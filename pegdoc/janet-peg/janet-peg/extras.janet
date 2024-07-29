(import ./grammar :prefix "")

# make a version of jg that matches a single form
(def jg-one
  (->
   # jg is a struct, need something mutable
   (table ;(kvs jg))
   # just recognize one form
   (put :main :input)
   # tried using a table with a peg but had a problem, so use a struct
   table/to-struct))

(comment

  (try
    (peg/match jg-one "\"\\u001\"")
    ([e] e))
  # =>
  "bad escape"

  (peg/match jg-one "\"\\u0001\"")
  # =>
  @[]

  (peg/match jg-one "(def a 1)")
  # =>
  @[]

  (try
    (peg/match jg-one "[:a :b)")
    ([e] e))
  # =>
  "missing ]"

  (peg/match jg-one "(def a # hi\n 1)")
  # =>
  @[]

  (try
    (peg/match jg-one "(def a # hi 1)")
    ([e] e))
  # =>
  "missing )"

  (peg/match jg-one "[1]")
  # =>
  @[]

  (peg/match jg-one "# hello")
  # =>
  @[]

  (peg/match jg-one "``hello``")
  # =>
  @[]

  (peg/match jg-one "8")
  # =>
  @[]

  (peg/match jg-one "[:a :b]")
  # =>
  @[]

  (peg/match jg-one "[:a :b] 1")
  # =>
  @[]

 )

# make a capturing version of jg
(def jg-capture
  (->
   # jg is a struct, need something mutable
   (table ;(kvs jg))
   # capture recognized bits
   (put :main ~(capture ,(in jg :main)))
   # tried using a table with a peg but had a problem, so use a struct
   table/to-struct))

(comment

  (peg/match jg-capture "")
  # =>
  nil

  (peg/match jg-capture "nil")
  # =>
  @["nil"]

  (peg/match jg-capture "true")
  # =>
  @["true"]

  (peg/match jg-capture "false")
  # =>
  @["false"]

  (peg/match jg-capture "symbol")
  # =>
  @["symbol"]

  (peg/match jg-capture "kebab-case-symbol")
  # =>
  @["kebab-case-symbol"]

  (peg/match jg-capture "snake_case_symbol")
  # =>
  @["snake_case_symbol"]

  (peg/match jg-capture "my-module/my-function")
  # =>
  @["my-module/my-function"]

  (peg/match jg-capture "*****")
  # =>
  @["*****"]

  (peg/match jg-capture "!%$^*__--__._+++===-crazy-symbol")
  # =>
  @["!%$^*__--__._+++===-crazy-symbol"]

  (peg/match jg-capture "*global-var*")
  # =>
  @["*global-var*"]

  (peg/match jg-capture "你好")
  # =>
  @["\xE4\xBD\xA0\xE5\xA5\xBD"]

  (peg/match jg-capture ":keyword")
  # =>
  @[":keyword"]

  (peg/match jg-capture ":range")
  # =>
  @[":range"]

  (peg/match jg-capture ":0x0x0x0")
  # =>
  @[":0x0x0x0"]

  (peg/match jg-capture ":a-keyword")
  # =>
  @[":a-keyword"]

  (peg/match jg-capture "::")
  # =>
  @["::"]

  (peg/match jg-capture ":")
  # =>
  @[":"]

  (peg/match jg-capture "0")
  # =>
  @["0"]

  (peg/match jg-capture "12")
  # =>
  @["12"]

  (peg/match jg-capture "-65912")
  # =>
  @["-65912"]

  (peg/match jg-capture "1.3e18")
  # =>
  @["1.3e18"]

  (peg/match jg-capture "-1.3e18")
  # =>
  @["-1.3e18"]

  (peg/match jg-capture "18r123C")
  # =>
  @["18r123C"]

  (peg/match jg-capture "11raaa&a")
  # =>
  @["11raaa&a"]

  (peg/match jg-capture "1_000_000")
  # =>
  @["1_000_000"]

  (peg/match jg-capture "0xbeef")
  # =>
  @["0xbeef"]

  (try
    (peg/match jg-capture "\"\\u001\"")
    ([e] e))
  # =>
  "bad escape"

  (peg/match jg-capture "\"\\u0001\"")
  # =>
  @["\"\\u0001\""]

  (peg/match jg-capture "\"\\U000008\"")
  # =>
  @["\"\\U000008\""]

  (peg/match jg-capture "(def a 1)")
  # =>
  @["(def a 1)"]

  (try
    (peg/match jg-capture "[:a :b)")
    ([e] e))
  # =>
  "missing ]"

  (peg/match jg-capture "(def a # hi\n 1)")
  # =>
  @["(def a # hi\n 1)"]

  (try
    (peg/match jg-capture "(def a # hi 1)")
    ([e] e))
  # =>
  "missing )"

  (peg/match jg-capture "[1]")
  # =>
  @["[1]"]

  (peg/match jg-capture "# hello")
  # =>
  @["# hello"]

  (peg/match jg-capture "``hello``")
  # =>
  @["``hello``"]

  (peg/match jg-capture "8")
  # =>
  @["8"]

  (peg/match jg-capture "[:a :b]")
  # =>
  @["[:a :b]"]

  (peg/match jg-capture "[:a :b] 1")
  # =>
  @["[:a :b] 1"]

  (def sample-source
    (string "# \"my test\"\n"
            "(+ 1 1)\n"
            "# => 2\n"))

  (peg/match jg-capture sample-source)
  # =>
  @["# \"my test\"\n(+ 1 1)\n# => 2\n"]

  )

# make a version of jg that captures a single form
(def jg-capture-one
  (->
   # jg is a struct, need something mutable
   (table ;(kvs jg))
   # capture just one form
   (put :main '(capture :input))
   # tried using a table with a peg but had a problem, so use a struct
   table/to-struct))

(comment

  (def sample-source
    (string "# \"my test\"\n"
            "(+ 1 1)\n"
            "# => 2\n"))

  (peg/match jg-capture-one sample-source)
  # =>
  @["# \"my test\""]

  (peg/match jg-capture-one sample-source 11)
  # =>
  @["\n"]

  (peg/match jg-capture-one sample-source 12)
  # =>
  @["(+ 1 1)"]

  (peg/match jg-capture-one sample-source 20)
  # =>
  @["# => 2"]

 )

(comment

  (comment

    # replace all underscores in keywords with dashes

    (import ./rewrite)

    (let [src (slurp (string (os/getenv "HOME")
                             "/src/janet-peg/janet-peg/rewrite.janet"))
          nodes (rewrite/par src)]
      (print
        (rewrite/gen
          (postwalk |(if (and (= (type $) :tuple)
                              (= (first $) :keyword)
                              (string/find "_" (in $ 1)))
                       (tuple ;(let [arr (array ;$)]
                                 (put arr 1
                                      (string/replace-all "_" "-" (in $ 1)))))
                       $)
                    nodes))))

    )

  )
