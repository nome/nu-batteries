# This module provides `filters` like commands which operate on lists

# Iterates over list items together with the next item in the list.
#
# Examples:
# ---------
#   Find the most specific paths in a list, discarding parent directories
#   > [/a /a/b /c] | sort | iter with-next | default '' next | where { not ($in.next starts-with $in.item) } | get item
export def with-next []: list<any> -> table<item: any, next: any> {
  zip (($in | skip) ++ [null])
  | each {|values|
    [item next] | zip $values | into record
  }
}

# Iterates over list items together with the previous item in the list.
#
# Examples:
# ---------
#   Find "rising" elements in a list, that are large than the previous value
#   > [4 5 1 3 -4] | iter with-previous | default (-inf) previous | where { $in.item > $in.previous } | get item
export def with-previous []: list<any> -> table<item: any, previous: any> {
  zip ([null] ++ $in)
  | each {|values|
    [item previous] | zip $values | into record
  }
}
