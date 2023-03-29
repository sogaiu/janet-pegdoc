(import ../highlight/highlight :as hl)
(import ../jandent/indent)
(import ../parse/question :as qu)
(import ../parse/tests :as tests)
(import ../random :as rnd)

(defn get-indent
  [a-str]
  (if-let [[indent]
           (peg/match ~(capture :s+) a-str)]
    indent
    ""))

(defn print-nicely
  [expr-str]
  (let [buf (hl/colorize (indent/format expr-str))]
    (each line (string/split "\n" buf)
      (print line))))

(defn special-plain-quiz
  [content]
  (def tests
    (tests/extract-first-test-set content))
  (when (empty? tests)
    (print "Sorry, didn't find any material to make a quiz from.")
    (break nil))
  # XXX: should check for success?
  (let [[ques ans] (rnd/choose tests)
        trimmed-ans (string/trim ans)]
    (print-nicely ques)
    (def buf @"")
    (print "# =>")
    (getline "" buf)
    (print)
    ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                         (dyn :pdoc-separator-color))
    (print)
    (print)
    (def trimmed-resp
      (string/trim buf))
    (when (empty? trimmed-resp)
      (print "Had enough?  Perhaps on another occasion then.")
      (break nil))
    (print "My answer is:")
    (print)
    (print-nicely trimmed-ans)
    (print)
    (print "Your answer is:")
    (print)
    (print-nicely trimmed-resp)
    (print)
    (when (deep= trimmed-ans trimmed-resp)
      (print "Yay, our answers agree :)")
      (break true))
    (print "Our answers differ, but perhaps yours works too.")
    (print)
    (try
      (let [result (eval-string trimmed-resp)
            evaled-ans (eval-string trimmed-ans)]
        (if (deep= result evaled-ans)
          (do
            (printf "Nice, our answers both evaluate to: %M"
                    evaled-ans)
            true)
          (do
            (printf "Sorry, your answer evaluates to: %M" result)
            false)))
      ([e]
        (print "Sorry, failed to evaluate your answer.")
        (print)
        (print "The error I got was: " e)
        (print)
        (print "I tried to evaluate the following.")
        (print)
        (print-nicely trimmed-resp)
        false))))

(defn special-fill-in-quiz
  [content]
  (def test-zloc-pairs
    (tests/extract-first-test-set-zlocs content))
  (when (empty? test-zloc-pairs)
    (print "Sorry, didn't find any material to make a quiz from.")
    (break nil))
  # XXX: should check for success?
  (let [[ques-zloc ans-zloc] (rnd/choose test-zloc-pairs)
        [blank-ques-zloc blanked-item] (qu/rewrite-test-zloc ques-zloc)]
    # XXX: a cheap work-around...evidence of a deeper issue?
    (unless blank-ques-zloc
      (print "Sorry, drew a blank...take a deep breath and try again?")
      (break nil))
    (let [ques (tests/indent-node-gen ques-zloc)
          blank-ques (tests/indent-node-gen blank-ques-zloc)
          trimmed-ans (string/trim (tests/indent-node-gen ans-zloc))]
      (print-nicely blank-ques)
      (print "# =>")
      (print-nicely trimmed-ans)
      (print)
      (def buf @"")
      (getline "What value could work in the blank? " buf)
      (print)
      ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                           (dyn :pdoc-separator-color))
      (print)
      (print)
      (def trimmed-resp
        (string/trim buf))
      (when (empty? trimmed-resp)
        (print "Had enough?  Perhaps on another occasion then.")
        (break nil))
      (print "One complete picture is: ")
      (print)
      (print-nicely ques)
      (print "# =>")
      (print-nicely trimmed-ans)
      (print)
      (print "So one value that works is:")
      (print)
      (print-nicely blanked-item)
      (print)
      (when (deep= blanked-item trimmed-resp)
        (print "Yay, our answers agree :)")
        (break true))
      (print "Your answer is:")
      (print)
      (print-nicely trimmed-resp)
      (print)
      (print "Our answers differ, but perhaps yours works too.")
      (print)
      (let [indeces (string/find-all "_" blank-ques)
            head-idx (first indeces)
            tail-idx (last indeces)]
        # XXX: cheap method -- more accurate would be to use zippers
        (def cand-code
          (string (string/slice blank-ques 0 head-idx)
                  trimmed-resp
                  (string/slice blank-ques (inc tail-idx))))
        (try
          (let [result (eval-string cand-code)
                evaled-ans (eval-string trimmed-ans)]
            (if (deep= result evaled-ans)
              (do
                (printf "Nice, our answers both evaluate to: %M"
                        evaled-ans)
                true)
              (do
                (printf "Sorry, your answer evaluates to: %M" result)
                false)))
          ([e]
            (print "Sorry, failed to evaluate your answer.")
            (print)
            (print "The error I got was: " e)
            (print)
            (print "I tried to evaluate the following.")
            (print)
            (print-nicely cand-code)
            false))))))

(defn special-quiz
  [content]
  (def quiz-fn
    (rnd/choose [special-plain-quiz
                 special-fill-in-quiz]))
  (quiz-fn content))

