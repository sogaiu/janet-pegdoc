(import ./examples :as ex)
(import ./doc)
(import ./termsize :as t)

(defn pdoc*
  [&opt sym]
  (def indent 4)
  (def indent-str (string/repeat " " indent))
  (defn not-found
    [&opt sym]
    (string indent-str
            "Did not find anything"
            (when sym (string/format " for '%s'" sym))
            ".\n"))
  (defn print-index
    [&opt fltr]
    (default fltr identity)
    (def atn-table (ex/parse-all-the-names))
    (print)
    (var found nil)
    (each sname ["Primitive Patterns" "Combining Patterns" "Captures"]
      (def items (->> (get atn-table sname)
                      (filter fltr)))
      (when (not (empty? items))
        (set found true)
        (print
          (doc-format
            (string sname ":\n\n"
                    "* "
                    (string/join items "\n* "))
            nil nil false))))
    (if found
      (print "\n"
             indent-str
             "Use (pdoc sym) for more information.\n")
      (print "\n"
             (not-found))))
  (defn thing-content
    [thing]
    (def special-fname (ex/get-filename thing))
    (def file-path (ex/get-filepath special-fname))
    (when (and file-path
               (os/stat file-path))
      # XXX: could check for failure here
      (slurp file-path)))
  #
  (cond
    (nil? sym)
    (print-index)
    #
    (string? sym)
    (print-index |(string/find sym $))
    #
    (int? sym)
    (if (not (neg? sym))
      (print-index |(string/find "0" $))
      (print-index |(string/find "-1" $)))
    #
    (keyword? sym)
    (if-let [patt (get default-peg-grammar sym)]
      (print "\n\n"
             indent-str
             "peg special"
             "\n\n"
             indent-str
             (string ":" sym)
             "\n\n"
             indent-str
             (string/format "%n" patt))
      (print "\n\n"
             (not-found (string ":" sym))))
    #
    (or (symbol? sym) (boolean? sym))
    (do
      (def content (thing-content (string/ascii-lower (string sym))))
      (when (not content)
        (print "\n\n"
               (not-found sym))
        (break))
      (def cols
        (if-let [cols (t/cols)]
          cols
          80))
      (def width (+ 8 cols))
      (print "\n\n"
             indent-str
             "peg special")
      (print (doc/special-doc content width indent)))
    #
    (print "\n\n"
           (not-found sym))))

(defmacro pdoc
  ``
  Shows documentation for the given peg special symbol, or can show a
  list of peg specials.

  If `sym` is a symbol, will look for documentation for that
  symbol. If `sym` is a string or is not provided, will show all peg
  special patterns containing that string (all peg specials will be
  shown if no string is given).
  ``
  [&opt sym]
  ~(,pdoc* ',sym))
