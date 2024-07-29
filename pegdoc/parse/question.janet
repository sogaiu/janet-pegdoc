(import ../janet-peg/janet-peg/location :as l)
(import ./zipper :as j)
(import ../janet-location-zipper/loc-jipper :as j)
(import ../random :as rnd)
(import ./specials :as sp)

(defn dprintf
  [fmt & args]
  (when (os/getenv "VERBOSE")
    (eprintf fmt ;args)))

# XXX: outline
#
# * (rewrite-test test-zloc)
#   * (find-peg-match-call test-zloc)
#     * (rewrite-peg-match-call peg-match-zloc)
#       * (find-grammar-argument peg-match-zloc)
#         * (find-peg-specials grammar-zloc)
#           * (choose-peg-special peg-special-zlocs)
#             * (blank-peg-special peg-special-zloc)

# XXX: list cases not handled
#
#      * integer (handled in find-peg-specials)
#      * keyword (handled in find-peg-specials)
#      * string long-string (handled in find-peg-specials)
#      * constant (handled in find-peg-specials)
#      * other?
(defn is-peg-special?
  [a-sym]
  (get sp/specials a-sym))

# XXX: might be issues with cmt and replace -- could rethink as
#      "what to blank" instead of just looking for peg specials
(defn find-peg-specials
  [grammar-zloc]
  (def results @[])
  # compare against this to determine whether still a descendant
  (def grammar-path-len
    (length (j/path grammar-zloc)))
  (var curr-zloc grammar-zloc)
  (while (not (j/end? curr-zloc))
    (match (j/node curr-zloc)
      [:symbol _ content]
      (when (is-peg-special? content)
        (array/push results curr-zloc))
      [:number]
      (array/push results curr-zloc)
      [:keyword]
      (array/push results curr-zloc)
      [:constant]
      (array/push results curr-zloc)
      [:string]
      (array/push results curr-zloc)
      [:long-string]
      (array/push results curr-zloc))
    (set curr-zloc
         (j/df-next curr-zloc))
    # XXX: not 100% sure whether this is something that can be relied on
    (when (or (j/end? curr-zloc)
              # no longer a descendant of grammar-zloc
              # XXX: verify relying on this is solid
              (<= (length (j/path curr-zloc))
                  grammar-path-len))
      (break)))
  #
  results)

(comment

  (def src
    ``
    ~(sequence "#"
               (capture (to "=>"))
               "=>"
               (capture (thru -1)))
    ``)

  (map |(j/node $)
       (find-peg-specials (-> (l/par src)
                              j/zip-down)))
  # =>
  '@[(:symbol @{:bc 3 :bl 1 :ec 11 :el 1} "sequence")
     (:string @{:bc 12 :bl 1 :ec 15 :el 1} "\"#\"")
     (:symbol @{:bc 13 :bl 2 :ec 20 :el 2} "capture")
     (:symbol @{:bc 22 :bl 2 :ec 24 :el 2} "to")
     (:string @{:bc 25 :bl 2 :ec 29 :el 2} "\"=>\"")
     (:string @{:bc 12 :bl 3 :ec 16 :el 3} "\"=>\"")
     (:symbol @{:bc 13 :bl 4 :ec 20 :el 4} "capture")
     (:symbol @{:bc 22 :bl 4 :ec 26 :el 4} "thru")
     (:number @{:bc 27 :bl 4 :ec 29 :el 4} "-1")]

  )

(defn blank-peg-special
  [peg-special-zloc]
  (def node-type
    (get (j/node peg-special-zloc) 0))
  (var blanked-item nil)
  (var new-peg-special-zloc nil)
  (cond
    (or (= :symbol node-type)
        (= :constant node-type)
        (= :number node-type)
        (= :string node-type)
        (= :long-string node-type)
        (= :keyword node-type))
    (set new-peg-special-zloc
         (j/edit peg-special-zloc
                 |(let [original-item (get $ 2)]
                    (set blanked-item original-item)
                    [node-type
                     (get $ 1)
                     (string/repeat "_" (length original-item))])))
    #
    (do
      (eprintf "Unexpected node-type: %s" node-type)
      (set new-peg-special-zloc peg-special-zloc)))
  [new-peg-special-zloc blanked-item])

(comment

    (def src
    ``
    ~(sequence "#"
               (capture (to "=>"))
               "=>"
               (capture (thru -1)))
    ``)

  (def ps-zloc
    (first (find-peg-specials (-> (l/par src)
                                  j/zip-down))))

  (def [new-peg-special blanked-item]
    (blank-peg-special ps-zloc))

  (j/node new-peg-special)
  # =>
  [:symbol @{:bc 3 :bl 1 :ec 11 :el 1} "________"]

  blanked-item
  # =>
  "sequence"

  (->> (blank-peg-special ps-zloc)
       first
       j/root
       l/gen)
  # =>
  ``
  ~(________ "#"
             (capture (to "=>"))
             "=>"
             (capture (thru -1)))
  ``

  )

(defn find-grammar-argument
  [peg-match-call-zloc]
  (when-let [pm-sym-zloc
             (j/search-from peg-match-call-zloc
                            |(match (j/node $)
                               [:symbol _ "peg/match"]
                               true))]
    # this should be the first argument
    (j/right-skip-wsc pm-sym-zloc)))

(comment

  (def src
    ``
    (peg/match ~(capture (range "09"))
               "123")
    ``)

  (j/node (find-grammar-argument (->> (l/par src)
                                      j/zip-down)))
  # =>
  '(:quasiquote
     @{:bc 12 :bl 1 :ec 35 :el 1}
     (:tuple @{:bc 13 :bl 1 :ec 35 :el 1}
             (:symbol @{:bc 14 :bl 1 :ec 21 :el 1} "capture")
             (:whitespace @{:bc 21 :bl 1 :ec 22 :el 1} " ")
             (:tuple @{:bc 22 :bl 1 :ec 34 :el 1}
                     (:symbol @{:bc 23 :bl 1 :ec 28 :el 1} "range")
                     (:whitespace @{:bc 28 :bl 1 :ec 29 :el 1} " ")
                     (:string @{:bc 29 :bl 1 :ec 33 :el 1} "\"09\""))))

  )

# XXX: not perfect but close enough?
(defn find-peg-match-call
  [test-zloc]
  (when-let [pm-sym-zloc
             (j/search-from test-zloc
                            |(match (j/node $)
                               [:symbol _ "peg/match"]
                               true))]
    # this should be the tuple the peg/match symbol is a child of
    (j/up pm-sym-zloc)))

(comment

  (def src
    ``
    (try
      (peg/match ~(error (capture "a"))
                 "a")
      ([e] e))
    ``)

  (j/node (find-peg-match-call (->> (l/par src)
                                    j/zip-down)))
  # ->
  '(:tuple
     @{:bc 3 :bl 2 :ec 18 :el 3}
     (:symbol @{:bc 4 :bl 2 :ec 13 :el 2} "peg/match")
     (:whitespace @{:bc 13 :bl 2 :ec 14 :el 2} " ")
     (:quasiquote @{:bc 14 :bl 2 :ec 36 :el 2}
                  (:tuple @{:bc 15 :bl 2 :ec 36 :el 2}
                          (:symbol @{:bc 16 :bl 2 :ec 21 :el 2} "error")
                          (:whitespace @{:bc 21 :bl 2 :ec 22 :el 2} " ")
                          (:tuple @{:bc 22 :bl 2 :ec 35 :el 2}
                                  (:symbol @{:bc 23 :bl 2 :ec 30 :el 2}
                                           "capture")
                                  (:whitespace @{:bc 30 :bl 2 :ec 31 :el 2}
                                               " ")
                                  (:string @{:bc 31 :bl 2 :ec 34 :el 2}
                                           "\"a\""))))
     (:whitespace @{:bc 36 :bl 2 :ec 1 :el 3} "\n")
     (:whitespace @{:bc 1 :bl 3 :ec 14 :el 3} "             ")
     (:string @{:bc 14 :bl 3 :ec 17 :el 3} "\"a\""))

  (def src
    ``
    (peg/match ~(if 1 "a")
               "a")
    ``)

  (j/node (find-peg-match-call (->> (l/par src)
                                    j/zip-down)))
  # =>
  '(:tuple
     @{:bc 1 :bl 1 :ec 16 :el 2}
     (:symbol @{:bc 2 :bl 1 :ec 11 :el 1} "peg/match")
     (:whitespace @{:bc 11 :bl 1 :ec 12 :el 1} " ")
     (:quasiquote @{:bc 12 :bl 1 :ec 23 :el 1}
                  (:tuple @{:bc 13 :bl 1 :ec 23 :el 1}
                          (:symbol @{:bc 14 :bl 1 :ec 16 :el 1} "if")
                          (:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " ")
                          (:number @{:bc 17 :bl 1 :ec 18 :el 1} "1")
                          (:whitespace @{:bc 18 :bl 1 :ec 19 :el 1} " ")
                          (:string @{:bc 19 :bl 1 :ec 22 :el 1} "\"a\"")))
     (:whitespace @{:bc 23 :bl 1 :ec 1 :el 2} "\n")
     (:whitespace @{:bc 1 :bl 2 :ec 12 :el 2} "           ")
     (:string @{:bc 12 :bl 2 :ec 15 :el 2} "\"a\""))

  )

(defn rewrite-test-zloc
  [test-zloc]
  # XXX: why is this printing a function...
  (dprintf "%M" j/path)
  (when-let [pm-call-zloc
             (find-peg-match-call test-zloc)
             grammar-zloc
             (find-grammar-argument pm-call-zloc)]
    (dprintf "test:")
    (dprintf (l/gen (j/node test-zloc)))
    (dprintf "grammar:")
    (dprintf (l/gen (j/node grammar-zloc)))
    # find how many "steps" back are needed to "get back" to original spot
    (var steps 0)
    (var chosen-special-zloc nil)
    # XXX: better to factor out so it can be recursive?
    (def grammar-node-type
      (get (j/node grammar-zloc) 0))
    (cond
      (or (= :string grammar-node-type)
          (= :long-string grammar-node-type)
          (= :keyword grammar-node-type)
          (= :constant grammar-node-type)
          (= :number grammar-node-type))
      (do
        (dprintf "grammar was a %s" grammar-node-type)
        (set chosen-special-zloc grammar-zloc))
      #
      (get {:tuple true
            :bracket-tuple true
            :quote true
            :quasiquote true
            :splice true
            :struct true
            :table true} grammar-node-type)
      (let [specials (find-peg-specials grammar-zloc)]
        # XXX
        (dprintf "grammar was a %s" grammar-node-type)
        # XXX
        (dprintf "Number of specials found: %d" (length specials))
        (when (empty? specials)
          # XXX
          (eprint "Failed to find a special")
          (break [nil nil]))
        (each sp specials
          (dprintf (l/gen (j/node sp))))
        (set chosen-special-zloc
             (rnd/choose specials))
        (dprintf "chosen: %s" (l/gen (j/node chosen-special-zloc))))
      #
      (do
        (eprint "Unexpected node-type:" grammar-node-type)
        (break [nil nil])))
    # find how many steps away we are from test-zloc's node
    (var curr-zloc chosen-special-zloc)
    # XXX: compare (attrs ...) results instead of gen / node
    (def test-str
      (l/gen (j/node test-zloc)))
    (while curr-zloc
      # XXX: expensive?
      # XXX: compare (attrs ...) results instead -- should be faster
      #      attrs should be unique inside the tree(?)
      (when (= (l/gen (j/node curr-zloc))
               test-str)
        (break))
      (set curr-zloc
           (j/df-prev curr-zloc))
      (++ steps))
    # XXX
    (dprintf "steps: %d" steps)
    # XXX: check not nil?
    (var [curr-zloc blanked-item]
      (->> chosen-special-zloc
           blank-peg-special))
    # get back to "test-zloc" position
    (for i 0 steps
      (set curr-zloc
           (j/df-prev curr-zloc)))
    # XXX
    #(dprintf "curr-zloc: %M" curr-zloc)
    #
    [curr-zloc blanked-item]))

(defn rewrite-test
  [test-zloc]
  (when-let [[rewritten-zloc blanked-item]
             (rewrite-test-zloc test-zloc)]
    [(->> rewritten-zloc
         j/root
         l/gen)
     blanked-item]))

(comment

  (def src
    ``
    (try
      (peg/match ~(error (capture "a"))
                 "a")
      ([e] e))
    ``)

  (def [result blanked-item]
    (rewrite-test (->> (l/par src)
                       j/zip-down)))

  (or (= "error" blanked-item)
      (= "\"a\"" blanked-item)
      (= "capture" blanked-item))
  # =>
  true

  (or (= result
         ``
         (try
           (peg/match ~(error (_______ "a"))
                      "a")
           ([e] e))
         ``)
      (= result
         ``
         (try
           (peg/match ~(_____ (capture "a"))
                      "a")
           ([e] e))
         ``)
      (= result
         ``
         (try
           (peg/match ~(error (capture ___))
                      "a")
           ([e] e))
         ``)
      (= result
         ``
         (try
           (peg/match ~(error (capture "a"))
                      ___)
           ([e] e))
         ``))
  # =>
  true

  )

