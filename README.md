# janet-pegdoc (pdoc)

Tool for quick doc lookups of Janet's peg specials.

## Usage Examples

Getting basic help.

```
$ pdoc --help
Usage: pdoc [peg-special]
View peg docs for a peg special.

  --help    show this output

With a peg-special, but no options, show some documentation.

With no arguments, lists all peg specials.
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
