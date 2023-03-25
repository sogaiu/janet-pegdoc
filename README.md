# janet-pegdoc (pdoc)

Tool for quick doc lookups and examples of Janet's PEG specials.

## Usage Examples

Getting basic help.

```
$ pdoc -h
Usage: pdoc -h|--help
       pdoc [peg-special]
       pdoc -x|--eg peg-special
View peg information.

  -x, --eg      show examples
  -h, --help    show this output

With a peg-special, but no options, show some documentation.
If any of "integer", "string", or "struct" are specified as the
"peg-special", show docs about using those as PEG constructs.

With the `-x` or `--eg` option and a peg-special (or one of the
exceptions mentioned above), show associated examples.

With no arguments, lists all peg specials.

Be careful to quote shortnames (e.g. *, ->, <-) appropriately
so the shell doesn't process them in an undesired fashion.
```

Show doc for the peg special `to`.

```
$ pdoc to

`(to patt)`

Match up to `patt` (but not including it).

If the end of the input is reached and `patt` is not matched, the entire
pattern does not match.
```

Show doc for a peg special via an alias.

```
$ pdoc ?

`(between min max patt)`

Matches between `min` and `max` (inclusive) repetitions of `patt`

`(opt patt)` and `(? patt)` are aliases for `(between 0 1 patt)`
```

Show examples for a peg special.

```
$ pdoc -x string

(peg/match "cat" "cat")
# =>
@[]

(peg/match "cat" "cat1")
# =>
@[]

(peg/match "" "")
# =>
@[]

(peg/match "" "a")
# =>
@[]

(peg/match "cat" "dog")
# =>
nil
```

Show all peg specials.

```
$ pdoc
Primitive Patterns
  Integer Patterns
  Range Patterns
  Set Patterns
  String Patterns

Combining Patterns
  `any`
  `at-least`
  `at-most`
  `backmatch`
  `between` aka `opt` or `?`
  `choice` aka `+`
  `if`
  `if-not`
  `look` aka `>`
  `not` aka `!`
  `repeat` aka `n` (actual number)
  `sequence` aka `*`
  `some`
  `thru`
  `to`
  `unref`

Captures
  `accumulate` aka `%`
  `argument`
  `backref` aka `->`
  `capture` aka `<-` or `quote`
  `cmt`
  `column`
  `constant`
  `drop`
  `error`
  `group`
  `int`
  `int-be`
  `lenprefix`
  `line`
  `number`
  `position` aka `$`
  `replace` aka `/`
  `uint`
  `uint-be`
```
