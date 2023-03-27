(import ./color :as color)
(import ./theme :as theme)

(defn configure
  []
  # width
  # XXX: tput cols can give a number for this, but not multi-platform?
  (setdyn :pdoc-width 68)
  # color
  (let [color-level (os/getenv "PDOC_COLOR")
        color-term (os/getenv "COLORTERM")]
    # XXX: not ready for prime time, so insist PDOC_COLOR is
    #      set for anything to happen
    (if color-level
      (cond
        (or (= "rgb" color-level)
            # XXX: tput colors more portable?
            (= "truecolor" color-term))
        (do
          (setdyn :pdoc-hl-str color/rgb-str)
          (setdyn :pdoc-theme theme/rgb-theme))
        #
        (or (= "basic" color-level)
            (= "16" color-term))
        (do
          (setdyn :pdoc-hl-str color/color-str)
          (setdyn :pdoc-theme theme/color-theme))
        #
        (do
          (setdyn :pdoc-hl-str color/mono-str)
          (setdyn :pdoc-theme theme/mono-theme)))
      # no color
      (do
        (setdyn :pdoc-hl-str color/mono-str)
        (setdyn :pdoc-theme theme/mono-theme)))))

