(import ../janet-peg/bounds :prefix "")

(comment

  (peg/match bounds-grammar
             "    \n   ")
  # =>
  '@[(:whitespace "    " 1 1 1 5) (:whitespace "\n" 1 5 2 1)
     (:whitespace "   " 2 1 2 4)]

  (peg/match bounds-grammar "3.1415926535")
  # =>
  '@[(:number "3.1415926535" 1 1 1 13)]

  (peg/match bounds-grammar "8")
  # =>
  '@[(:number "8" 1 1 1 2)]

  (peg/match bounds-grammar "18")
  # =>
  '@[(:number "18" 1 1 1 3)]

  (peg/match bounds-grammar "print")
  # =>
  '@[(:symbol "print" 1 1 1 6)]

  (peg/match bounds-grammar "(+ 1 (* 8 3))")
  # =>
  '@[(:tuple
       (:symbol "+" 1 2 1 3) (:whitespace " " 1 3 1 4)
       (:number "1" 1 4 1 5) (:whitespace " " 1 5 1 6)
       (:tuple
         (:symbol "*" 1 7 1 8) (:whitespace " " 1 8 1 9)
         (:number "8" 1 9 1 10) (:whitespace " " 1 10 1 11)
         (:number "3" 1 11 1 12)
         1 6 1 13)
       1 1 1 14)]

  (peg/match bounds-grammar (string "(comment\n"
                                    "  8\n"
                                    "  )"))
  # =>
  '@[(:tuple
       (:symbol "comment" 1 2 1 9)
       (:whitespace "\n" 1 9 2 1)
       (:whitespace "  " 2 1 2 3) (:number "8" 2 3 2 4)
       (:whitespace "\n" 2 4 3 1)
       (:whitespace "  " 3 1 3 3)
       1 1 3 4)]

  (peg/match bounds-grammar "|(+ $ 2)")
  # =>
  '@[(:fn
       (:tuple
         (:symbol "+" 1 3 1 4) (:whitespace " " 1 4 1 5)
         (:symbol "$" 1 5 1 6) (:whitespace " " 1 6 1 7)
         (:number "2" 1 7 1 8)
         1 2 1 9)
       1 1 1 9)]

  (peg/match bounds-grammar "true")
  # =>
  '@[(:constant "true" 1 1 1 5)]

  (peg/match bounds-grammar "@[2 3 5]")
  # =>
  '@[(:bracket-array
       (:number "2" 1 3 1 4) (:whitespace " " 1 4 1 5)
       (:number "3" 1 5 1 6) (:whitespace " " 1 6 1 7)
       (:number "5" 1 7 1 8)
       1 1 1 9)]

  (peg/match bounds-grammar "'fun")
  # =>
  '@[(:quote (:symbol "fun" 1 2 1 5) 1 1 1 5)]

  (peg/match bounds-grammar `@"breathe"`)
  # =>
  '@[(:buffer "breathe" 1 1 1 11)]

  (peg/match bounds-grammar "@```breathe```")
  # =>
  '@[(:long-buffer "```breathe```" 1 1 1 15)]

  (peg/match bounds-grammar "@{:expr :smile\n:pose :sitting}")
  # =>
  '@[(:table
       (:keyword ":expr" 1 3 1 8) (:whitespace " " 1 8 1 9)
       (:keyword ":smile" 1 9 1 15) (:whitespace "\n" 1 15 2 1)
       (:keyword ":pose" 2 1 2 6) (:whitespace " " 2 6 2 7)
       (:keyword ":sitting" 2 7 2 15)
       1 1 2 16)]

  (peg/match bounds-grammar "@(:x :y :z)")
  # =>
  '@[(:array
       (:keyword ":x" 1 3 1 5) (:whitespace " " 1 5 1 6)
       (:keyword ":y" 1 6 1 8) (:whitespace " " 1 8 1 9)
       (:keyword ":z" 1 9 1 11)
       1 1 1 12)]

  (peg/match bounds-grammar "~{}")
  # =>
  '@[(:quasiquote (:struct 1 2 1 4) 1 1 1 4)]

  (peg/match bounds-grammar "[1 3 :eight]")
  # =>
  '@[(:bracket-tuple
       (:number "1" 1 2 1 3) (:whitespace " " 1 3 1 4)
       (:number "3" 1 4 1 5) (:whitespace " " 1 5 1 6)
       (:keyword ":eight" 1 6 1 12)
       1 1 1 13)]

  (peg/match bounds-grammar ";[1 2]")
  # =>
  '@[(:splice
       (:bracket-tuple
         (:number "1" 1 3 1 4) (:whitespace " " 1 4 1 5)
         (:number "2" 1 5 1 6)
         1 2 1 7)
       1 1 1 7)]

  )
