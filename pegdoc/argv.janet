(defn parse-argv
  [argv]
  (def opts @{})
  (def rest @[])
  (def argc (length argv))
  #
  (when (> argc 1)
    (var i 1)
    (while (< i argc)
      (def arg (get argv i))
      (cond
        (get {"--bash-completion" true} arg)
        (put opts :bash-completion true)
        #
        (get {"--fish-completion" true} arg)
        (put opts :fish-completion true)
        #
        (get {"--zsh-completion" true} arg)
        (put opts :zsh-completion true)
        #
        (get {"--raw-all" true} arg)
        (put opts :raw-all true)
        #
        (get {"--doc" true
              "-d" true}
             arg)
        (put opts :doc true)
        #
        (get {"--eg" true
              "-x" true}
             arg)
        (put opts :eg true)
        #
        (get {"--quiz" true
              "-q" true}
             arg)
        (put opts :quiz true)
        #
        (get {"--help" true
              "-h" true}
             arg)
        (put opts :help true)
        #
        (array/push rest arg))
      (++ i)))
  #
  [opts rest])

