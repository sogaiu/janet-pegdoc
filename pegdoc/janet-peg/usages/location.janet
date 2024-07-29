(import ../janet-peg/location :prefix "")

# loc-grammar
(comment

  (get (peg/match loc-grammar "true") 2)
  # =>
  '(:constant @{:bc 1 :bl 1 :ec 5 :el 1} "true")

  (get (peg/match loc-grammar "(+ 1 1)") 2)
  # =>
  '(:tuple @{:bc 1 :bl 1
             :ec 8 :el 1}
           (:symbol @{:bc 2 :bl 1
                      :ec 3 :el 1} "+")
           (:whitespace @{:bc 3 :bl 1
                          :ec 4 :el 1} " ")
           (:number @{:bc 4 :bl 1
                      :ec 5 :el 1} "1")
           (:whitespace @{:bc 5 :bl 1
                          :ec 6 :el 1} " ")
           (:number @{:bc 6 :bl 1
                      :ec 7 :el 1} "1"))

  (get (peg/match loc-grammar "|(+ $ 1)") 2)
  # =>
  '(:fn @{:bc 1 :bl 1
          :ec 9 :el 1}
        (:tuple @{:bc 2 :bl 1
                  :ec 9 :el 1}
                (:symbol @{:bc 3 :bl 1
                           :ec 4 :el 1} "+")
                (:whitespace @{:bc 4 :bl 1
                               :ec 5 :el 1} " ")
                (:symbol @{:bc 5 :bl 1
                           :ec 6 :el 1} "$")
                (:whitespace @{:bc 6 :bl 1
                               :ec 7 :el 1} " ")
                (:number @{:bc 7 :bl 1
                           :ec 8 :el 1} "1")))

  (get (peg/match loc-grammar "@(1 2)") 2)
  # =>
  '(:array @{:bc 1 :bl 1
             :ec 7 :el 1}
           (:number @{:bc 3 :bl 1
                      :ec 4 :el 1} "1")
           (:whitespace @{:bc 4 :bl 1
                          :ec 5 :el 1} " ")
           (:number @{:bc 5 :bl 1
                      :ec 6 :el 1} "2"))

  (get (peg/match loc-grammar "{:x :y}") 2)
  # =>
  '(:struct @{:bc 1 :bl 1
              :ec 8 :el 1}
            (:keyword @{:bc 2 :bl 1
                        :ec 4 :el 1} ":x")
            (:whitespace @{:bc 4 :bl 1
                           :ec 5 :el 1} " ")
            (:keyword @{:bc 5 :bl 1
                        :ec 7 :el 1} ":y"))

  (get (peg/match loc-grammar "'z") 2)
  # =>
  '(:quote @{:bc 1 :bl 1
             :ec 3 :el 1}
           (:symbol @{:bc 2 :bl 1
                      :ec 3 :el 1} "z"))

  (get (peg/match loc-grammar ";w") 2)
  # =>
  '(:splice @{:bc 1 :bl 1
              :ec 3 :el 1}
            (:symbol @{:bc 2 :bl 1
                       :ec 3 :el 1} "w"))

  (get (peg/match loc-grammar ",a") 2)
  # =>
  '(:unquote @{:bc 1 :bl 1
               :ec 3 :el 1}
             (:symbol @{:bc 2 :bl 1
                        :ec 3 :el 1} "a"))

  )

# gen
(comment

  (gen
    '(:comment @{:bc 1 :bl 1
                 :ec 11 :el 1} "# hi there"))
  # =>
  "# hi there"

  (gen
    '(:number @{:bc 1 :bl 1
                :ec 4 :el 1} "8.3"))
  # =>
  "8.3"

  (gen
    '(:symbol @{:bc 1 :bl 1
                :ec 7 :el 1} "printf"))
  # =>
  "printf"

  (gen
    '(:keyword @{:bc 1 :bl 1
                 :ec 7 :el 1} ":smile"))
  # =>
  ":smile"

  (gen
    '(:string @{:bc 1 :bl 1
                :ec 6 :el 1} "\"fun\""))
  # =>
  `"fun"`

  (gen
    '(:long-string @{:bc 1 :bl 1
                     :ec 13 :el 1} "``long-fun``"))
  # =>
  "``long-fun``"

  (gen
    '(:long-buffer @{:bc 1 :bl 1
                     :ec 21 :el 1} "@``long-buffer-fun``"))
  # =>
  "@``long-buffer-fun``"

  (gen
    '(:quasiquote @{:bc 1 :bl 1
                    :ec 3 :el 1}
                  (:symbol @{:bc 2 :bl 1
                             :ec 3 :el 1} "x")))
  # =>
  "~x"

  )
