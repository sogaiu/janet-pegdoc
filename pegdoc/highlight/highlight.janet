(import ./color :prefix "")
(import ./grammar :prefix "")
(import ./mono :prefix "")
(import ./rgb :prefix "")
(import ./theme :prefix "")

(def jg-capture-ast
  # jg is a struct, need something mutable
  (let [jca (table ;(kvs jg))]
    # override things that need to be captured
    (each kwd [:buffer :comment :constant :keyword :long-buffer
               :long-string :number :string :symbol :whitespace]
      (put jca kwd
               ~(cmt (capture ,(in jca kwd))
                     ,|[kwd $])))
    (each kwd [:fn :quasiquote :quote :splice :unquote]
      (put jca kwd
               ~(cmt (capture ,(in jca kwd))
                     ,|[kwd ;(slice $& 0 -2)])))
    (each kwd [:array :bracket-array :bracket-tuple :table :tuple :struct]
      (put jca kwd
           (tuple # array needs to be converted
                  ;(put (array ;(in jca kwd))
                        2 ~(cmt (capture ,(get-in jca [kwd 2]))
                                ,|[kwd ;(slice $& 0 -2)])))))
    # tried using a table with a peg but had a problem, so use a struct
    (table/to-struct jca)))

(comment

  (peg/match jg-capture-ast "")
  # =>
  nil

  (peg/match jg-capture-ast ".0")
  # =>
  @[[:number ".0"]]

  (peg/match jg-capture-ast "@\"i am a buffer\"")
  # =>
  @[[:buffer "@\"i am a buffer\""]]

  (peg/match jg-capture-ast "# hello")
  # =>
  @[[:comment "# hello"]]

  (peg/match jg-capture-ast ":a")
  # =>
  @[[:keyword ":a"]]

  (peg/match jg-capture-ast "@``i am a long buffer``")
  # =>
  @[[:long-buffer "@``i am a long buffer``"]]

  (peg/match jg-capture-ast "``hello``")
  # =>
  @[[:long-string "``hello``"]]

  (peg/match jg-capture-ast "\"\\u0001\"")
  # =>
  @[[:string "\"\\u0001\""]]

  (peg/match jg-capture-ast "|(+ $ 2)")
  # =>
  '@[(:fn
       (:tuple
         (:symbol "+") (:whitespace " ")
         (:symbol "$") (:whitespace " ")
         (:number "2")))]

  (peg/match jg-capture-ast "@{:a 1}")
  # =>
  '@[(:table
       (:keyword ":a") (:whitespace " ")
       (:number "1"))]

  )

(def jg-capture-top-level-ast
  # jg is a struct, need something mutable
  (let [jca (table ;(kvs jg-capture-ast))]
    (put jca
         :main ~(sequence :input (position)))
    # tried using a table with a peg but had a problem, so use a struct
    (table/to-struct jca)))

(defn par
  [src &opt start single]
  (default start 0)
  (if single
    (if-let [[tree position]
             (peg/match jg-capture-top-level-ast src start)]
      [@[:code tree] position]
      [@[:code] nil])
    (if-let [tree (peg/match jg-capture-ast src start)]
      (array/insert tree 0 :code)
      @[:code])))

(comment

  (par "(+ 1 1)")
  # =>
  '@[:code
     (:tuple
       (:symbol "+") (:whitespace " ")
       (:number "1") (:whitespace " ")
       (:number "1"))]

  )

(defn gen*
  [an-ast buf]
  (case (first an-ast)
    :code
    (each elt (drop 1 an-ast)
      (gen* elt buf))
    #
    :buffer
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :buffer)))
    :comment
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :comment)))
    :constant
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :constant)))
    :keyword
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :keyword)))
    :long-buffer
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :long-buffer)))
    :long-string
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :long-string)))
    :number
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :number)))
    :string
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :string)))
    :symbol
    (buffer/push-string buf ((dyn :pdoc-hl-str mono-str)
                              (in an-ast 1)
                              ((dyn :pdoc-theme mono-theme) :symbol)))
    :whitespace
    (buffer/push-string buf (in an-ast 1))
    #
    :array
    (do
      (buffer/push-string buf "@(")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf ")"))
    :bracket-array
    (do
      (buffer/push-string buf "@[")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "]"))
    :bracket-tuple
    (do
      (buffer/push-string buf "[")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "]"))
    :tuple
    (do
      (buffer/push-string buf "(")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf ")"))
    :struct
    (do
      (buffer/push-string buf "{")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "}"))
    :table
    (do
      (buffer/push-string buf "@{")
      (each elt (drop 1 an-ast)
        (gen* elt buf))
      (buffer/push-string buf "}"))
    #
    :fn
    (do
      (buffer/push-string buf "|")
      (each elt (drop 1 an-ast)
        (gen* elt buf)))
    :quasiquote
    (do
      (buffer/push-string buf "~")
      (each elt (drop 1 an-ast)
        (gen* elt buf)))
    :quote
    (do
      (buffer/push-string buf "'")
      (each elt (drop 1 an-ast)
        (gen* elt buf)))
    :splice
    (do
      (buffer/push-string buf ";")
      (each elt (drop 1 an-ast)
        (gen* elt buf)))
    :unquote
    (do
      (buffer/push-string buf ",")
      (each elt (drop 1 an-ast)
        (gen* elt buf)))
    ))

(defn gen
  [an-ast]
  (let [buf @""]
    (gen* an-ast buf)
    (string buf)))

(comment

  (gen
    [:code])
  # =>
  ""

  (gen
    [:code
     [:buffer "@\"buffer me\""]])
  # =>
  `@"buffer me"`

  (gen
    [:comment "# i am a comment"])
  # =>
  "# i am a comment"

  (gen
    [:long-string "```longish string```"])
  # =>
  "```longish string```"

  (gen
    '(:fn
       (:tuple
         (:symbol "-") (:whitespace " ")
         (:symbol "$") (:whitespace " ")
         (:number "8"))))
  # =>
  "|(- $ 8)"

  (gen
    '(:array
       (:keyword ":a") (:whitespace " ")
       (:keyword ":b")))
  # =
  "@(:a :b)"

  (gen
    '@(:struct
       (:keyword ":a") (:whitespace " ")
       (:number "1")))
  # =>
  "{:a 1}"

  )

(defn colorize
  [src]
  (gen (par src)))

(comment

  (def src "{:x  :y \n :z  [:a  :b    :c]}")

  (colorize src)

  (def src-2 "(peg/match ~(any \"a\") \"abc\")")

  (colorize src-2)

  )

