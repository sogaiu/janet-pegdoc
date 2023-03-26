# janet-pegdoc (pdoc)

Tool for doc lookups, examples, and quizzes of [Janet's PEG
specials](https://janet-lang.org/docs/peg.html).

## Usage Examples

Ask for a quiz question.

```
$ pdoc --quiz range
(peg/match ~(range "aa")
           "a")
# =>
```

Show doc and examples for a peg special.

```
$ pdoc any

`(any patt)`

Matches 0 or more repetitions of `patt`

####################################################################

# any with empty string
(peg/match ~(any "a")
           "")
# =>
@[]

# any
(peg/match ~(any "a")
           "aa")
# =>
@[]

# any with capture
(peg/match ~(capture (any "a"))
           "aa")
# =>
@["aa"]
```

Show just doc for the peg special `to`.

```
$ pdoc -d to

`(to patt)`

Match up to `patt` (but not including it).

If the end of the input is reached and `patt` is not matched, the entire
pattern does not match.
```

Show just doc for a peg special via an alias.

```
$ pdoc -d ?

`(between min max patt)`

Matches between `min` and `max` (inclusive) repetitions of `patt`

`(opt patt)` and `(? patt)` are aliases for `(between 0 1 patt)`
```

Show just examples for a peg special.

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
  any
  at-least
  at-most
  backmatch
  between aka opt or ?
  choice aka +
  if
  if-not
  look aka >
  not aka !
  repeat aka n (actual number)
  sequence aka *
  some
  thru
  to
  unref

Captures
  accumulate aka %
  argument
  backref aka ->
  capture aka <- or quote
  cmt
  column
  constant
  drop
  error
  group
  int
  int-be
  lenprefix
  line
  number
  position aka $
  replace aka /
  uint
  uint-be

Built-ins
  :a                     =  (range "AZ" "az")
  :d                     =  (range "09")
  :h                     =  (range "09" "AF" "af")
  :s                     =  (set " \0\f\n\r\t\v")
  :w                     =  (range "09" "AZ" "az")
  :a*                    =  (any :a)
  :d*                    =  (any :d)
  :h*                    =  (any :h)
  :s*                    =  (any :s)
  :w*                    =  (any :w)
  :a+                    =  (some :a)
  :d+                    =  (some :d)
  :h+                    =  (some :h)
  :s+                    =  (some :s)
  :w+                    =  (some :w)
  :A                     =  (if-not :a 1)
  :D                     =  (if-not :d 1)
  :H                     =  (if-not :h 1)
  :S                     =  (if-not :s 1)
  :W                     =  (if-not :w 1)

Aliases
  (! patt)               =  (not patt)
  ($ ?tag)               =  (position ?tag)
  (% patt ?tag)          =  (accumulate patt ?tag)
  (* patt-1 ... patt-n)  =  (sequence patt-1 ... patt-n)
  (+ patt-1 ... patt-n)  =  (choice patt-1 ... patt-n)
  (-> prev-tag ?tag)     =  (backref prev-tag ?tag)
  (/ patt subst ?tag)    =  (replace patt subst ?tag)
  (<- patt ?tag)         =  (capture patt ?tag)
  (> offset patt)        =  (look offset patt)
  (? patt)               =  (between 0 1 patt)
  (1 patt)               =  (repeat 1 patt)
  (2 patt)               =  (repeat 2 patt)
  (3 patt)               =  (repeat 3 patt)
  ...
  (opt patt)             =  (between 0 1 patt)
  (quote patt ?tag)      =  (capture patt ?tag)
  'patt                  =  (capture patt)
```

Get basic help.

```
$ pdoc -h
Usage: pdoc [option] [peg-special]

View Janet PEG information.

  -h, --help                  show this output

  -d, --doc [<peg-special>]   show doc
  -x, --eg [<peg-special>]    show examples
  -q, --quiz [<peg-special>]  show quiz question

  --bash-completion           output bash-completion bits
  --fish-completion           output fish-completion bits
  --zsh-completion            output zsh-completion bits
  --raw-all                   show all names to help completion

With a peg-special, but no options, show docs and examples.
If any of "integer", "string", or "struct" are specified as the
"peg-special", show docs and examples about using those as PEG
constructs.

With the `-d` or `--doc` option, show docs for specified
PEG special, or if none specified, of a randomly chosen one.

With the `-x` or `--eg` option, show examples for
specified PEG special, or if none specified, of a randomly chosen
one.

With the `-q` or `--quiz` option, show quiz question for
specified PEG special, or if none specified, of a randonly chosen
one.

With no arguments, lists all PEG specials.

Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
appropriately so the shell doesn't process them in an undesired
fashion.
```

