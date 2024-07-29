(import ../janet-peg/grammar :prefix "")

# jg
(comment

  (peg/match jg "nil")
  # =>
  @[]

  (peg/match jg ":a")
  # =>
  @[]

  (peg/match jg "@``i am a long buffer``")
  # =>
  @[]

  (peg/match jg "8")
  # =>
  @[]

  (peg/match jg "-2.0")
  # =>
  @[]

  (peg/match jg "\"\\u0001\"")
  # =>
  @[]

  (peg/match jg "a")
  # =>
  @[]

  (peg/match jg " ")
  # =>
  @[]

  (peg/match jg "~a")
  # =>
  @[]

  (peg/match jg "'a")
  # =>
  @[]

  (peg/match jg ";a")
  # =>
  @[]

  (peg/match jg ",a")
  # =>
  @[]

  (peg/match jg "@(:a)")
  # =>
  @[]

  (peg/match jg "@[:a]")
  # =>
  @[]

  (peg/match jg "[:a]")
  # =>
  @[]

  (peg/match jg "{:a 1}")
  # =>
  @[]

  (peg/match jg "(:a)")
  # =>
  @[]

  (peg/match jg "(def a 1)")
  # =>
  @[]

  )
