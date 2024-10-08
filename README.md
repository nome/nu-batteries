# nu-batteries - An extended standard library for nu

:warning: **This module and its APIs should be considered experimental.** :warning:

## :recycle: installation
### using nupm
* `nupm install https://github.com/nome/nu-batteries`

### manually
* `git clone https://github.com/nome/nu-batteries`
* In your `env.nu`, add the path of the `nu-batteries` directory to `$env.NU_LIB_DIRS`

## usage
```
> overlay use nu-batteries

# Change type to "large-file" for files larger than 1kB.
> ls nu-batteries | update-where { $in.size > 1kB } type "large-file"
╭───┬─────────────────────────┬────────────┬────────┬────────────────╮
│ # │          name           │    type    │  size  │    modified    │
├───┼─────────────────────────┼────────────┼────────┼────────────────┤
│ 0 │ nu-batteries/filters.nu │ file       │  810 B │ 13 minutes ago │
│ 1 │ nu-batteries/iter.nu    │ file       │  987 B │ 15 minutes ago │
│ 2 │ nu-batteries/mod.nu     │ file       │   72 B │ an hour ago    │
│ 3 │ nu-batteries/set.nu     │ large-file │ 1.4 KB │ 19 minutes ago │
╰───┴─────────────────────────┴────────────┴────────┴────────────────╯

# Find the most specific paths in a list, discarding parent directories
> [/a /a/b /c] | sort | iter with-next | default '' next | where { not ($in.next starts-with $in.item) } | get item
╭───┬──────╮
│ 0 │ /a/b │
│ 1 │ /c   │
╰───┴──────╯

# Find items that were removed from a list
> [551, 588, 804, 290, 298] | set difference [551, 588, 804, 298]
╭───┬─────╮
│ 0 │ 290 │
╰───┴─────╯

# Find the largest common prefix in a list of paths
> [/usr/local/bin /usr/bin] | path prefix
/usr

# look up a file or directory in a list of directories
> "nupm" | path lookup $env.NU_LIB_DIRS
/home/nome/.config/nushell/nupm/modules/nupm
> "applications/Alacritty.desktop" | path lookup ($env.XDG_DATA_DIRS | split row (char esep))
/usr/share/applications/Alacritty.desktop

# Increase indentation of text without creating trailing whitespace on empty lines
> "1. first\n   * sub-point\n\n2. second" | text indent "  "
  1. first
     * sub-point

  2. second

# Remove indentation from text
> "  1. first\n     * sub-point" | text dedent
1. first
   * sub-point

# Comment out lines of code or configuration
> "def hello [] {\n  'world'\n}" | text indent "# " {true}
# def hello [] {
#   'world'
# }
```

For a list of all commands, see `help nu-batteries`.
