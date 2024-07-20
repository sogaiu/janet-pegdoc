# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./argv :as av)
(import ./completion :as compl)
(import ./examples :as ex)
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

  If any of "boolean", "dictionary", "integer", "string",
  "struct", or "table" are specified as the "peg-special",
  show docs and usages about using those as PEG constructs.

  With the `-d` or `--doc` option, show docs for specified
  PEG special, or if none specified, for a randomly chosen one.

  With the `-q` or `--quiz` option, show quiz question for
  specified PEG special, or if none specified, for a randomly
  chosen one.

  With the `-u` or `--usage` option, show usages for
  specified PEG special, or if none specified, for a randomly
  chosen one.

  With no arguments, lists all PEG specials.

  Be careful to quote shortnames (e.g. *, ->, >, <-, etc.)
  appropriately so the shell doesn't process them in an
  undesired fashion.
  ``)

(defn choose-random-special
  [file-names]
  (def new-names (sort file-names))
  (each r-name ["0.all-the-names.janet" "0.compile.janet"]
    (def r-idx (index-of r-name new-names))
    (when (not r-idx)
      (errorf "Unexpected failure to find %s in: %n" r-name new-names))
    (array/remove new-names r-idx))
  #
  (def file-name (rnd/choose new-names))
  # return name without extension
  (string/slice file-name 0
                (last (string/find-all "." file-name))))

(defn main
  [& argv]
  (setdyn :pdoc-rng
          (math/rng (os/cryptorand 8)))

  (view/configure)

  (def [opts rest errs]
    (av/parse-argv argv))

  (when (not (empty? errs))
    (each err errs
      (eprint "pdoc: " err))
    (eprint "Try 'pdoc -h' for usage text.")
    (os/exit 1))

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
        (ex/all-example-file-names)
        ([e]
          (eprint "Problem determining all names.")
          (eprint e)
          nil)))
    (when (not file-names)
      (eprintf "Failed to find all names.")
      (os/exit 1))
    (doc/all-names (ex/all-names file-names))
    (os/exit 0))

  # check if there was a peg special specified
  (def special-fname (ex/get-filename (first rest)))

  # if no peg-special found and no options, show info about all specials
  (when (and (nil? special-fname)
             (nil? (opts :doc))
             (nil? (opts :usage))
             (nil? (opts :quiz)))
    (if-let [[file-path _]
             (module/find (string ex/examples-root "/0.all-the-names"))]
      (do
        (when (not (os/stat file-path))
          (eprintf "Failed to find file: %s" file-path)
          (os/exit 1))
        (doc/normal-doc (slurp file-path))
        (os/exit 0))
      (do
        (eprint "Hmm, something is wrong, failed to find all the names.")
        (os/exit 1))))

  # ensure a special-name beyond this form by choosing one if needed
  (default special-fname
    (do
      (def file-names
        (try
          (ex/all-example-file-names)
          ([e]
            (eprint "Problem determining all names.")
            (eprint e)
            nil)))
      (when (not file-names)
        (eprintf "Failed to find all names.")
        (os/exit 1))
      (choose-random-special file-names)))

  # show docs, usages, and/or quizzes for a special-fname
  (def file-path (ex/get-filepath special-fname))

  (when (not file-path)
    (eprintf "Did not find file for `%s`" special-fname)
    (os/exit 1))

  (when (not (os/stat file-path))
    (eprintf "Hmm, something is wrong, failed to find file: %s"
             file-path)
    (os/exit 1))

  # XXX: could check for failure here
  (def content (slurp file-path))

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
    (qu/special-quiz content)))

