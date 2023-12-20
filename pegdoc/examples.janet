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

(defn all-example-file-names
  []
  (let [[file-path _]
        (module/find "pegdoc/examples/0.all-the-names")]
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
