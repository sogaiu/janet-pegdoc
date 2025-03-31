(defn install
  [manifest &]
  (def os (os/which))
  # based on code in boot.janet
  (def s (get {:windows `\` :mingw `\` :cygwin `\`} os "/"))
  #
  (def bin-name "pdoc")
  (def bin-dir (string/format `%s%sbin` (dyn *syspath*) s))
  #
  (bundle/add manifest "pegdoc")
  (bundle/add-bin manifest bin-name)
  #
  (when (or (= :windows os) (= :mingw os))
    (def bin-path (string/format `%s%s%s` bin-dir `\` bin-name))
    (def bat-content
      # jpm and janet-pm have bits like this
      (string "@echo off\r\n"
              "goto #_undefined_# 2>NUL || "
              `title %COMSPEC% & janet "` bin-path `" %*`))
    # XXX: not so nice approach?  do stuff in _build?
    (def bat-name (string/format "%s.bat" bin-name))
    (defer (os/rm bat-name)
      (spit bat-name bat-content)
      (bundle/add-bin manifest bat-name)))
  # bin-dir may not already be on PATH, so mention
  (print "**************************************************************")
  (printf "To use `%s`, ensure its parent dir is on PATH" bin-name)
  (printf "`%s` lives under %s" bin-name bin-dir)
  (print)
  (print "If PATH is not set up appropriately, may be try (temporary):")
  (print)
  (if (or (= :windows os) (= :mingw os))
    (do
      # escaping % below by using %%
      (printf "  cmd.exe: set PATH=%s;%%PATH%%" bin-dir)
      (printf "  PowerShell: $env:Path = '%s;' + $env:Path" bin-dir))
    (do
      (printf "  fish: fish_add_path --path %s" bin-dir)
      (printf "  bash/zsh: export PATH=%s:$PATH" bin-dir)))
  (print "**************************************************************"))

