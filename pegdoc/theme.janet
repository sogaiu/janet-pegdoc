(import ./color :as clr)

(defn rgb-theme
  [node-type]
  (cond
    (= :symbol node-type)
    clr/chartreuse
    #
    (= :keyword node-type)
    clr/magenta
    #
    (= :string node-type)
    clr/yellow
    #
    (= :number node-type)
    clr/cyan
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

