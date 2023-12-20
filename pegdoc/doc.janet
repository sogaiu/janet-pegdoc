(import ./termsize :as t)

(defn normal-doc
  [content]
  (def lines
    (string/split "\n" content))
  (when (empty? (array/peek lines))
    (array/pop lines))
  (def doc-lines
    (keep |(or (first
                 (peg/match ~(sequence "# " (capture (to -1)))
                            $))
               "")
          lines))
  (string/join doc-lines "\n"))

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
  [content &opt width indent]
  (default width (+ 8 (dyn :pdoc-width (t/cols))))
  (default indent 0)
  (def lines
    (string/split "\n" content))
  (def doc-lines
    (massage-lines-for-doc lines))
  # XXX: issue with doc-format?
  #      width doesn't seem to work as-is as a value very well
  (doc-format (string/join doc-lines "\n") width indent))

