(def examples-table
  {"+" "choice"
   "*" "sequence"
   "opt" "between"
   "?" "between"
   "!" "not"
   ">" "look"
   "<-" "capture"
   "quote" "capture"
   "/" "replace"
   "$" "position"
   "%" "accumulate"
   "->" "backref"
   #
   "boolean" "0.boolean"
   "dictionary" "0.dictionary"
   "integer" "0.integer"
   "string" "0.string"
   "struct" "0.dictionary"
   "table" "0.dictionary"})

(defn get-filename
  [thing]
  (if-let [alias (get examples-table thing)]
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

(def examples-root
  "pegdoc/margaret/examples")

(defn get-filepath
  [filename]
  (def [file-path _]
    (module/find (string examples-root "/" filename)))
  file-path)

(defn all-example-file-names
  []
  (let [[file-path _]
        (module/find (string examples-root "/0.all-the-names"))]
    (when file-path
      (let [dir-path
            (string/slice file-path 0
                          (last (string/find-all "/" file-path)))]
        (unless (os/stat dir-path)
          (errorf "Unexpected directory non-existence:" dir-path))
        #
        (os/dir dir-path)))))

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
  (array/push names "boolean")
  (array/push names "dictionary")
  (array/push names "integer")
  (array/push names "string")
  (array/push names "struct")
  (array/push names "table")
  # add aliases
  (each alias (keys examples-table)
    (let [name (get examples-table alias)]
      (unless (string/has-prefix? "0." name)
        (when (index-of name names)
          (array/push names alias)))))
  #
  names)

(defn parse-all-the-names
  []
  (let [[file-path _]
        (module/find (string examples-root "/0.all-the-names"))]
    (when (and file-path
               (os/stat file-path))
      (def atn (slurp file-path))
      (def sections
        (filter |(pos? (length $)) (string/split "#\n" atn)))
      (def tbl @{})
      (each s sections
        (def pieces (string/split "\n#" s))
        (put tbl
             (string/slice (get pieces 0) 2)
             (map string/trim (array/slice pieces 1))))
      tbl)))
