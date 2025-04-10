(defn install
  [manifest &]
  (def bin-name "pdoc")
  #
  (bundle/add manifest "pegdoc")
  (bundle/add-bin manifest bin-name)
  #
  (def os (os/which))
  (when (or (= :windows os) (= :mingw os))
    (def bin-path (string/format `%s\bin\%s` (dyn *syspath*) bin-name))
    (def bat-content
      # jpm and janet-pm have bits like this
      # https://github.com/microsoft/terminal/issues/217#issuecomment-737594785
      (string "@echo off\r\n"
              "goto #_undefined_# 2>NUL || "
              `title %COMSPEC% & janet "` bin-path `" %*`))
    # XXX: not so nice approach?  do stuff in _build?
    (def bat-name (string/format "%s.bat" bin-name))
    (defer (os/rm bat-name)
      (spit bat-name bat-content)
      (bundle/add-bin manifest bat-name))))

