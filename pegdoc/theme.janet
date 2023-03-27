(import ./color :as color)

(defn rgb-theme
  [node-type]
  (cond
    (= :symbol node-type)
    color/chartreuse
    #
    (= :keyword node-type)
    color/magenta
    #
    (= :string node-type)
    color/yellow
    #
    (= :number node-type)
    color/cyan
    #
    [nil nil nil]))

(defn color-theme
  [node-type]
  (cond
    (= :symbol node-type)
    [:green]
    #
    (= :keyword node-type)
    [:magenta]
    #
    (= :string node-type)
    [:yellow]
    #
    (= :number node-type)
    [:cyan]
    #
    [nil]))

(defn mono-theme
  [_]
  [nil])

