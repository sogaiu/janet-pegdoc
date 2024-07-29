(import ../janet-peg/rewrite :prefix "")

# jg-capture-ast
(comment

  (peg/match jg-capture-ast ".0a")
  # =>
  @[[:symbol ".0a"]]

  (peg/match jg-capture-ast "foo:bar")
  # =>
  @[[:symbol "foo:bar"]]

  (peg/match jg-capture-ast "nil")
  # =>
  @[[:constant "nil"]]

  (peg/match jg-capture-ast "nil?")
  # =>
  @[[:symbol "nil?"]]

  (peg/match jg-capture-ast "true")
  # =>
  @[[:constant "true"]]

  (peg/match jg-capture-ast "true?")
  # =>
  @[[:symbol "true?"]]

  (peg/match jg-capture-ast "false")
  # =>
  @[[:constant "false"]]

  (peg/match jg-capture-ast "false?")
  # =>
  @[[:symbol "false?"]]

  (peg/match jg-capture-ast "8")
  # =>
  @[[:number "8"]]

  (peg/match jg-capture-ast "a")
  # =>
  @[[:symbol "a"]]

  (peg/match jg-capture-ast " ")
  # =>
  @[[:whitespace " "]]

  (peg/match jg-capture-ast "~a")
  # =>
  @[[:quasiquote [:symbol "a"]]]

  (peg/match jg-capture-ast "'a")
  # =>
  @[[:quote [:symbol "a"]]]

  (peg/match jg-capture-ast ";a")
  # =>
  @[[:splice [:symbol "a"]]]

  (peg/match jg-capture-ast ",a")
  # =>
  @[[:unquote [:symbol "a"]]]

  (peg/match jg-capture-ast "@(:a)")
  # =>
  '@[(:array (:keyword ":a"))]

  (peg/match jg-capture-ast "@[:a]")
  # =>
  '@[(:bracket-array (:keyword ":a"))]

  (peg/match jg-capture-ast "[:a]")
  # =>
  '@[(:bracket-tuple (:keyword ":a"))]

  (peg/match jg-capture-ast "{:a 1}")
  # =>
  '@[(:struct
       (:keyword ":a") (:whitespace " ")
       (:number "1"))]

  (peg/match jg-capture-ast "(:a)")
  # =>
  '@[(:tuple (:keyword ":a"))]

  (peg/match jg-capture-ast "(def a 1)")
  # =>
  '@[[:tuple
      [:symbol "def"] [:whitespace " "]
      [:symbol "a"] [:whitespace " "]
      [:number "1"]]]

  (peg/match jg-capture-ast "(def a # hi\n 1)")
  # =>
  '@[(:tuple
       (:symbol "def") (:whitespace " ")
       (:symbol "a") (:whitespace " ")
       (:comment "# hi") (:whitespace "\n") (:whitespace " ")
       (:number "1"))]

  )

# par
(comment

  (def src
    ``
    (+ 1 1)

    (/ 2 3)
    ``)

  (par src 0 :single)
  # =>
  '(@[:code
      (:tuple
        (:symbol "+") (:whitespace " ")
        (:number "1") (:whitespace " ")
        (:number "1"))]
     7)

  (par src 7 :single)
  # =>
  '(@[:code
      (:whitespace "\n")]
     8)

  (par src 8 :single)
  # =>
  '(@[:code
      (:whitespace "\n")]
     9)

  (par src 9 :single)
  # =>
  '(@[:code
      (:tuple
        (:symbol "/") (:whitespace " ")
        (:number "2") (:whitespace " ")
        (:number "3"))]
     16)

  (par "")
  # =>
  @[:code]

  )

# gen
(comment

  (gen
    [:constant "true"])
  # =>
  "true"

  (gen
    [:keyword ":x"])
  # =>
  ":x"

  (gen
    [:long-buffer "@```looooong buffer```"])
  # =>
  "@```looooong buffer```"

  (gen
    [:string "\"a string\""])
  # =>
  `"a string"`

  (gen
    [:symbol "non-descript-symbol"])
  # =>
  "non-descript-symbol"

  (gen
    [:whitespace "\n"])
  # =>
  "\n"

  (gen
    '(:quasiquote
       (:tuple
         (:symbol "/") (:whitespace " ")
         (:number "1") (:whitespace " ")
         (:symbol "a"))))
  # =>
  "~(/ 1 a)"

  (gen
    '(:quote
       (:tuple
         (:symbol "*") (:whitespace " ")
         (:number "0") (:whitespace " ")
         (:symbol "x"))))
  # =>
  "'(* 0 x)"

  (gen
    '(:splice
       (:tuple
         (:keyword ":a") (:whitespace " ")
         (:keyword ":b"))))
  # =>
  ";(:a :b)"

  (gen
    '(:unquote
       (:symbol "a")))
  # =>
  ",a"

  (gen
    '(:bracket-array
       (:keyword ":a") (:whitespace " ")
       (:keyword ":b")))
  # =>
  "@[:a :b]"

  (gen
    '@(:bracket-tuple
       (:keyword ":a") (:whitespace " ")
       (:keyword ":b")))
  # =>
  "[:a :b]"

  (gen
    '@(:table
       (:keyword ":a") (:whitespace " ")
       (:number "1")))
  # =>
  "@{:a 1}"

  (gen
    '@(:tuple
       (:keyword ":a") (:whitespace " ")
       (:keyword ":b")))
  # =>
  "(:a :b)"

  )
