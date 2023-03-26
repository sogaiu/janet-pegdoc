# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./alias :as al)
(import ./argv :as av)
(import ./completion :as comp)
(import ./dump :as dump)

(def usage
  ``
  Usage: pdoc [option] [peg-special]

  View peg information.

    -h, --help                  show this output

    -d, --doc [<peg-special>]   show doc
    -x, --eg [<peg-special>]    show examples
    -q, --quiz [<peg-special>]  show quiz question

    --bash-completion           output bash-completion bits
    --fish-completion           output fish-completion bits
    --zsh-completion            output zsh-completion bits
    --raw-all                   show all names to help completion

  With a peg-special, but no options, show docs and examples.
  If any of "integer", "string", or "struct" are specified as the
  "peg-special", show docs and examples about using those as PEG
  constructs.

  With the `-d` or `--doc` option, show docs for specified
  peg special, or if none, of a randomly chosen one.

  With the `-x` or `--eg` option, show examples for
  specified peg special, or if none, of a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for
  specified peg special, or if none, of a randonly chosen one.

  With no arguments, lists all peg specials.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an undesired
  fashion.
  ``)

(defn all-example-file-names
  []
  (let [[file-path _]
        (module/find "pegdoc/examples/0.all-the-names")]
    (when file-path
      (let [dir-path
            (string/slice file-path 0
                          (last (string/find-all "/" file-path)))]
        (unless (os/stat dir-path)
          (errorf "Unexpected directory non-existence:" dir-path))
        #
        (os/dir dir-path)))))

(defn all-names
  [file-names]
  (def names
    (->> file-names
         # drop .janet extension
         (map |(string/slice $ 0
                             (last (string/find-all "." $))))
         # only keep things that have names
         (filter |(not (string/has-prefix? "0." $)))))
  # add things with no names
  (array/push names "integer")
  (array/push names "string")
  (array/push names "struct")
  (each alias (keys al/alias-table)
    (let [name (get al/alias-table alias)]
      (unless (string/has-prefix? "0." name)
        (when (index-of name names)
          (array/push names alias)))))
  #
  names)

(defn choose-random-special
  [file-names]
  (let [idx (math/rng-int (math/rng (os/cryptorand 3))
                          (dec (length file-names)))
        all-idx (index-of "0.all-the-names.janet" file-names)]
    (unless all-idx
      (errorf "Unexpected failure to find file with all the names: %M"
              file-names))
    (def file-name
      (get (array/remove file-names all-idx)
           idx))
    # return name without extension
    (string/slice file-name 0
                  (last (string/find-all "." file-name)))))

(defn main
  [& argv]
  (def [opts rest]
    (av/parse-argv argv))

  # usage
  (when (opts :help)
    (print usage)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (comp/maybe-handle-dump-completion opts)
    (os/exit 0))

  # help completion by showing a raw list of relevant names
  (when (opts :raw-all)
    (def file-names
      (try
        (all-example-file-names)
        ([e]
          (eprint "Problem determining all names.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all names.")
      (os/exit 1))
    (dump/all-names (all-names file-names))
    (os/exit 0))

  # check if there was a peg special specified
  (var peg-special
    (let [cand (first rest)]
      (if-let [alias (get al/alias-table cand)]
        alias
        cand)))

  # if no peg-special found and no options, show info about all specials
  (when (and (nil? peg-special)
             (nil? (opts :doc))
             (nil? (opts :eg))
             (nil? (opts :quiz)))
    (if-let [[file-path _]
             (module/find "pegdoc/examples/0.all-the-names")]
      (do
        (unless (os/stat file-path)
          (eprintf "Failed to find file: %s" file-path)
          (os/exit 1))
        (dump/doc (slurp file-path))
        (os/exit 0))
      (do
        (eprint "Hmm, something is wrong, failed to find all the names.")
        (os/exit 1))))

  # ensure a peg-special beyond this form by choosing one if needed
  (unless peg-special
    (def file-names
      (try
        (all-example-file-names)
        ([e]
          (eprint "Problem determining all names.")
          (eprint e)
          nil)))
    (unless file-names
      (eprintf "Failed to find all names.")
      (os/exit 1))
    (set peg-special
      (choose-random-special file-names)))

  # show docs, examples, and/or quizzes for a peg-special
  (let [[file-path _]
        (module/find (string "pegdoc/examples/" peg-special))]

    (unless file-path
      (eprintf "Did not find doc for `%s`" peg-special)
      (os/exit 1))

    (unless (os/stat file-path)
      (eprintf "Hmm, something is wrong, failed to find file: %s"
               file-path)
      (os/exit 1))

    # XXX: could check for failure here
    (def content
      (slurp file-path))

    (when (or (and (opts :doc) (opts :eg))
              (and (nil? (opts :doc))
                   (nil? (opts :eg))
                   (nil? (opts :quiz))))
      (dump/special-doc content)
      (print (string/repeat "#" 68))
      (dump/special-examples content)
      (os/exit 0))

    (when (opts :doc)
      (dump/special-doc content))

    (cond
      (opts :eg)
      (dump/special-examples content)
      #
      (opts :quiz)
      (dump/special-quiz content))))

