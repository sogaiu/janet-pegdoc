(import ./color :as color)
(import ./mono :as mono)
(import ./rgb :as rgb)

(defn rgb-theme
  [node-type]
  (cond
    (= :symbol node-type)
    rgb/chartreuse
    #
    (= :keyword node-type)
    rgb/magenta
    #
    (= :string node-type)
    rgb/yellow
    #
    (= :number node-type)
    rgb/cyan
    #
    rgb/none))

(defn color-theme
  [node-type]
  (cond
    (= :symbol node-type)
    color/green
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
    color/none))

(defn mono-theme
  [_]
  mono/none)

