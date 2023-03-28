(import ../parse/tests :as tests)
(import ../parse/question :as qu)
(import ../highlight/highlight :as hl)
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
    (print (string/repeat "#" (dyn :pdoc-width)))
    (print)
    (print "Answer is: ")
    (print)
    (print-dedented (hl/colorize ans))))

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
      (print (string/repeat "#" (dyn :pdoc-width)))
      (print)
      (print "One value that works is: " blanked-item)
      (print)
      (print "The complete picture would then be: ")
      (print)
      (print-dedented (hl/colorize ques))
      (print "# =>")
      (print-dedented (hl/colorize ans)))))

(defn special-quiz
  [content]
  (def quiz-fn
    (rnd/choose [special-plain-quiz
                 special-fill-in-quiz]))
  (quiz-fn content))

