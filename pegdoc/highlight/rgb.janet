# color names (except "none") from M-x list-colors-display

(def red
  [0xff 0x00 0x00])

(def dark-orange
  [0xff 0x8c 0x00])

(def yellow
  [0xff 0xff 0x00])

(def chartreuse
  [0x7f 0xff 0x00])

(def cyan
  [0x00 0xff 0xff])

(def blue
  [0x00 0x00 0xff])

(def purple
  [0xa0 0x20 0xf0])

(def magenta
  [0xff 0x00 0xff])

(def white
  [0xff 0xff 0xff])

(def none
  [nil nil nil])

(defn rgb-str
  [text [r g b]]
  (if (nil? r)
    text
    # https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
    # ESC[38;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB foreground color     # ] <- hack
    (string "\e[38;2;" r ";" g ";" b "m"
            text
            "\e[0m")))

(defn rgb-prin
  [msg [r g b]]
  (prin (rgb-str msg [r g b])))

(def rgb-separator-color
  blue)

