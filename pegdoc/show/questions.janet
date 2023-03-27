(import ../parse/extract :as ext)
(import ../highlight/highlight :as hl)

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

(defn special-quiz
  [content]
  (def tests
    (ext/extract-first-test-set content))
  (let [idx (math/rng-int (math/rng (os/cryptorand 3))
                          (length tests))
        [ques ans] (get tests idx)]
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

