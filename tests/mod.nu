use std assert
use ../nu-batteries *

export def test-update-where [] {
  assert equal ([[a b]; [1 2] [3 4]] | update-where { $in.a == 3 } b 10) [[a b]; [1 2] [3 10]]
  assert equal ([[a b]; [1 2] [3 4]] | update-where { $in.a == 33 } b 10) [[a b]; [1 2] [3 4]]
  assert equal ([[a b]; [1 2] [3 4]] | update-where { $in.a == 3 } b {$in * 10}) [[a b]; [1 2] [3 40]]
}

export def test-with-next [] {
  assert equal ([1 2 3] | iter with-next) [[item next]; [1 2] [2 3] [3 null]]
  assert equal ([] | iter with-next) []
}

export def test-with-previous [] {
  assert equal ([1 2 3] | iter with-previous) [[item previous]; [1 null] [2 1] [3 2]]
  assert equal ([] | iter with-previous) []
}

export def test-iter-product [] {
  assert equal ([a b c] | iter product [1 2]) [[a, 1], [a, 2], [b, 1], [b, 2], [c, 1], [c, 2]]
  assert equal ([a b c] | iter product []) []
  assert equal ([] | iter product [1 2]) []
}

export def test-set-difference [] {
  assert equal ([1 4 6] | set difference [4 2 8]) [1 6]
  assert equal ([1 2 3] | set difference [4 5]) [1 2 3]
  assert equal ([] | set difference [3 4]) []
  assert equal ([3 4] | set difference []) [3 4]
  assert equal ([] | set difference []) []
}

export def test-set-symmetric-difference [] {
  assert equal ([1 4 6] | set symmetric-difference [4 2 8] | sort) [1 2 6 8]
  assert equal ([1 2 3] | set symmetric-difference [4 5] | sort) [1 2 3 4 5]
  assert equal ([] | set symmetric-difference [3 4]) [3 4]
  assert equal ([3 4] | set symmetric-difference []) [3 4]
  assert equal ([] | set symmetric-difference []) []
}

export def test-set-intersection [] {
  assert equal ([1 4 6] | set intersection [4 2 8]) [4]
  assert equal ([1 2 3] | set intersection [4 5]) []
  assert equal ([] | set intersection [3 4]) []
  assert equal ([3 4] | set intersection []) []
  assert equal ([] | set intersection []) []
}

export def test-set-union [] {
  assert equal ([1 4 6] | set union [4 2 8] | sort) [1 2 4 6 8]
  assert equal ([1 2 3] | set union [4 5] | sort) [1 2 3 4 5]
  assert equal ([] | set union [3 4]) [3 4]
  assert equal ([3 4] | set union []) [3 4]
  assert equal ([] | set union []) []
}

export def test-set-is-subset [] {
  assert ([4 2] | set is-subset [1 2 4 6])
  assert ([] | set is-subset [1 2 4 6])
  assert not ([4 2] | set is-subset [2 6])
  assert not ([3 1] | set is-subset [])
}

export def test-set-is-superset [] {
  assert ([1 2 4 6] | set is-superset [4 2])
  assert ([1 2 4 6] | set is-superset [])
  assert not ([2 6] | set is-superset [4 2])
  assert not ([] | set is-superset [3 1])
}

export def test-set-equal [] {
  assert ([1 2 3] | set equal [3 1 2])
  assert not ([1 2 3] | set equal [1 3])
  assert not ([1 3] | set equal [1 3 2])
  assert not ([1 2] | set equal [3 4])
  assert ([] | set equal [])
}

export def test-path-prefix [] {
  assert equal ([/usr/local/bin /usr/bin] | path prefix) /usr
  assert equal ([/usr/bin /bin] | path prefix) /
  assert equal ([/usr/local/bin /usr/local/bin] | path prefix) /usr/local/bin
}

export def test-path-lookup [] {
  let testdir = mktemp --directory
  mkdir ($testdir | path join "a")
  mkdir ($testdir | path join "b")
  touch ($testdir | path join "a" "aaa")
  touch ($testdir | path join "b" "bbb")
  let p = [a b] | each {|x| $testdir | path join $x }

  assert equal ("aaa" | path lookup $p) ($testdir | path join "a" "aaa")
  assert equal ("bbb" | path lookup $p) ($testdir | path join "b" "bbb")
  assert equal ("nonexistent" | path lookup $p) null

  rm -rf $testdir
}

export def test-text-indent [] {
  assert equal ("abc\n\ndef" | text indent "  ") "  abc\n\n  def"
  assert equal ("abc\n\ndef" | text indent "# " {true}) "# abc\n# \n# def"
}

export def test-text-dedent [] {
  assert equal ("  abc\n    def" | text dedent) "abc\n  def"
  assert equal ("    abc\n  def" | text dedent) "  abc\ndef"
}
