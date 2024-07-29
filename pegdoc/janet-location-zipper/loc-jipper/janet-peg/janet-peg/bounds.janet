# bounds include start and end positions
#
# positions are represented as line and column (1-based)
#
# start position - "caret before character"
# end position   - "caret after character"

(def bounds-grammar
  ~{:main (some :input)
    #
    :input (choice :non-form
                   :form)
    #
    :non-form (choice :whitespace
                      :comment)
    #
    :whitespace
    (cmt (capture (sequence (line) (column)
                            (choice (some (set " \0\f\t\v"))
                                    (choice "\r\n"
                                            "\r"
                                            "\n"))
                            (line) (column)))
         ,|[:whitespace (last $&) ;(slice $& 0 -2)])
    #
    :comment
    (cmt (sequence (line) (column)
                   "#"
                   (capture (any (if-not (set "\r\n") 1)))
                   (line) (column))
         ,|[:comment
            $2
            $0 $1 $3 $4])
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
    :fn
    (cmt (capture (sequence (line) (column)
                            "|"
                            (any :non-form)
                            :form
                            (line) (column)))
         # $& is the remaining arguments
         ,|[:fn
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :quasiquote
    (cmt (capture (sequence (line) (column)
                            "~"
                            (any :non-form)
                            :form
                            (line) (column)))
         ,|[:quasiquote
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :quote
    (cmt (capture (sequence (line) (column)
                            "'"
                            (any :non-form)
                            :form
                            (line) (column)))
         ,|[:quote
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :splice
    (cmt (capture (sequence (line) (column)
                            ";"
                            (any :non-form)
                            :form
                            (line) (column)))
         ,|[:splice
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :unquote
    (cmt (capture (sequence (line) (column)
                            ","
                            (any :non-form)
                            :form
                            (line) (column)))
         ,|[:unquote
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
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
    :number
    (cmt (capture
           (sequence (line) (column)
                     (drop (sequence (cmt
                                       (capture (some :num-char))
                                       ,scan-number)
                                     (opt (sequence ":"
                                                    (range "AZ" "az")))))
                     (line) (column)))
         ,|[:number (last $&) ;(slice $& 0 -2)])
    #
    :num-char (choice (range "09" "AZ" "az")
                      (set "&+-._"))
    #
    :constant
    (cmt (capture (sequence (line) (column)
                            (choice "false" "nil" "true")
                            (line) (column)
                            (not :name-char)))
         ,|[:constant (last $&) ;(slice $& 0 -2)])
    #
    :name-char (choice (range "09" "AZ" "az" "\x80\xFF")
                       (set "!$%&*+-./:<?=>@^_"))
    #
    :buffer
    (cmt (sequence (line) (column)
                   `@"`
                   (capture
                     (any (choice :escape
                                  (if-not `"` 1))))
                   `"`
                   (line) (column))
         ,|[:buffer
            $2
            $0 $1 $3 $4])
    #
    :escape (sequence `\`
                      (choice (set `"'0?\abefnrtvz`)
                              (sequence "x" [2 :hex])
                              (sequence "u" [4 :hex])
                              (sequence "U" [6 :hex])
                              (error (constant "bad escape"))))
    #
    :hex (range "09" "af" "AF")
    #
    :string
    (cmt (sequence (line) (column)
                   `"`
                   (capture (any (choice :escape
                                         (if-not `"` 1))))
                   `"`
                   (line) (column))
         ,|[:string
            $2
            $0 $1 $3 $4])
    # XXX: includes delimiters in representation portion
    :long-string
    (cmt (capture (sequence (line) (column)
                            :long-bytes
                            (line) (column)))
         ,|[:long-string (last $&) ;(slice $& 0 -2)])
    #
    :long-bytes {:main (drop (sequence :open
                                       (any (if-not :close 1))
                                       :close))
                 :open (capture :delim :n)
                 :delim (some "`")
                 :close (cmt (sequence (not (look -1 "`"))
                                       (backref :n)
                                       (capture :delim))
                             ,=)}
    # XXX: includes delimiters in representation portion
    :long-buffer
    (cmt (sequence (line) (column)
                   "@"
                   (capture :long-bytes)
                   (line) (column))
         ,|[:long-buffer
            $2
            $0 $1 $3 $4])
    #
    :keyword
    (cmt (capture (sequence (line) (column)
                            ":"
                            (any :name-char)
                            (line) (column)))
         ,|[:keyword (last $&) ;(slice $& 0 -2)])
    #
    :symbol
    (cmt (capture (sequence (line) (column)
                            (some :name-char)
                            (line) (column)))
         ,|[:symbol (last $&) ;(slice $& 0 -2)])
    #
    :array
    (cmt (capture (sequence (line) (column)
                            "@("
                            (any :input)
                            (choice ")"
                                    (error (constant "missing )")))
                            (line) (column)))
        ,|[:array
           ;(slice $& 2 -4)
           ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :tuple
    (cmt (capture (sequence (line) (column)
                            "("
                            (any :input)
                            (choice ")"
                                    (error (constant "missing )")))
                            (line) (column)))
         ,|[:tuple
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :bracket-array
    (cmt (capture (sequence (line) (column)
                            "@["
                            (any :input)
                            (choice "]"
                                    (error (constant "missing ]")))
                            (line) (column)))
         ,|[:bracket-array
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :bracket-tuple
    (cmt (capture (sequence (line) (column)
                            "["
                            (any :input)
                            (choice "]"
                                    (error (constant "missing ]")))
                            (line) (column)))
         ,|[:bracket-tuple
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :table
    (cmt (capture (sequence (line) (column)
                            "@{"
                            (any :input)
                            (choice "}"
                                    (error (constant "missing }")))
                            (line) (column)))
         ,|[:table
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    #
    :struct
    (cmt (capture (sequence (line) (column)
                            "{"
                            (any :input)
                            (choice "}"
                                    (error (constant "missing }")))
                            (line) (column)))
         ,|[:struct
            ;(slice $& 2 -4)
            ;(slice $& 0 2) ;(slice $& -4 -2)])
    })

(comment

  (peg/match bounds-grammar "    ")
  # =>
  '@[(:whitespace "    " 1 1 1 5)]

  (peg/match bounds-grammar "(+ 1 1)")
  # =>
  '@[(:tuple
       (:symbol "+" 1 2 1 3) (:whitespace " " 1 3 1 4)
       (:number "1" 1 4 1 5) (:whitespace " " 1 5 1 6)
       (:number "1" 1 6 1 7)
       1 1 1 8)]

  (peg/match bounds-grammar "{:a 1 :b 2}")
  # =>
  '@[(:struct
       (:keyword ":a" 1 2 1 4) (:whitespace " " 1 4 1 5)
       (:number "1" 1 5 1 6) (:whitespace " " 1 6 1 7)
       (:keyword ":b" 1 7 1 9) (:whitespace " " 1 9 1 10)
       (:number "2" 1 10 1 11)
       1 1 1 12)]

  (peg/match bounds-grammar "``hello``")
  # =>
  '@[(:long-string "``hello``" 1 1 1 10)]

  (peg/match bounds-grammar `"hello"`)
  # =>
  '@[(:string "hello" 1 1 1 8)]

  (peg/match bounds-grammar "# nice comment")
  # =>
  '@[(:comment " nice comment" 1 1 1 15)]

  (peg/match bounds-grammar ":smile")
  # =>
  '@[(:keyword ":smile" 1 1 1 7)]

  (peg/match bounds-grammar "~,print")
  # =>
  '@[(:quasiquote
       (:unquote
         (:symbol "print" 1 3 1 8)
         1 2 1 8)
       1 1 1 8)]

  )
