use std iter

# Finds the largest common prefix in a list of paths.
#
# Examples:
# ---------
#   > [/usr/local/bin /usr/bin] | path prefix
export def prefix []: list<string> -> string {
  path split
  | reduce {|it, prefix|
    $it | zip $prefix | take while { $in.0 == $in.1 }
  }
  | each { get 0 }
  | path join
}

# Looks up a file or directory in a list of paths.
#
# Examples:
# ---------
#   `(which nu).path`
#   > "nu" | path lookup $env.PATH
export def lookup [pathlist: list<string>]: string -> string {
  let needle = $in
  $pathlist
    | each { path join $needle }
    | iter find {|p| $p | path exists}
}
