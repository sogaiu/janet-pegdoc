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

    -d, --doc <peg-special>     show doc
    -x, --eg <peg-special>      show examples
    -q, --quiz [<peg-special>]  show quiz question

    --bash-completion           output bash-completion bits
    --fish-completion           output fish-completion bits
    --zsh-completion            output zsh-completion bits
    --raw-all                   show all names to help completion

  With a peg-special, but no options, show docs and examples.
  If any of "integer", "string", or "struct" are specified as the
  "peg-special", show docs and examples about using those as PEG
  constructs.

  With the `-d` or `--doc` option and a peg-special (or one of the
  exceptions mentioned above), show associated docs.

  With the `-x` or `--eg` option and a peg-special (or one of the
  exceptions mentioned above), show associated examples.

  With the `-q` or `--quiz` option, show a quiz question for
  a specified peg special, or if not specified, a random quiz
  question.

  With no arguments, lists all peg specials.

  Be careful to quote shortnames (e.g. *, ->, >, <-) appropriately
  so the shell doesn't process them in an undesired fashion.
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
        (os/dir dir-path)))))

(defn choose-random-special
  [file-names]
  (let [idx (math/rng-int (math/rng (os/cryptorand 3))
                          (dec (length file-names)))
        all-idx (index-of "0.all-the-names.janet" file-names)]
    (unless all-idx
      (errorf "Unexpected failure to find file with all the names: %M" 
              file-names))
    (get (array/remove file-names all-idx)
         idx)))

(defn main
  [& argv]
  (def [opts rest]
    (av/parse-argv argv))

  (when (opts :help)
    (print usage)
    (os/exit 0))

  # possibly handle dumping completion bits
  (when (comp/maybe-handle-dump-completion opts)
    (os/exit 0))

  # show all special names including aliases (and string, integer, struct)
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
    (dump/all-names file-names)
    (os/exit 0))

  (when (or (opts :doc) (opts :eg))
    (when (empty? rest)
      (eprint "Need one non-option argument.")
      (os/exit 1)))

  (def peg-special
    (let [cand (first rest)]
      (if-let [alias (get al/alias-table cand)]
        alias
        cand)))

  # no peg-special found, so...
  (unless peg-special
    # show random quiz question
    (when (opts :quiz)
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
      (def choice
        (choose-random-special file-names))
      (dump/special-quiz (string "pegdoc/examples/" choice))
      (os/exit 0))
    # or, show info about all specials
    (if-let [[file-path _]
             (module/find "pegdoc/examples/0.all-the-names")]
      (do
        (dump/doc file-path)
        (os/exit 0))
      (do
        (eprint "Hmm, something is wrong, failed to find all the names.")
        (os/exit 1))))

  # show docs and/or examples for a peg-special
  (let [[file-path _]
        (module/find (string "pegdoc/examples/" peg-special))]

    (unless file-path
      (eprintf "Did not find doc for `%s`" peg-special)
      (os/exit 1))

    (unless (os/stat file-path)
      (eprintf "Hmm, something is wrong, failed to find file: %s"
               file-path)
      (os/exit 1))

    (when (or (and (opts :doc) (opts :eg))
              (and (nil? (opts :doc))
                   (nil? (opts :eg))
                   (nil? (opts :quiz))))
      (dump/special-doc file-path)
      (print (string/repeat "#" 68))
      (dump/special-examples file-path)
      (os/exit 0))

    (when (opts :doc)
      (dump/special-doc file-path))

    (cond
      (opts :eg)
      (dump/special-examples file-path)
      #
      (opts :quiz)
      (dump/special-quiz file-path))))

