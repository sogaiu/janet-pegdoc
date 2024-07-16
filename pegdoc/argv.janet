(def arg-data
  {"--bash-completion" true
   "--fish-completion" true
   "--zsh-completion" true
   "--raw-all" true
   "--doc" "-d"
   "--help" "-h"
   "--quiz" "-q"
   "--stdin" "-s"
   "--trace" "-t"
   "--usage" "-u"
   "--web" "-w"})

(def shorts-table
  (tabseq [[full short] :pairs arg-data
           :when short]
    short full))

(defn opt-to-keyword
  [opt-str]
  (def full-opt-str (get shorts-table opt-str opt-str))
  (when (not (string/has-prefix? "--" full-opt-str))
    (break (string/format "Unknown short option: %s" opt-str)))
  (when (not (get arg-data full-opt-str))
    (break (string/format "Unknown option: %s" opt-str)))
  (keyword (string/slice full-opt-str 2)))

(defn parse-argv
  [argv]
  (def opts @{})
  (def rest @[])
  (def errs @[])
  (def argc (length argv))
  #
  (when (> argc 1)
    (var i 1)
    (while (< i argc)
      (def arg (get argv i))
      (if (string/has-prefix? "-" arg)
        (let [res (opt-to-keyword arg)]
          (cond
            (string? res)
            (array/push errs res)
            #
            (keyword? res)
            (put opts res true)
            #
            (array/push errs
                        (string/format "unexpected type: %n"
                                       (type res)))))
        (array/push rest arg))
      (++ i)))
  #
  [opts rest errs])

