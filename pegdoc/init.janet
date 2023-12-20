(import ./examples :as ex)
(import ./show/doc :as doc)
(import ./termsize :as t)

(defn pdoc*
  [&opt sym]
  # XXX: almost duplicate code in main.janet
  (defn thing-content
    [thing]
    (def special-fname
      (if-let [alias (get ex/examples-table thing)]
        alias
        (let [the-type
              (type (try (parse thing) ([e] nil)))]
          (cond
            (= :boolean the-type)
            "0.boolean"
            #
            (or (= :struct the-type)
                (= :table the-type))
            "0.struct"
            #
            (try (scan-number thing) ([e] nil))
            "0.integer"
            #
            thing))))
    (def [file-path _]
      (module/find (string "pegdoc/examples/" special-fname)))
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
