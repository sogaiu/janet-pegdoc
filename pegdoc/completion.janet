(def bash-completion
  ``
  _pdoc_specials() {
      COMPREPLY=( $(compgen -W "$(pdoc --raw-all)" -- ${COMP_WORDS[COMP_CWORD]}) );
  }
  complete -F _pdoc_specials pdoc
  ``)

(def fish-completion
  ``
  function __pdoc_complete_specials
    if not test "$__pdoc_specials"
      set -g __pdoc_specials (pdoc --raw-all)
    end

    printf "%s\n" $__pdoc_specials
  end

  complete -c pdoc -a "(__pdoc_complete_specials)" -d 'specials'
  ``)

(def zsh-completion
  ``
  #compdef pdoc

  _pdoc() {
      local matches=(`pdoc --raw-all`)
      compadd -a matches
  }
  
  _pdoc "$@"
  ``)

(defn maybe-handle-dump-completion
  [opts]
  # this makes use of the fact that print returns nil
  (not
    (cond
      (opts :bash-completion)
      (print bash-completion)
      #
      (opts :fish-completion)
      (print fish-completion)
      #
      (opts :zsh-completion)
      (print zsh-completion)
      #
      true)))

