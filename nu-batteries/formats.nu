# This module provides format cnonversion commands.

# Convert simple markdown table to nushell table.
#
# Examples:
# ---------
#   > ls | to md | from mdtable
export def "from mdtable" []: string -> table {
  let lines = $in | lines
  let format = $lines | get 0 | split row '|' | skip 1 | drop 1 | str trim | str join '}|{'
  $lines | skip 2 | parse $"|{($format)}|"
}

# TODO: starting with nushell 0.108.0, compact supports records natively
#       so at some point we could just remove this custom function
def compact-record []: record -> record {
  transpose key value
  | compact value
  | transpose -rid
  | if $in == [] { {} } else { $in }
}

# Normalize dn, control and changetype parts of a change record.
#
# While RFC2849 specifies all three of these in lower case, real-world examples
# with mixed case exist (e.g. changeType instead of changetype).
def normalize-change-record []: record -> record {
  transpose key value
  | update key {
    let key = $in
    let downcased = $key | str downcase
    if $downcased in [dn control changetype] {
      $downcased
    } else {
      $key
    }
  }
  | transpose -rid
}

# Parse a list of RFC2849 attrval-spec blocks, possibly including a dn-spec
# (which is basically just an attrval-spec with a value that must be valid
# UTF-8 and cannot be a url). Values for repeated attributes are represented as
# lists. Attributes with options (e.g. "cn;lang-ja") are represented as-is in
# the tables's column names, without further parsing them into AttributeType
# and option list. Url values are passed through `url parse`.
def parse-attrval-specs []: list<string> -> table {
  split column -n 2 ":" key value
  | update value {
    let value = $in
    if ($value | str starts-with ":") {
      # handle base64 encoded values
      $value
      | str substring 1..
      | str trim
      | decode base64
      | decode utf-8
    } else if ($value | str starts-with "<") {
      # handle url values
      $value
      | str substring 1..
      | url parse
    } else {
      # handle regular values
      $value | str trim -l
    }
  }
  | transpose -raid
}

# Convert LDAP data interchange format to nushell table
#
# Should be able to parse any RFC2849 conforming input.
#
# Can parse both LDIF content and changes formats.
# URL values are represented by records, as returned by `url parse`.
# Attribute options are currently not parsed, so an attribute specifier like
# "ou;lang-ja" will result in a column of the same name rather than an "ou"
# column.
#
# Examples:
# ---------
#  > ldapsearch -x -LLL objectClass=posixAccount | from ldif
export def "from ldif" []: string -> table {
  str replace -a "\n " ""
  # strip version specifier
  | str replace -r '^version: +\d+\r?\n' ''
  | split row -r '\n{2,}'
  # iterate over records (ldif-attrval-record or ldif-change-record)
  | each {
    # handle "-" separated change-modify record mod-specs
    | split row -r '\r?\n-\r?\n'
    | each {
      lines
      # ignore comments and trailing "-"
      | where {|line| not ($line | str starts-with '#') and $line != "-" }
      | parse-attrval-specs
    }
    # remove empty lists caused by trailing "-"
    | compact --empty
    # This is the most tricky bit: we want to copy dn, control and changetype
    # (pseudo-)attributes (if present) from the first mod-spec block over to any
    # following blocks, so that every one becomes a valid standalone
    # change-modify block.
    | generate {|modspec, common|
      let common = $common | default { $modspec | select dn!? control!? changetype!? | compact-record }
      {
        out: ($modspec | merge $common | normalize-change-record)
        next: $common
      }
    } null
  }
  # flatten nested structure caused by change-modify mod-spec parsing
  | flatten
}

# Convert nushell table to LDAP data interchange format
#
# This does NOT check whether the input table specifies valid LDIF data (e.g.
# all records containing a "dn" field).
# URL references are currently not supported.
#
# Examples:
#  > [[dn objectclass cn uid]; ["cn=Barbara Jensen,dc=example,dc=com" person ["Barbara Jensen" "Babs Jensen"] bjensen]] | to ldif | ldapadd
export def "to ldif" []: table -> string {
  # make sure dn is the first line of every record output,
  # followed by control (if present) and changetype (for change records)
  move --first ...(let c = $in | columns; [dn control changetype] | where {|x| $x in $c})
  | each {
    transpose key value
    # FIXME: This should only flatten lists, not (url) records
    | flatten
    | update value {
      let value = $in
      if ($value | describe) =~ "record" {
        # value presumably describes a URL (see `url join`/`url parse`)
        url join | "< " + $in
      } else if $value =~ '^[\x01-\x09\x0b-\x0c\x0e-\x1f\x21-\x39\x3b\x3d-\x7f][\x01-\x09\x0b-\x0c\x0e-\x7f]*$' {
        # value is a SAFE-STRING according to RFC2849
        if ($value | str ends-with " ") {
          # Values or distinguished names that end with SPACE SHOULD be base-64 encoded.
          $value | encode base64 | ": " + $in
        } else {
          " " + $value
        }
      } else if ($value | is-empty) {
        " "
      } else {
        $value | encode base64 | ": " + $in
      }
    }
    | each { $"($in.key):($in.value)" }
    | str join "\n"
  }
  | str join "\n\n"
  | "version: 1\n" ++ $in
}
