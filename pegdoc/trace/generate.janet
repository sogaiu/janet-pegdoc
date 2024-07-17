(import ../random :as rnd)
(import ./render :as r)

(def samples-root
  # XXX: kind of a work-around
  (string (dyn :syspath) "/pegdoc/trace/samples"))

(defn enum-samples
  []
  (os/dir samples-root))

(defn scan-for-files
  [pattern]
  (filter |(string/find pattern $)
          (enum-samples)))

(defn choose-random
  [files]
  (string samples-root "/" (rnd/choose files)))

(defn scan-with-random
  [pattern]
  (let [results (scan-for-files pattern)
        files (if (not (empty? results))
                results
                (enum-samples))]
    (choose-random files)))

(defn report
  [dir-path]
  (printf "Generated trace files in %s." dir-path)
  (printf "Recommended starting points:")
  (def first-event-path
    (string/format "file://%s/first.html" dir-path))
  (def last-event-path
    (string/format "file://%s/last.html" dir-path))
  (def trace-log-path
    (string/format "file://%s/all.html" dir-path))
  (printf "* first event: %s" first-event-path)
  (printf "* last event: %s" last-event-path)
  (printf "* all events: %s" trace-log-path))

# XXX: might be a better way...
(defn extract
  [content]
  # quote and eval to prepare to remove head element
  (def form (eval-string (string "'" content)))
  # check that the call is to peg/match or meg/match
  (assert (peg/match ~(sequence (set "mp")
                                "eg/match"
                                -1)
                     (string (first form)))
          (string/format "not a call to peg/match or meg/match: %s"
                         (first form)))
  (def args (drop 1 form))
  # back to string and eval again to handle any quote / quasiquote
  (map |(eval-string (string/format "%n" $))
       args))

(comment

  (extract ``
           (peg/match ~(sequence "abc"
                                 (argument 0))
                      "abc"
                      0
                     :smile
                     :it-is-fine)
           ``)
  # =>
  '@[(sequence "abc" (argument 0)) "abc" 0 :smile :it-is-fine]

  )

(defn gen-files-inner
  [peg text start force dir-path & args]
  (def stat (os/stat dir-path))
  (def mode (get stat :mode))
  (when (and stat
             (not= :directory mode))
    (errorf "non-directory with name %s exists already" dir-path))
  #
  (cond
    (nil? stat)
    (do
      (os/mkdir dir-path)
      (assert (= :directory
                 (os/stat dir-path :mode))
              (string/format "failed to arrange for trace directory: %s"
                             dir-path)))
    #
    (and (false? force)
         (not (empty? (os/dir dir-path))))
    (do
      (def prmpt
        (string/format "Directory `%s` exists, overwrite contents? [y/N] "
                       dir-path))
      (def buf (getline prmpt))
      (when (not (string/has-prefix? "y" (string/ascii-lower buf)))
        (eprintf "Ok, bye!")
        (break))))
  #
  (def old-dir (os/cwd))
  (defer (os/cd old-dir)
    (os/cd dir-path)
    (r/render peg text start ;args))
  #
  (report dir-path))

(defn gen-files
  [content &opt force dir-path]
  (default force false)
  (default dir-path ".")
  (try
    (do
      (def [peg text start & args]
        (eval-string content))
      (default start 0)
      (default args [])
      (gen-files-inner peg text start force dir-path ;args))
    ([e f]
      (eprintf "problem creating trace files using: %s" content)
      (propagate e f))))

(defn gen-files-from-call-str
  [call-str &opt force dir-path]
  (default force true)
  (default dir-path ".")
  (try
    (do
      (def [peg text start & args]
        (extract call-str))
      (default start 0)
      (default args [])
      (gen-files-inner peg text start force dir-path ;args))
    ([e f]
      (eprintf "problem creating trace files using: %s" call-str)
      (propagate e f))))

