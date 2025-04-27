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

# hexadecimal exponential notation
(comment

  (peg/match jg "0x1.3DEp42")
  # =>
  @[]

  (peg/match jg "0x1p2")
  # =>
  @[]

  (peg/match jg "0x1p+1")
  # =>
  @[]

  (peg/match jg "0x2p-1")
  # =>
  @[]

  (peg/match jg "-0x1_1.0p1")
  # =>
  @[]

  (peg/match jg "0x1_1.0_0P11")
  # =>
  @[]

  (peg/match jg "+0x1.0000000000000p+0000")
  # =>
  @[]

  (peg/match jg "+0x0.0000000000000p+0000")
  # =>
  @[]

  (peg/match jg "-0x0.0000000000000p+0000")
  # =>
  @[]

  (peg/match jg "+0x1.5555555555555p-0002")
  # =>
  @[]

  (peg/match jg "-0x1.2492492492492p-0001")
  # =>
  @[]

  (peg/match jg "+0x1.999999999999ap-0004")
  # =>
  @[]

  (peg/match jg "+0x1.9e3779b97f4a8p+0000")
  # =>
  @[]

  (peg/match jg "+0x1.6a09e667f3bcdp-0001")
  # =>
  @[]

  (peg/match jg "+0x1.921fb54442d18p+0001")
  # =>
  @[]

  (peg/match jg "+0x1.5bf0a8b145769p+0001")
  # =>
  @[]

  (peg/match jg "+0x1.62e42fefa39efp-0001")
  # =>
  @[]

  (peg/match jg "+0x1.71547652b82fep+0000")
  # =>
  @[]

  (peg/match jg "+0x1.0000000000000p-0052")
  # =>
  @[]

  (peg/match jg "+0x1.0000000000000p-1074")
  # =>
  @[]

  (peg/match jg "+0x1.fffffffffffffp+1023")
  # =>
  @[]

  (peg/match jg "-0x1.fffffffffffffp+0052")
  # =>
  @[]

  (peg/match jg "+0x1.fffffffffffffp+0052")
  # =>
  @[]

  )

