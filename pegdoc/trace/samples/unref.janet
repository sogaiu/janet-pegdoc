[~{:main (sequence :thing -1)
   :thing (choice (unref (sequence :open :thing :close))
                  (capture (any (if-not "[" 1))))
   :open (capture (sequence "[" (some "_") "]")
                  :delim)
   :close (capture (backmatch :delim))}
 "[__][_]a[_][__]"]
