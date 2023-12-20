(import ../doc)

# XXX: not sure if this quoting will work on windows...
(defn escape
  [a-str]
  (string "\""
          a-str
          "\""))

(defn all-names
  [names]
  # print all names
  (each name (sort names)
    # XXX: anything missing?
    # XXX: anything platform-specific?
    (if (get {"*" true
              "->" true
              ">" true
              "<-" true}
             name)
      (print (escape name))
      (print name))))

(defn normal-doc
  [content]
  '(each line (doc/normal-doc content)
    (print line))
  (print (doc/normal-doc content)))

(defn special-doc
  [content &opt width indent]
  (print (doc/special-doc content width indent)))
