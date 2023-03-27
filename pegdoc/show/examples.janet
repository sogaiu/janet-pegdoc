(import ../highlight/highlight :as hl)

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
      hl/colorize
      print))

