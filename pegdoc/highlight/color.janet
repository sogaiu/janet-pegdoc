(def red
  :red)

(def yellow
  :yellow)

(def green
  :green)

(def blue
  :blue)

(def cyan
  :cyan)

(def magenta
  :magenta)

(def white
  :white)

(def black
  :black)

(def none
  nil)

(defn color-str
  [msg color]
  (if color
    (let [color-num (match color
                      :black 30
                      :blue 34
                      :cyan 36
                      :green 32
                      :magenta 35
                      :red 31
                      :white 37
                      :yellow 33)]
      (string "\e[" color-num "m"
              msg
              "\e[0m"))
    msg))

(defn color-prin
  [msg color]
  (prin (color-str msg color)))

(def color-separator-color
  blue)

