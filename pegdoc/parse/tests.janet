(import ../janet-peg/janet-peg/location :as l)
(import ./zipper :as j)
(import ../janet-location-zipper/loc-jipper :as j)

# ti == test indicator, which can look like any of:
#
# # =>
# # before =>
# # => after
# # before => after

(defn find-test-indicator
  [zloc]
  (var label-left nil)
  (var label-right nil)
  [(j/right-until zloc
                  |(match (j/node $)
                     [:comment _ content]
                     (if-let [[l r]
                              (peg/match ~(sequence "#"
                                                    (capture (to "=>"))
                                                    "=>"
                                                    (capture (thru -1)))
                                         content)]
                       (do
                         (set label-left (string/trim l))
                         (set label-right (string/trim r))
                         true)
                       false)))
   label-left
   label-right])

(comment

  (def src
    ``
    (+ 1 1)
    # =>
    2
    ``)

  (let [[zloc l r]
        (find-test-indicator (-> (l/par src)
                                 j/zip-down))]
    (and zloc
         (empty? l)
         (empty? r)))
  # =>
  true

  (def src
    ``
    (+ 1 1)
    # before =>
    2
    ``)

  (let [[zloc l r]
        (find-test-indicator (-> (l/par src)
                                 j/zip-down))]
    (and zloc
         (= "before" l)
         (empty? r)))
  # =>
  true

  (def src
    ``
    (+ 1 1)
    # => after
    2
    ``)

  (let [[zloc l r]
        (find-test-indicator (-> (l/par src)
                                 j/zip-down))]
    (and zloc
         (empty? l)
         (= "after" r)))
  # =>
  true

  )

(defn find-test-expr
  [ti-zloc]
  # check for appropriate conditions "before"
  (def before-zlocs @[])
  (var curr-zloc ti-zloc)
  (var found-before nil)
  (while curr-zloc
    (set curr-zloc
         (j/left curr-zloc))
    (when (nil? curr-zloc)
      (break))
    (match (j/node curr-zloc)
      [:comment]
      (array/push before-zlocs curr-zloc)
      #
      [:whitespace]
      (array/push before-zlocs curr-zloc)
      #
      (do
        (set found-before true)
        (array/push before-zlocs curr-zloc)
        (break))))
  #
  (cond
    (nil? curr-zloc)
    :no-test-expression
    #
    (and found-before
         (->> (slice before-zlocs 0 -2)
              (filter |(not (match (j/node $)
                              [:whitespace]
                              true)))
              length
              zero?))
    curr-zloc
    #
    :unexpected-result))

(comment

  (def src
    ``
    (comment

      (def a 1)

      (put @{} :a 2)
      # =>
      @{:a 2}

      )
    ``)

  (def [ti-zloc _ _]
    (find-test-indicator (-> (l/par src)
                             j/zip-down
                             j/down)))

  (j/node ti-zloc)
  # =>
  '(:comment @{:bc 3 :bl 6 :ec 7 :el 6} "# =>")

  (def test-expr-zloc
    (find-test-expr ti-zloc))

  (j/node test-expr-zloc)
  # =>
  '(:tuple @{:bc 3 :bl 5 :ec 17 :el 5}
           (:symbol @{:bc 4 :bl 5 :ec 7 :el 5} "put")
           (:whitespace @{:bc 7 :bl 5 :ec 8 :el 5} " ")
           (:table @{:bc 8 :bl 5 :ec 11 :el 5})
           (:whitespace @{:bc 11 :bl 5 :ec 12 :el 5} " ")
           (:keyword @{:bc 12 :bl 5 :ec 14 :el 5} ":a")
           (:whitespace @{:bc 14 :bl 5 :ec 15 :el 5} " ")
           (:number @{:bc 15 :bl 5 :ec 16 :el 5} "2"))

  (-> (j/left test-expr-zloc)
      j/node)
  # =>
  '(:whitespace @{:bc 1 :bl 5 :ec 3 :el 5} "  ")

  )

(defn find-expected-expr
  [ti-zloc]
  (def after-zlocs @[])
  (var curr-zloc ti-zloc)
  (var found-comment nil)
  (var found-after nil)
  #
  (while curr-zloc
    (set curr-zloc
         (j/right curr-zloc))
    (when (nil? curr-zloc)
      (break))
    (match (j/node curr-zloc)
      [:comment]
      (do
        (set found-comment true)
        (break))
      #
      [:whitespace]
      (array/push after-zlocs curr-zloc)
      #
      (do
        (set found-after true)
        (array/push after-zlocs curr-zloc)
        (break))))
  #
  (cond
    (or (nil? curr-zloc)
        found-comment)
    :no-expected-expression
    #
    (and found-after
         (match (j/node (first after-zlocs))
           [:whitespace _ "\n"]
           true))
    (if-let [from-next-line (drop 1 after-zlocs)
             next-line (take-until |(match (j/node $)
                                      [:whitespace _ "\n"]
                                      true)
                                   from-next-line)
             target (->> next-line
                         (filter |(match (j/node $)
                                    [:whitespace]
                                    false
                                    #
                                    true))
                         first)]
      target
      :no-expected-expression)
    #
    :unexpected-result))

(comment

  (def src
    ``
    (comment

      (def a 1)

      (put @{} :a 2)
      # =>
      @{:a 2}

      )
    ``)

  (def [ti-zloc _ _]
    (find-test-indicator (-> (l/par src)
                             j/zip-down
                             j/down)))

  (j/node ti-zloc)
  # =>
  '(:comment @{:bc 3 :bl 6 :ec 7 :el 6} "# =>")

  (def expected-expr-zloc
    (find-expected-expr ti-zloc))

  (j/node expected-expr-zloc)
  # =>
  '(:table @{:bc 3 :bl 7 :ec 10 :el 7}
           (:keyword @{:bc 5 :bl 7 :ec 7 :el 7} ":a")
           (:whitespace @{:bc 7 :bl 7 :ec 8 :el 7} " ")
           (:number @{:bc 8 :bl 7 :ec 9 :el 7} "2"))

  (-> (j/left expected-expr-zloc)
      j/node)
  # =>
  '(:whitespace @{:bc 1 :bl 7 :ec 3 :el 7} "  ")

  (def src
    ``
    (comment

      (butlast @[:a :b :c])
      # => @[:a :b]

      (butlast [:a])
      # => []

    )
    ``)

  (def [ti-zloc _ _]
    (find-test-indicator (-> (l/par src)
                             j/zip-down
                             j/down)))

  (j/node ti-zloc)
  # =>
  '(:comment @{:bc 3 :bl 4 :ec 16 :el 4} "# => @[:a :b]")

  (find-expected-expr ti-zloc)
  # =>
  :no-expected-expression

  )

(defn find-test-exprs
  [ti-zloc]
  # look for a test expression
  (def test-expr-zloc
    (find-test-expr ti-zloc))
  (case test-expr-zloc
    :no-test-expression
    (break [nil nil])
    #
    :unexpected-result
    (errorf "unexpected result from `find-test-expr`: %p"
            test-expr-zloc))
  # look for an expected value expression
  (def expected-expr-zloc
    (find-expected-expr ti-zloc))
  (case expected-expr-zloc
    :no-expected-expression
    (break [test-expr-zloc nil])
    #
    :unexpected-result
    (errorf "unexpected result from `find-expected-expr`: %p"
            expected-expr-zloc))
  #
  [test-expr-zloc expected-expr-zloc])

(defn extract-tests-from-comment-zloc
  [comment-zloc]
  # move into comment block
  (var curr-zloc (j/down comment-zloc))
  (def tests @[])
  # process comment block content
  (while (not (j/end? curr-zloc))
    (def [ti-zloc label-left label-right]
      (find-test-indicator curr-zloc))
    (unless ti-zloc
      (break))
    (def [test-expr-zloc expected-expr-zloc]
      (find-test-exprs ti-zloc))
    # found a complete test
    (if (and test-expr-zloc
             expected-expr-zloc)
      (do
        (array/push tests [test-expr-zloc
                           expected-expr-zloc])
        (set curr-zloc
             (j/right expected-expr-zloc)))
      (set curr-zloc
           (j/right curr-zloc))))
  #
  tests)

(comment

  (def src
    ``
    (comment

      (def a 1)

      (put @{} :a 2)
      # left =>
      @{:a 2}

      (+ 1 1)
      # => right
      2

      )
    ``)

  (def tests
    (-> (l/par src)
        j/zip-down
        extract-tests-from-comment-zloc))

  (l/gen (j/node (get-in tests [0 0])))
  # =>
  "(put @{} :a 2)"

  (l/gen (j/node (get-in tests [0 1])))
  # =>
  "@{:a 2}"

  (l/gen (j/node (get-in tests [1 0])))
  # =>
  "(+ 1 1)"

  (l/gen (j/node (get-in tests [1 1])))
  # =>
  "2"

  )

(defn extract-test-zlocs
  [src]
  (var tests @[])
  (var curr-zloc
    (-> (l/par src)
        j/zip-down
        # XXX: leading newline is a hack to prevent very first thing
        #      from being a comment block
        (j/insert-left [:whitespace @{} "\n"])
        # XXX: once the newline is inserted, need to move to it
        j/left))
  #
  (while (not (j/end? curr-zloc))
    # try to find a top-level comment block
    (if-let [comment-zloc
             (j/right-until curr-zloc
                            |(match (j/node $)
                               [:tuple _ [:symbol _ "comment"]]
                               true))]
      (do
        (let [results (extract-tests-from-comment-zloc comment-zloc)]
          (unless (empty? results)
            (array/push tests ;results))
          (set curr-zloc comment-zloc)))
      (break)))
  #
  tests)

(comment

  (def src
    ``
    (comment

      (def a 1)

      (put @{}
           :a 2)
      # left =>
      @{:a 2}

      (+ 1 1)
      # => right
      2

      )

    (comment

      (string/slice "hallo" 1)
      # =>
      "allo"

      )
    ``)

  (def test-zlocs
    (extract-test-zlocs src))

  # XXX: the indentation for all lines after the first one is off by 2
  #      because all lines are indented by 2 within the comment form.
  #      the first part of the test (on the first line) is not
  #      indented because the first non-whitespace character is
  #      what is identified as the starting position
  (l/gen (j/node (get-in test-zlocs [0 0])))
  # =>
  ``
  (put @{}
         :a 2)
  ``

  (l/gen (j/node (get-in test-zlocs [0 1])))
  # =>
  "@{:a 2}"

  (l/gen (j/node (get-in test-zlocs [2 0])))
  # =>
  "(string/slice \"hallo\" 1)"

  (l/gen (j/node (get-in test-zlocs [2 1])))
  # =>
  "\"allo\""

  )

# XXX: not perfect, but mostly ok?
(defn get-indentation
  [a-zloc]
  (when-let [left-zloc (j/left a-zloc)]
    (let [[the-type _ content] (j/node left-zloc)]
      (when (= :whitespace the-type)
        # found indentation
        (when (empty? (string/trim content))
          # early return
          (break content)))))
  # no indentation
  "")

(comment

  (def src
    ``
    (comment

      (def a 1)

      (put @{} :a 2)
      # =>
      @{:a 2}

      )
    ``)

  (def [ti-zloc _ _]
    (find-test-indicator (-> (l/par src)
                             j/zip-down
                             j/down)))

  (get-indentation (find-test-expr ti-zloc))
  # =>
  "  "

  )

(defn indent-node-gen
  [a-zloc]
  (string (get-indentation a-zloc) (l/gen (j/node a-zloc))))

(defn extract-tests
  [src]
  (def test-zlocs
    (extract-test-zlocs src))
  (map |(let [[t-zloc e-zloc] $]
          [(indent-node-gen t-zloc)
           (indent-node-gen e-zloc)])
       test-zlocs))

# only operate on first comment form
(defn extract-first-test-set-zlocs
  [src]
  (var tests @[])
  (var curr-zloc
    (-> (l/par src)
        j/zip-down
        # XXX: leading newline is a hack to prevent very first thing
        #      from being a comment block
        (j/insert-left [:whitespace @{} "\n"])
        # XXX: once the newline is inserted, need to move to it
        j/left))
  #
  (while (not (j/end? curr-zloc))
    # try to find a top-level comment block
    (if-let [comment-zloc
             (j/right-until curr-zloc
                            |(match (j/node $)
                               [:tuple _ [:symbol _ "comment"]]
                               true))]
      (do
        (let [results (extract-tests-from-comment-zloc comment-zloc)]
          (unless (empty? results)
            (array/push tests ;results))
          (break)))
      (break)))
  #
  tests)

# only operate on first comment form
(defn extract-first-test-set
  [src]
  (def test-zlocs
    (extract-first-test-set-zlocs src))
  (map |(let [[t-zloc e-zloc] $]
          [(indent-node-gen t-zloc)
           (indent-node-gen e-zloc)])
       test-zlocs))

