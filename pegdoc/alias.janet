(def alias-table
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
   "integer" "0.integer"
   "string" "0.string"
   "struct" "0.struct"})

