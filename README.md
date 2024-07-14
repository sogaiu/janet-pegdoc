# janet-pegdoc (pdoc)

Tool for doc lookups, usages, and quizzes of [Janet's PEG
specials](https://janet-lang.org/docs/peg.html).

`pdoc` manifests itself as a macro as well as a command line tool.

## Installation

Quick:

```
jpm install https://github.com/sogaiu/janet-pegdoc
```
Manual:

```
git clone https://github.com/sogaiu/janet-pegdoc
cd janet-pegdoc
jpm install
```

In either case, success should lead to the command `pdoc` being
available on `PATH` and a `pegdoc` directory under `JANET_PATH`.

## Use from REPL

There is a macro named `pdoc` (a bit like the built in `doc` macro)
that can be used from the REPL to look up PEG special documentation.

One way to use it is to start `janet` like:

```
janet -l pegdoc
```

Then at the REPL:

```
Janet 1.32.1-11d7af3f linux/x64/gcc - '(doc)' for help
repl:1:> (pdoc if)


    peg special

    (if cond patt)

    Tries to match patt only if cond matches as well.

    cond will not produce any captures.

nil
```

Alternatively, evaluate `(use pegdoc)` before invoking `(pdoc ...)`.

Setting up one's user profile appropriately may be another way to make
`pdoc` available (see `-R` and/or `JANET_PROFILE` info in the janet(1)
manual page for hints).

Like the `doc` macro, `pdoc` can also be invoked with a string (or no
argument) to produce a set of search results.  The results are grouped
according to whether they are primitive, combining, or capture
patterns.

## CLI Invocation Examples

Show doc and usages for a peg special.

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

Show just usages for a peg special.

```
$ pdoc -u if

(peg/match ~(if 1 "a")
           "a")
# =>
@[]

(peg/match ~(if 5 (set "eilms"))
           "smile")
# =>
@[]

(peg/match ~(if 5 (set "eilms"))
           "wink")
# =>
nil
```

Ask for a quiz question and have your answer checked.

```
$ pdoc --quiz replace
(peg/match ~(replace (sequence (capture "ca")
                               (_______ "t"))
                     ,(fn [one two]
                        (string one two "alog")))
           "cat")
# =>
@["catalog"]

What value could work in the blank?
```

Show all peg specials.

```
$ pdoc

Primitive Patterns
  Integer (..., -1, 0, 1, ...)
  range                  =  (range r1 ?r2 ... ?rn)
  set                    =  (set chars)
  String ("...")
  Boolean (true, false)

Combining Patterns
  any                    =  (any patt)
  at-least               =  (at-least n patt)
  at-most                =  (at-most n patt)
  backmatch              =  (backmatch ?tag)
  between (opt, ?)       =  (between min max patt)
  choice (+)             =  (choice patt-1 patt-2 ...)
  if                     =  (if cond patt)
  if-not                 =  (if-not cond patt)
  look (>)               =  (look offset ?patt)
  not (!)                =  (not patt)
  repeat (0, 1, 2, ...)  =  (repeat n patt)
  sequence (*)           =  (sequence patt-1 patt-2 ...)
  some                   =  (some patt)
  split                  =  (split sep patt)
  sub                    =  (sub window-patt patt)
  thru                   =  (thru patt)
  to                     =  (to patt)

Captures
  accumulate (%)         =  (accumulate pat ?tag)
  argument               =  (argument n ?tag)
  backref (->)           =  (backref prev-tag ?tag)
  capture (<-, quote)    =  (capture patt ?tag)
  cmt                    =  (cmt patt fun ?tag)
  column                 =  (column ?tag)
  constant               =  (constant k ?tag)
  drop                   =  (drop patt)
  error                  =  (error ?patt)
  group                  =  (group patt ?tag)
  int                    =  (int n ?tag)
  int-be                 =  (int-be n ?tag)
  lenprefix              =  (lenprefix n patt)
  line                   =  (line ?tag)
  number                 =  (number patt ?base ?tag)
  position ($)           =  (position ?tag)
  replace (/)            =  (replace patt subst ?tag)
  uint                   =  (uint n ?tag)
  uint-be                =  (uint-be n ?tag)
  unref                  =  (unref rule ?tag)

Built-ins
  :a                     =  (range "AZ" "az")
  :d                     =  (range "09")
  :h                     =  (range "09" "AF" "af")
  :s                     =  (set " \0\f\n\r\t\v")
  :w                     =  (range "09" "AZ" "az")
  :A                     =  (if-not :a 1)
  :D                     =  (if-not :d 1)
  :H                     =  (if-not :h 1)
  :S                     =  (if-not :s 1)
  :W                     =  (if-not :w 1)
  :a+                    =  (some :a)
  :d+                    =  (some :d)
  :h+                    =  (some :h)
  :s+                    =  (some :s)
  :w+                    =  (some :w)
  :A+                    =  (some :A)
  :D+                    =  (some :D)
  :H+                    =  (some :H)
  :S+                    =  (some :S)
  :W+                    =  (some :W)
  :a*                    =  (any :a)
  :d*                    =  (any :d)
  :h*                    =  (any :h)
  :s*                    =  (any :s)
  :w*                    =  (any :w)
  :A*                    =  (any :A)
  :D*                    =  (any :D)
  :H*                    =  (any :H)
  :S*                    =  (any :S)
  :W*                    =  (any :W)

Aliases
  (! patt)               =  (not patt)
  ($ ?tag)               =  (position ?tag)
  (% patt ?tag)          =  (accumulate patt ?tag)
  (* patt-1 ... patt-n)  =  (sequence patt-1 ... patt-n)
  (+ patt-1 ... patt-n)  =  (choice patt-1 ... patt-n)
  (-> prev-tag ?tag)     =  (backref prev-tag ?tag)
  (/ patt subst ?tag)    =  (replace patt subst ?tag)
  (<- patt ?tag)         =  (capture patt ?tag)
  (> offset ?patt)       =  (look offset ?patt)
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
Usage: pdoc [option] [peg-special]
       pdoc [-t|--trace] [file|pattern]

View Janet PEG information.

  -h, --help                   show this output

  -d, --doc [<peg-special>]    show doc
  -q, --quiz [<peg-special>]   show quiz question
  -u, --usage [<peg-special>]  show usage

  -t, --trace [file|pattern]   generate trace files

  --bash-completion            output bash-completion bits
  --fish-completion            output fish-completion bits
  --zsh-completion             output zsh-completion bits
  --raw-all                    show all names for completion

With a peg-special, but no options, show docs and usages.

If any of "boolean", "dictionary", "integer", "string",
"struct", or "table" are specified as the "peg-special",
show docs and usages about using those as PEG constructs.

With the `-d` or `--doc` option, show docs for specified
PEG special, or if none specified, for a randomly chosen one.

With the `-q` or `--quiz` option, show quiz question for
specified PEG special, or if none specified, for a randomly
chosen one.

With the `-u` or `--usage` option, show usages for
specified PEG special, or if none specified, for a randomly
chosen one.

With the `-t` or `--trace` option, generate trace files for
`meg/match` using arguments contained in `file` or a file
selected by substring-matching a file name specified by
`pattern`.  `file` should be a `.janet` file, which when
evaluated, returns a tuple with values for each desired
argument.  If `file` or `pattern` is not provided, some
appropriate content will be arranged for.  Generated files
will end up in a subdirectory.  `meg/match`'s signature is
the same as that of `peg/match`.

With the `-w` or `--web` option, start a local web server
that provides access to the tracing functionality described
for the `-t` or `--trace` option.

With no arguments, lists all PEG specials.

Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
appropriately so the shell doesn't process them in an
undesired fashion.
```

## Conveniences

### Flexible Option Position

As a convenience feature, options (e.g. `-u` or `-d`) can be specified
before or after a PEG special, e.g. invoking:

```
pdoc -d thru
```

should yield the same result as:

```
pdoc thru -d
```

This was done so that quick editing of a previous command would be
more convenient for different uses.

If interested in a particular PEG special, may be you'd prefer to be
invoking `pdoc <peg-special> -d` followed by `pdoc <peg-special> -u`,
and then may be even `pdoc <peg-special> -q` for a quiz question.

Instead, if interested in seeing usages for different PEG specials,
may be you'd prefer to be invoking `pdoc -u int` followed by
`pdoc -u int-be` or `pdoc -u uint`.

### Shell Completion

The PEG special argument to `pdoc` can be completed if using the bash
/ fish / zsh shells with appropriate configuration.

So for example, pressing `TAB` after entering `pdoc a` might yield the
output:

```
accumulate  any         argument    at-least    at-most
```

To set this up, invoke `pdoc` with one of the following for the
relevant shell:

* `--bash-completion`
* `--fish-completion`
* `--zsh-completion`

Put the resulting output in a location appropriate for the shell in
use.

Below are some hints about where such locations might be:

* [bash](https://github.com/scop/bash-completion/blob/master/README.md#faq) --
  look for `Where should I install my own local completions?`
* [fish](https://fishshell.com/docs/current/completions.html#where-to-put-completions)
* [zsh](https://zsh.sourceforge.io/Doc/Release/Completion-System.html) -- good luck :P

## Credits

Portions of tests and the documentation come from Janet and the
janet-lang.org website.  In addition, spork/http is included.

Thus the following license applies to at least those portions.

```
Copyright (c) 2019, 2020, 2021, 2022, 2023, 2024 Calvin Rose and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
