# Commands for working with sets
#
# The commands in this module provide basic set operations on lists.

# Return the list of elements that are in the input but not in `other`.
export def difference [other: list<any>]: list<any> -> list<any> {
  filter {|x| $x not-in $other }
}

# Return the list of elements that are in either the input list and `other` but not both.
export def symmetric-difference [other: list<any>]: list<any> -> list<any> {
  let self = $in
  ($self | filter {|x| $x not-in $other}) ++ ($other | filter {|x| $x not-in $self})
}

# Return the list of elements that are both in the input list and in `other`.
export def intersection [other: list<any>]: list<any> -> list<any> {
  filter {|x| $x in $other }
}

# Return the list of elements that are in either input list or `other`.
export def union [other: list<any>]: list<any> -> list<any> {
  append $other | uniq
}

# Check whether the input list is a subset of `other`
#
# Returns true if all input elements are contained in `other`, false otherwise.
export def is-subset [other: list<any>]: list<any> -> bool {
  all {|x| $x in $other}
}

# Check whether the input list is a superset of `other`.
#
# Returns true if all elements of `other` are contained in the input list, false otherwise.
export def is-superset [other: list<any>]: list<any> -> bool {
  let self = $in
  $other | all {|x| $x in $self}
}

# Check whether the input list contains the same items as `other` (in any order).
export def equal [other: list<any>]: list<any> -> bool {
  let self = $in
  ($self | all {|x| $x in $other}) and ($other | all {|x| $x in $self})
}
