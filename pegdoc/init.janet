(import ./examples :as ex)
(import ./doc)
(import ./termsize :as t)

(defn pdoc*
  [&opt sym]
  (def indent 4)
  (defn print-index
    []
    (def atn-table (ex/parse-all-the-names))
    (print)
    (each sname ["Primitive Patterns" "Combining Patterns" "Captures"]
      (print
        (doc-format
          (string sname ":\n\n"
                  "* " (string/join (get atn-table sname) "\n* "))
          nil nil false)))
    (print "\n"
           (string/repeat " " indent)
           "Use (pdoc sym) for more information.\n"))
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
    (symbol? sym)
    (do
      (def content (thing-content (string sym)))
      (when (not content)
        (print "\n\n"
               (string/repeat " " indent)
               "no documentation found.\n"
               "\n")
        (break))
      (def width (+ 8 (t/cols)))
      (print "\n\n"
             (string/repeat " " indent)
             "peg special")
      (print (doc/special-doc content width indent)))
    # XXX
    (string? sym)
    (print "Not implemented yet.")
    #
    (print "\n\n"
           (string/repeat " " indent)
           (string/format "unexpected type %n for %n.\n"
                          (type sym) sym)
           "\n")))

(defmacro pdoc
  [&opt sym]
  ~(,pdoc* ',sym))
