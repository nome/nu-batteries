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

