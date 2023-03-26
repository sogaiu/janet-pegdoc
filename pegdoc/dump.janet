(import ./alias :as al)
(import ./extract :as ex)

(defn all-names
  [file-names]
  (def names
    (->> file-names
         # drop .janet extension
         (map |(string/slice $ 0
                             (last (string/find-all "." $))))
         # only keep things that have names
         (filter |(not (string/has-prefix? "0." $)))))
  # add things with no names
  (array/push names "integer")
  (array/push names "string")
  (array/push names "struct")
  (each alias (keys al/alias-table)
    (let [name (get al/alias-table alias)]
      (unless (string/has-prefix? "0." name)
        (when (index-of name names)
          (array/push names alias)))))
  # print all names
  (each name (sort names)
    (cond
      (= name "*")
      # XXX: not sure if this quoting will work on windows...
      (print "\"*\"")
      #
      (= name "->")
      (print "\"->\"")
      #
      (= name ">")
      (print "\">\"")
      #
      (= name "<-")
      (print "\"<-\"")
      #
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
  (each line examples-lines
    (print line)))

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

# XXX: see extract.janet comment for reason for
#      odd indentation
(defn print-work-around
  [extracted]
  (def lines
    (string/split "\n" extracted))
  (print (get lines 0))
  (array/remove lines 0)
  (each line lines
    # XXX: could this be wrong sometimes?
    #      should only do if starts with 2 or more spaces?
    (print (string/slice line 2))))

(defn special-quiz
  [content]
  (def tests
    (ex/extract-first-test-set content))
  (let [idx (math/rng-int (math/rng (os/cryptorand 3))
                          (length tests))
        [ques ans] (get tests idx)]
    (print-work-around ques)
    (def buf @"")
    (print "# =>")
    (getline "" buf)
    (print)
    (print "Answer is: " ans)))

