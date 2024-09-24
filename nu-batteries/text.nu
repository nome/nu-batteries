# This module contains commands for working with text.

# Adds `prefix` to the beginning of selected lines of text.
#
# If `condition` is not given or `null`, adds `prefix` to all lines which
# contain non-whitespace chars, i.e. non-empty lines.
#
# Examples:
# ---------
#   Indent by two space
#   > "abc\n\ndef" | text indent "  "
#
#   Comment lines of shell code
#   > "abc\n\ndef" | text indent "# "
#
#   Also modify empty lines
#   > "abc\n\ndef" | text indent "# " {true}
export def indent [
  prefix: string  # The string to prepend to each line.
  condition?: closure  # Only modify lines for which this returns true
]: string -> string {
  let default_condition = {$in !~ '^\s*$'}
  $in | lines
  | each {|line|
    if ($line | do ($condition | default $default_condition)) {
      $prefix ++ $line
    } else {
      $line
    }
  }
  | str join "\n"
}

# Removes common leading whitespace from every line of text.
#
# Examples:
# ---------
#   > "  abc\n    def" | text dedent
export def dedent []: string -> string {
  let lines = lines
  let prefix = $lines
    | each { str replace --regex '\S+.*' '' }
    | reduce {|it, prefix|
      if $it starts-with $prefix {
        $prefix
      } else if $prefix starts-with $it {
        $it
      } else {
        ''
      }
    }
    | str length
  $lines
  | each { str substring $prefix.. }
  | str join "\n"
}
