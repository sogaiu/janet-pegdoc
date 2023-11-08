(import ../highlight/highlight :as hl)

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

(defn normal-doc
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
  # XXX: issue with doc-format?
  #      width doesn't seem to work as-is as a value very well
  (print (doc-format (string/join doc-lines "\n")
                     (+ 8 (dyn :pdoc-width))
                     0)))

