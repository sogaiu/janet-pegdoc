(import ./highlight/color :as color)
(import ./highlight/mono :as mono)
(import ./highlight/rgb :as rgb)
(import ./highlight/theme :as theme)

(defn configure
  []
  # width
  # XXX: tput cols can give a number for this, but not multi-platform?
  (setdyn :pdoc-width 68)
  # color
  (let [color-level (os/getenv "PDOC_COLOR")
        # XXX: tput colors more portable?
        color-term (os/getenv "COLORTERM")]
    # XXX: not ready for prime time, so insist PDOC_COLOR is
    #      set for anything to happen
    (if color-level
      (cond
        (or (= "rgb" color-level)
            #(= "truecolor" color-term)
            false)
        (do
          (setdyn :pdoc-hl-prin rgb/rgb-prin)
          (setdyn :pdoc-hl-str rgb/rgb-str)
          (setdyn :pdoc-separator-color rgb/rgb-separator-color)
          (setdyn :pdoc-theme theme/rgb-theme))
        #
        (or (= "color" color-level)
            (= "16" color-term))
        (do
          (setdyn :pdoc-hl-prin color/color-prin)
          (setdyn :pdoc-hl-str color/color-str)
          (setdyn :pdoc-separator-color color/color-separator-color)
          (setdyn :pdoc-theme theme/color-theme))
        #
        (do
          (setdyn :pdoc-hl-prin mono/mono-prin)
          (setdyn :pdoc-hl-str mono/mono-str)
          (setdyn :pdoc-separator-color mono/mono-separator-color)
          (setdyn :pdoc-theme theme/mono-theme)))
      # no color
      (do
        (setdyn :pdoc-hl-prin mono/mono-prin)
        (setdyn :pdoc-hl-str mono/mono-str)
        (setdyn :pdoc-separator-color mono/mono-separator-color)
        (setdyn :pdoc-theme theme/mono-theme)))))

