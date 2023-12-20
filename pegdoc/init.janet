(import ./examples :as ex)
(import ./show/doc :as doc)
(import ./termsize :as t)

(defn pdoc*
  [&opt sym]
  (defn thing-content
    [thing]
    (def special-fname (ex/get-filename thing))
    (def file-path (ex/get-filepath special-fname))
    (when (and file-path
               (os/stat file-path))
      # XXX: could check for failure here
      (slurp file-path)))

  (def content
    (thing-content (string sym)))

  (def indent 4)

  (unless content
    (print "\n\n"
           (string/repeat " " indent)
           "no documentation found.\n"
           "\n")
    (break))

  (def width (+ 8 (t/cols)))

  (print "\n\n"
         (string/repeat " " indent)
         "peg special")

  (doc/special-doc content width indent))

(defmacro pdoc
  [&opt sym]
  ~(,pdoc* ',sym))
