# testing on samples
#
# * the code will attempt to perform round-trip testing across
#   sample source code.  correct results are desirable, but information
#   about speed (perhaps even memory?) might also be nice to obtain.

(import ../janet-peg/rewrite)

(def sep
  (if (= :windows (os/which))
    "\\"
    "/"))

(defn find-files-with-ext
  [dir ext]
  (def paths @[])
  (defn helper
    [a-dir]
    (each path (os/dir a-dir)
      (def sub-path
        (string a-dir sep path))
      (case (os/stat sub-path :mode)
        :directory
        (helper sub-path)
        #
        :file
        (when (string/has-suffix? ext sub-path)
          (array/push paths sub-path)))))
  (helper dir)
  paths)

(comment

  (find-files-with-ext "." file-ext)

  )

(defn clean-end-of-path
  [path sep]
  (when (one? (length path))
    (break path))
  (if (string/has-suffix? sep path)
    (string/slice path 0 -2)
    path))

(comment

  (clean-end-of-path "hello/" "/")
  # =>
  "hello"

  (clean-end-of-path "/" "/")
  # =>
  "/"

  )

(defn main
  [& args]
  (def file-ext ".janet")
  (def src-filepaths @[])
  # collect file and directory paths from args
  (each thing (slice args 1)
    (def apath
      (clean-end-of-path thing sep))
    (def stat
      (os/stat apath :mode))
    # XXX: should :link be supported?
    (cond
      (= :file stat)
      (if (string/has-suffix? file-ext apath)
        (array/push src-filepaths apath)
        (do
          (eprintf "File does not have extension: %p" )
          (os/exit 1)))
      #
      (= :directory stat)
      (array/concat src-filepaths (find-files-with-ext apath file-ext))
      #
      (do
        (eprintf "Not an ordinary file or directory: %p" apath)
        (os/exit 1))))
  (def tot-fps (length src-filepaths))
  (var tot-lines 0)
  (var tot-files 0)
  (def slurp-probs @[])
  (def par-probs @[])
  (def gen-probs @[])
  (def rt-probs @[])
  (var i 0)
  #
  (while (< i tot-fps)
    (prompt :top
      (def fp (get src-filepaths i))
      # XXX: ignore symlinks
      (print fp)
      (var src nil)
      (try
        (set src (slurp fp))
        ([err]
          (eprintf "Problem slurping: %p" fp)
          (array/push slurp-probs fp)
          (++ i)
          (return :top)))
      (def n-lines
        (length (string/split "\n" src)))
      (+= tot-lines n-lines)
      (var tree nil)
      #
      (try
        (set tree
             (rewrite/par src))
        ([err]
          (eprintf "Problem parsing %p: %p" fp err)
          (array/push par-probs fp)
          (++ i)
          (return :top)))
      (var new-src nil)
      (try
        (set new-src
             (rewrite/gen tree))
        ([err]
          (eprintf "Problem generating source for %p: %p" fp err)
          (array/push gen-probs fp)
          (++ i)
          (return :top)))
      (when (not= (string src)
                  new-src)
        (eprintf "Round trip failed for: %p" fp)
        (array/push rt-probs fp)
        (++ i)
        (return :top))
      (++ tot-files)
      (++ i)))
  #
  (print)
  (printf "Files successfully processed: %p / %p"
          tot-files tot-fps)
  (printf "Lines successfully processed: %p" tot-lines)
  (print)
  #
  (when (not (empty? slurp-probs))
    (eprintf "slurp issue file paths: %p" slurp-probs)
    (eprint))
  (when (not (empty? par-probs))
    (eprintf "parse issue file paths: %p" par-probs)
    (eprint))
  (when (not (empty? gen-probs))
    (eprintf "generate issue file paths: %p" gen-probs)
    (eprint)))

