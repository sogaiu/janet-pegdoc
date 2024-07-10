(import ../margaret/margaret/render :as r)

(def samples-root
  "pegdoc/trace/samples")

(defn enum-samples
  []
  (os/dir samples-root))

(defn report
  [dir-path]
  (printf "Generated trace files in `%s`." dir-path)
  (printf "Recommended starting points:")
  (def first-event-path
    (string/format "file://%s/%s/0.html" (os/cwd) dir-path))
  (def trace-log-path
    (string/format "file://%s/%s/all.html" (os/cwd) dir-path))
  (printf "* first event: %s" first-event-path)
  (printf "* all events: %s" trace-log-path))

(defn gen-files
  [content &opt dir-path]
  (default dir-path "meg-trace")
  (try
    (do
      (def [peg text start & args]
        (eval-string content))
      #
      (default start 0)
      (default args [])
      (def stat (os/stat dir-path))
      (def mode (get stat :mode))
      (when (and stat
                 (not= :directory mode))
        (errorf "non-directory with name %s exists already" dir-path))
      #
      (if stat
        (do
          (def prmpt
            (string/format "Directory `%s` exists, overwrite contents? [y/N] "
                           dir-path))
          (def buf (getline prmpt))
          (when (not (string/has-prefix? "y" (string/ascii-lower buf)))
            (eprintf "Ok, bye!")
            (break)))
        (do
          (os/mkdir dir-path)
          (assert (= :directory
                     (os/stat dir-path :mode))
                  (string/format "failed to arrange for trace directory: %s"
                                 dir-path))))
      #
      (def old-dir (os/cwd))
      (defer (os/cd old-dir)
        (os/cd dir-path)
        (r/render peg text start ;args))
      #
      (report dir-path))
    ([e]
      (eprintf "problem creating trace files using: %s" content)
      (eprintf e))))

