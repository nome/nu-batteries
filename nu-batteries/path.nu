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
