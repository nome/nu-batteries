# This module provides commands which operate on tables

# Update an existing column to have new values in rows matching a condition.
#
# Similar to `where <row_condition> | update <column> <replacement>`, but includes
# rows which do not match `<row_condition>` unmodified.
#
# Examples:
# ---------
#   Change type to "large-file" for files larger than 1kB.
#   > ls | update-where { $in.size > 1kB } type "large-file"
# 
export def update-where [
  row_condition: closure  # The condition that selects which rows to update.
  column: cell-path  # The name of the column to update.
  replacement: any  # The new value to give the cell(s), or a closure to create the value.
]: table -> table {
  each {|x|
    if ($x | do $row_condition) {
      update $column $replacement
    } else {
      $in
    }
  }
}
