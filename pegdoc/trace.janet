(import ./margaret/render :as r)

(defn make-trace-files
  [content]
  (try
    (do
      (def [peg text start & args]
        (parse-all content))
      #
      (default start 0)
      (default args [])
      (r/render peg text start ;args)
      (printf "Generated HTML trace files and dump.jdn.")
      (printf "Why not have a look at 0.html?"))
    ([e]
      (eprintf "problem creating trace files using: %s" content)
      (eprintf e))))

