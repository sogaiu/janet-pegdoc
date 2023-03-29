(import ../highlight/highlight :as hl)
(import ../parse/question :as qu)
(import ../parse/tests :as tests)
(import ../random :as rnd)

(defn get-indent
  [a-str]
  (if-let [[indent]
           (peg/match ~(capture :s+) a-str)]
    indent
    ""))

(defn print-dedented
  [expr-str]
  (if-let [indent (get-indent expr-str)
           count (length indent)]
    (each line (string/split "\n" expr-str)
      (print (string/slice line count)))))

(defn special-plain-quiz
  [content]
  (def tests
    (tests/extract-first-test-set content))
  # XXX: should check for success
  (let [[ques ans] (rnd/choose tests)]
    (print-dedented (hl/colorize ques))
    (def buf @"")
    (print "# =>")
    (getline "" buf)
    (print)
    ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                         (dyn :pdoc-separator-color))
    (print)
    (print)
    (def trimmed-ans
      (string/trim buf))
    # XXX: loop to get a non-empty answer?
    (when (empty? trimmed-ans)
      (print "Had enough?  Perhaps on another occasion then.")
      (break nil))
    (print "My answer is:")
    (print)
    (print-dedented (hl/colorize ans))
    (print)
    (print "Your answer is:")
    (print)
    (print (hl/colorize trimmed-ans))
    (print)
    # XXX: why is this trimming necessary?
    (when (deep= (string/trim ans) trimmed-ans)
        (print "Yay, our answers agree :)")
        (break true))
    (print "Sorry, I don't think your answer is correct.")
    #
    false))

(defn special-fill-in-quiz
  [content]
  (def test-zloc-pairs
    (tests/extract-first-test-set-zlocs content))
  # XXX: should check for success
  (let [[ques-zloc ans-zloc] (rnd/choose test-zloc-pairs)
        [blank-ques-zloc blanked-item] (qu/rewrite-test-zloc ques-zloc)]
    # XXX: a cheap work-around...evidence of a deeper issue?
    (unless blank-ques-zloc
      (print "Sorry, drew a blank...take a deep breath and try again?")
      (break))
    (let [ques (tests/indent-node-gen ques-zloc)
          blank-ques (tests/indent-node-gen blank-ques-zloc)
          ans (tests/indent-node-gen ans-zloc)]
      (print-dedented (hl/colorize blank-ques))
      (print "# =>")
      (print-dedented (hl/colorize ans))
      (print)
      (def buf @"")
      (getline "What value could work in the blank? " buf)
      (print)
      ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                           (dyn :pdoc-separator-color))
      (print)
      (print)
      (def trimmed-ans
        (string/trim buf))
      # XXX: loop to get a non-empty answer?
      (when (empty? trimmed-ans)
        (print "Had enough?  Perhaps on another occasion then.")
        (break nil))
      (print "One complete picture is: ")
      (print)
      (print-dedented (hl/colorize ques))
      (print "# =>")
      (print-dedented (hl/colorize ans))
      (print)
      (print "So one value that works is: " blanked-item)
      (print)
      (when (deep= blanked-item trimmed-ans)
        (print "Yay, our answers agree :)")
        (break true))
      (print "Our answers differ, but perhaps yours works too.")
      (let [indeces (string/find-all "_" blank-ques)
            head-idx (first indeces)
            tail-idx (last indeces)]
        # XXX: cheap method -- more accurate would be to use zippers
        (def cand-code
          (string (string/slice blank-ques 0 head-idx)
                  trimmed-ans
                  (string/slice blank-ques (inc tail-idx))))
        (try
          # XXX: this trimming seems weird...
          (let [result (string/trim (eval-string cand-code))]
            (if (deep= result ans)
              (do
                (printf "Nice, your answer also evaluates to: %M" ans)
                true)
              (do
                (printf "Sorry, your answer evalutes to: %M" ans)
                false)))
          ([e]
            (print "Sorry, failed to evaluate with your answer.")
            false))))))

(defn special-quiz
  [content]
  (def quiz-fn
    (rnd/choose [special-plain-quiz
                 special-fill-in-quiz]))
  (quiz-fn content))

