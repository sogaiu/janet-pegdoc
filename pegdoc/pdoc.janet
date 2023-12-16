# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./argv :as av)
(import ./completion :as compl)
(import ./random :as rnd)
(import ./show/doc :as doc)
(import ./show/usages :as u)
(import ./show/questions :as qu)
(import ./view :as view)

(def usage
  ``
  Usage: pdoc [option] [peg-special]

  View Janet PEG information.

    -h, --help                   show this output

    -d, --doc [<peg-special>]    show doc
    -q, --quiz [<peg-special>]   show quiz question
    -u, --usage [<peg-special>]  show usage

    --bash-completion            output bash-completion bits
    --fish-completion            output fish-completion bits
    --zsh-completion             output zsh-completion bits
    --raw-all                    show all names for completion

  With a peg-special, but no options, show docs and usages.

  If any of "boolean", "integer", "string", or "struct" are
  specified as the "peg-special", show docs and usages about
  using those as PEG constructs.

  With the `-d` or `--doc` option, show docs for specified
  PEG special, or if none specified, for a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for
  specified PEG special, or if none specified, for a randonly
  chosen one.

  With the `-u` or `--usage` option, show usages for
  specified PEG special, or if none specified, for a randomly
  chosen one.

  With no arguments, lists all PEG specials.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an
  undesired fashion.
  ``)

(def examples-table
  {"+" "choice"
   "*" "sequence"
   "opt" "between"
   "?" "between"
   "!" "not"
   ">" "look"
   "<-" "capture"
   "quote" "capture"
   "/" "replace"
   "$" "position"
   "%" "accumulate"
   "->" "backref"
   #
   "boolean" "0.boolean"
   "integer" "0.integer"
   "string" "0.string"
   "struct" "0.struct"})

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
  (array/push names "boolean")
  (array/push names "integer")
  (array/push names "string")
  (array/push names "struct")
  # add aliases
  (each alias (keys examples-table)
    (let [name (get examples-table alias)]
      (unless (string/has-prefix? "0." name)
        (when (index-of name names)
          (array/push names alias)))))
  #
  names)

(defn choose-random-special
  [file-names]
  (let [all-idx (index-of "0.all-the-names.janet" file-names)]
    (unless all-idx
      (errorf "Unexpected failure to find file with all the names: %M"
              file-names))
    (def file-name
      (rnd/choose (array/remove file-names all-idx)))
    # return name without extension
    (string/slice file-name 0
                  (last (string/find-all "." file-name)))))

(defn main
  [& argv]
  (setdyn :pdoc-rng
          (math/rng (os/cryptorand 8)))

  (view/configure)

  (def [opts rest]
    (av/parse-argv argv))

  # usage
  (when (opts :help)
    (print usage)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (compl/maybe-handle-dump-completion opts)
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
    (doc/all-names (all-names file-names))
    (os/exit 0))

  # check if there was a peg special specified
  (var peg-special
    (let [cand (first rest)]
      (if-let [alias (get examples-table cand)]
        alias
        cand)))

  # if no peg-special found and no options, show info about all specials
  (when (and (nil? peg-special)
             (nil? (opts :doc))
             (nil? (opts :usage))
             (nil? (opts :quiz)))
    (if-let [[file-path _]
             (module/find "pegdoc/examples/0.all-the-names")]
      (do
        (unless (os/stat file-path)
          (eprintf "Failed to find file: %s" file-path)
          (os/exit 1))
        (doc/normal-doc (slurp file-path))
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

  # show docs, usages, and/or quizzes for a peg-special
  (let [[file-path _]
        (module/find (string "pegdoc/examples/" peg-special))]

    (unless file-path
      (eprintf "Did not find file for `%s`" peg-special)
      (os/exit 1))

    (unless (os/stat file-path)
      (eprintf "Hmm, something is wrong, failed to find file: %s"
               file-path)
      (os/exit 1))

    # XXX: could check for failure here
    (def content
      (slurp file-path))

    (when (or (and (opts :doc) (opts :usage))
              (and (nil? (opts :doc))
                   (nil? (opts :usage))
                   (nil? (opts :quiz))))
      (doc/special-doc content)
      ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                           (dyn :pdoc-separator-color))
      (print)
      (u/special-usages content)
      (os/exit 0))

    (when (opts :doc)
      (doc/special-doc content))

    (cond
      (opts :usage)
      (u/special-usages content)
      #
      (opts :quiz)
      (qu/special-quiz content))))

