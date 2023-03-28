(def none
  [nil])

(defn mono-str
  [text _ignored]
  text)

(defn mono-prin
  [msg _color]
  (prin msg))

(def mono-separator-color
  none)

