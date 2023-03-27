(import ./extract :as ex)
(import ./highlight :as hl)

# XXX: not sure if this quoting will work on windows...
(defn escape
  [a-str]
  (string "\""
          a-str
          "\""))

(defn all-names
  [names]
  # print all names
  (each name (sort names)
    # XXX: anything missing?
    # XXX: anything platform-specific?
    (if (get {"*" true
              "->" true
              ">" true
              "<-" true}
             name)
      (print (escape name))
      (print name))))

(defn doc
  [content]
  (def lines
    (string/split "\n" content))
  (when (empty? (array/peek lines))
    (array/pop lines))
  (each line lines
    (->> line
         (peg/match ~(sequence "# "
                               (capture (to -1))))
         first
         print)))

# assumes example file has certain structure
(defn massage-lines-for-examples
  [lines]
  (def n-lines (length lines))
  (def m-lines @[])
  (var i 0)
  # skip first line if import
  (when (peg/match ~(sequence "(import")
                   (first lines))
    (++ i))
  # get "inside" comment form
  (while (< i n-lines)
    (def cur-line (get lines i))
    # whether loop ends or not, index increases
    (++ i)
    # stop at first (comment ...) form
    (when (peg/match ~(sequence "(comment")
                     cur-line)
      (break)))
  # save lines until (comment ...) ends
  (while (< i n-lines)
    (def cur-line (get lines i))
    # supposedly where the "(comment ...)" form ends -- hacky
    (if (peg/match ~(sequence (any (set " \t\f\v"))
                              ")")
                   cur-line)
      (break)
      (if (string/has-prefix? "  " cur-line)
        (array/push m-lines (string/slice cur-line 2))
        (array/push m-lines cur-line)))
    (++ i))
  #
  m-lines)

(defn special-examples
  [content]
  (def lines
    (string/split "\n" content))
  (def examples-lines
    (massage-lines-for-examples lines))
  (-> (string/join examples-lines "\n")
      hl/highlight
      print))

# assumes example file has certain structure
(defn massage-lines-for-doc
  [lines]
  (def m-lines @[])
  (var i 0)
  # skip first line if import
  (when (peg/match ~(sequence "(import")
                   (first lines))
    (++ i))
  (while (< i (length lines))
    (def cur-line (get lines i))
    # stop at first (comment ...) form
    (if (peg/match ~(sequence "(comment")
                     cur-line)
      (break)
      (if (string/has-prefix? "# " cur-line)
        (array/push m-lines (string/slice cur-line 2))
        (array/push m-lines cur-line)))
    (++ i))
  #
  m-lines)

(defn special-doc
  [content]
  (def lines
    (string/split "\n" content))
  (def doc-lines
    (massage-lines-for-doc lines))
  (each line doc-lines
    (print line)))

(defn get-indent
  [a-str]
  (if-let [[indent]
           (peg/match ~(capture :s+) a-str)]
    indent
    ""))

(defn print-dedented
  [expr-str]
  (if-let [indent (get-indent expr-str)
           count (length indent)]
    (each line (string/split "\n" expr-str)
      (print (string/slice line count)))))

(defn special-quiz
  [content]
  (def tests
    (ex/extract-first-test-set content))
  (let [idx (math/rng-int (math/rng (os/cryptorand 3))
                          (length tests))
        [ques ans] (get tests idx)]
    (print-dedented (hl/highlight ques))
    (def buf @"")
    (print "# =>")
    (getline "" buf)
    (print)
    (print (string/repeat "#" (dyn :pdoc-width)))
    (print)
    (print "Answer is: ")
    (print)
    (print-dedented (hl/highlight ans))))

