(def jg
  ~@{:main (some :input)
     #
     :input (choice :non-form
                    :form)
     #
     :non-form (choice :whitespace
                       :comment)
     #
     :whitespace (choice (some (set " \0\f\t\v"))
                         (choice "\r\n"
                                 "\r"
                                 "\n"))
     #
     :comment (sequence "#"
                        (any (if-not (set "\r\n") 1)))
     #
     :form (choice :reader-macro
                   :collection
                   :literal)
     #
     :reader-macro (choice :fn
                           :quasiquote
                           :quote
                           :splice
                           :unquote)
     #
     :fn (sequence "|"
                   (any :non-form)
                   :form)
     #
     :quasiquote (sequence "~"
                           (any :non-form)
                           :form)
     #
     :quote (sequence "'"
                      (any :non-form)
                      :form)
     #
     :splice (sequence ";"
                       (any :non-form)
                       :form)
     #
     :unquote (sequence ","
                        (any :non-form)
                        :form)
     #
     :literal (choice :number
                      :constant
                      :buffer
                      :string
                      :long-buffer
                      :long-string
                      :keyword
                      :symbol)
     #
     :collection (choice :array
                         :bracket-array
                         :tuple
                         :bracket-tuple
                         :table
                         :struct)
     #
     :number (drop (sequence (cmt (capture (some :num-char))
                                  ,scan-number)
                             (opt (sequence ":" (range "AZ" "az")))))
     #
     :num-char (choice (range "09" "AZ" "az")
                       (set "&+-._"))
     #
     :constant (sequence (choice "false" "nil" "true")
                         (not :name-char))
     #
     :name-char (choice (range "09" "AZ" "az" "\x80\xFF")
                        (set "!$%&*+-./:<?=>@^_"))
     #
     :buffer (sequence `@"`
                       (any (choice :escape
                                    (if-not `"` 1)))
                       `"`)
     #
     :escape (sequence `\`
                       (choice (set `"'0?\abefnrtvz`)
                               (sequence "x" [2 :h])
                               (sequence "u" [4 :h])
                               (sequence "U" [6 :h])
                               (error (constant "bad escape"))))
     #
     :string (sequence `"`
                       (any (choice :escape
                                    (if-not `"` 1)))
                       `"`)
     #
     :long-string :long-bytes
     #
     :long-bytes {:main (drop (sequence :open
                                        (any (if-not :close 1))
                                        :close))
                  :open (capture :delim :n)
                  :delim (some "`")
                  :close (cmt (sequence (not (look -1 "`"))
                                        (backref :n)
                                        (capture (backmatch :n)))
                              ,=)}
     #
     :long-buffer (sequence "@"
                            :long-bytes)
     #
     :keyword (sequence ":"
                        (any :name-char))
     #
     :symbol (some :name-char)
     #
     :array (sequence "@("
                      (any :input)
                      (choice ")"
                              (error (constant "missing )"))))
     #
     :tuple (sequence "("
                      (any :input)
                      (choice ")"
                              (error (constant "missing )"))))
     #
     :bracket-array (sequence "@["
                              (any :input)
                              (choice "]"
                                      (error (constant "missing ]"))))
     #
     :bracket-tuple (sequence "["
                              (any :input)
                              (choice "]"
                                      (error (constant "missing ]"))))
     :table (sequence "@{"
                      (any :input)
                      (choice "}"
                              (error (constant "missing }"))))
     #
     :struct (sequence "{"
                       (any :input)
                       (choice "}"
                               (error (constant "missing }"))))
     })

(comment

  (peg/match jg "")
  # =>
  nil

  (peg/match jg "11")
  # =>
  @[]

  (peg/match jg "0xff")
  # =>
  @[]

  (peg/match jg "1:u")
  # =>
  @[]

  (peg/match jg "-2:s")
  # =>
  @[]

  (peg/match jg "1e2:n")
  # =>
  @[]

  (peg/match jg "0x2.8FaP11")
  # =>
  @[]

  (peg/match jg "@\"i am a buffer\"")
  # =>
  @[]

  (peg/match jg "# hello")
  # =>
  @[]

  (peg/match jg "``hello``")
  # =>
  @[]

  (peg/match jg "|(+ $ 2)")
  # =>
  @[]

  (peg/match jg "[1 2]")
  # =>
  @[]

  (peg/match jg "@{:a 1}")
  # =>
  @[]

  (peg/match jg "[:a :b] 1")
  # =>
  @[]

  (try
    (peg/match jg "[:a :b)")
    ([e] e))
  # =>
  "missing ]"

  (try
    (peg/match jg "(def a # hi 1)")
    ([e] e))
  # =>
  "missing )"

  (try
    (peg/match jg "\"\\u001\"")
    ([e] e))
  # =>
  "bad escape"

  )
