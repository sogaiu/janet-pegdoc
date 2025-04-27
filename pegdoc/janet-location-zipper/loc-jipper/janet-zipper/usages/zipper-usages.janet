(import ../janet-zipper/zipper :as z)

(comment

  (z/s/butlast [])
  # =>
  nil

  (z/s/butlast @[])
  # =>
  nil

  (z/s/butlast [:a :b :c])
  # =>
  [:a :b]

  (z/s/butlast @[:a])
  # =>
  @[]

  )

(comment

  (z/s/rest [])
  # =>
  nil

  (z/s/rest @[])
  # =>
  nil

  (z/s/rest [:a])
  # =>
  []

  (z/s/rest [:a :b])
  # =>
  [:b]

  (z/s/rest @[:a :b])
  # =>
  @[:b]

  (z/s/rest @[:a :b :c])
  # =>
  @[:b :c]

  )

(comment

  (z/s/tuple-push [:a] :b :c)
  # =>
  [:a :b :c]

  (z/s/tuple-push [] :a)
  # =>
  [:a]

  )

(comment

  (z/s/to-entries {:a 1})
  # =>
  @[[:a 1]]

  (sort (z/s/to-entries @{:a 1 :b 2}))
  # =>
  @[[:a 1] [:b 2]]

  (z/s/to-entries @{:a 1})
  # =>
  @[[:a 1]]

  (z/s/to-entries @{})
  # =>
  @[]

  )

(comment

  (z/s/first-rest-maybe-all [:a])
  # =>
  [:a [] [:a]]

  (z/s/first-rest-maybe-all @[:a :b])
  # =>
  [:a @[:b] @[:a :b]]

  )

# zipper
(comment

  # XXX

  )

# zip
(comment

  (def a-node
    [:a [:b [:x :y]]])

  (deep= (z/zip a-node)
         [a-node @{}])
  # =>
  true

  )

# node
(comment

  (def a-node
    [:a [:b [:x :y]]])

  (z/node (z/zip a-node))
  # =>
  a-node

  )

# state
(comment

  # merge is used to "remove" the prototype table of `st`
  (merge {}
         (z/state (z/zip [:a :b [:x :y]])))
  # =>
  @{}

  (deep=
    #
    (merge {}
           (-> (z/zip [:a :b [:x :y]])
               z/down
               z/state))
    #
    '@{:ls ()
       :pnodes ((:a :b (:x :y)))
       :pstate @{}
       :rs (:b (:x :y))})
  # =>
  true

  (deep=
    #
    (merge {}
           (-> (z/zip [[:a [:b [:x :y]]]])
               z/down
               z/down
               z/right
               z/state))
    #
    '@{:ls (:a)
       :pnodes (((:a (:b (:x :y)))) (:a (:b (:x :y))))
       :pstate @{:ls ()
                 :pnodes (((:a (:b (:x :y)))))
                 :pstate @{}
                 :rs ()}
       :rs ()})
  # =>
  true

  )

# branch?
(comment

  (def a-zip
    (z/zip [:a [:b [:x :y]]]))

  (z/branch? a-zip)
  # =>
  true

  (-> a-zip
      z/down
      z/right
      z/branch?)
  # =>
  true

  (-> a-zip
      z/down
      z/right
      z/down
      z/branch?)
  # =>
  false

  (-> a-zip
      z/down
      z/right
      z/down
      z/right
      z/branch?)
  # =>
  true

  )

# children
(comment

  (def a-zip
    (z/zip [:a [:b [:x :y]]]))

  (-> a-zip
      z/children
      first)
  # =>
  :a

  (-> a-zip
      z/down
      z/right
      z/down
      z/right
      z/children)
  # =>
  [:x :y]

  )

# make-state
(comment

  # XXX

  )

# down
(comment

  (-> (z/zip [:a])
      z/down
      z/node)
  # =>
  :a

  (-> (z/zip [[[:a :b] :c]])
      z/down
      z/down
      z/children)
  # =>
  [:a :b]

  )

# right
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/node)
  # =>
  :x

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/branch?)
  # =>
  true

  (-> [:code
       [:tuple
        [:number "1"] [:whitespace " "]
        [:number "2"]]]
      z/zip
      z/down
      z/right
      z/down
      z/right
      z/right
      z/node)
  # =>
  [:whitespace " "]

  )

# make-node
(comment

  # users of make-node:
  #
  # * up
  # * remove
  # * append-child
  # * insert-child

  )

# up
(comment

  (def a-zip
    (z/zip [[[:a :b :c] :d] :e]))

  (-> a-zip
      z/down
      z/down
      z/down
      z/right
      z/right
      z/up
      z/right
      z/up
      z/right
      z/up
      z/node)
  # =>
  (z/node a-zip)

  )

# end?
(comment

  # users of end?:
  #
  # * root
  # * df-next

  )

# root
(comment

  # `root` is typically used with functions that lead to changes:
  #
  # * replace
  # * edit
  # * insert-child
  # * append-child
  # * remove
  # * insert-left
  # * insert-right

  )

# df-next
(comment

  (def a-zip
    (z/zip [:a :b [:x]]))

  (-> a-zip
      z/df-next
      z/df-next
      z/df-next
      z/node)
  # =>
  [:x]

  (-> a-zip
      z/df-next
      z/df-next
      z/df-next
      z/df-next
      z/node)
  # =>
  :x

  (-> a-zip
      z/df-next
      z/df-next
      z/df-next
      z/df-next
      z/df-next
      z/node)
  # =>
  [:a :b [:x]]

  (-> (z/zip [:a])
      z/df-next
      z/df-next
      z/end?)
  # =>
  true

  )

# replace
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      (z/replace :x)
      z/right
      (z/replace :y)
      z/right
      (z/replace [:a :b])
      z/root)
  # =>
  [:x :y [:a :b]]

  )

# edit
(comment

  (-> (z/zip [1 2 [8 9]])
      z/down
      z/right
      z/right
      z/down
      z/right
      (z/edit dec)
      z/root)
  # =>
  [1 2 [8 8]]

  (-> (z/zip [1 2 [8 9]])
      z/down
      z/right
      z/right
      z/down
      (z/edit + 2)
      z/root)
  # =>
  [1 2 [10 9]]

  )

# insert-child
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      (z/insert-child :w)
      (z/insert-child :v)
      (z/insert-child [])
      z/down
      (z/insert-child :s)
      z/root)
  # =>
  [:a :b [[:s] :v :w :x :y]]

  )

# append-child
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      (z/append-child [])
      z/down
      z/right
      z/right
      (z/append-child :joy)
      z/root)
  # =>
  [:a :b [:x :y [:joy]]]

  )

# rightmost
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/rightmost
      z/node)
  # =>
  [:x :y]

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/rightmost
      z/node)
  # =>
  :y

  (-> (z/zip ['def 'm [:a 1 :b 2]])
      z/down
      z/rightmost
      z/down
      z/rightmost
      z/node)
  # =>
  2

  )

# remove
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/remove
      z/root)
  # =>
  [:a [:x :y]]

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/remove
      z/root)
  # =>
  [:a :b]

  (-> (z/zip [:a :b :c])
      z/down
      z/right
      z/right
      z/remove
      z/root)
  # =>
  [:a :b]

  (-> (z/zip [:a :b :c])
      z/down
      z/right
      z/remove
      z/right
      z/remove
      z/root)
  # =>
  [:a]

  # tests (length ls) == 0 case
  (-> (z/zip [:a :b :c])
      z/down
      z/remove
      z/root)
  # =>
  [:b :c]

  )

# left
(comment

  (def a-zip
    (z/zip [:a :b [:x :y]]))

  (deep= (z/down a-zip)
         (-> a-zip
             z/down
             z/right
             z/left))
  # =>
  true

  (-> a-zip
      z/down
      z/right
      z/right
      z/down
      z/right
      z/left
      z/node)
  # =>
  :x

  )

# df-prev
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/df-prev
      z/node)
  # =>
  :b

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/df-prev
      z/df-prev
      z/node)
  # =>
  :b

  )

# insert-right
(comment

  (-> (z/zip [:a [:b]])
      z/down
      z/right
      z/down
      (z/insert-right :c)
      z/root)
  # =>
  [:a [:b :c]]

  (-> (z/zip [:a])
      z/down
      (z/insert-right [:b])
      z/right
      z/down
      (z/insert-right :c)
      z/root)
  # =>
  [:a [:b :c]]

  )

# insert-left
(comment

  (-> (z/zip [:b])
      z/down
      (z/insert-left :a)
      z/root)
  # =>
  [:a :b]

  (-> (z/zip [:c])
      z/down
      (z/insert-left [:b])
      z/left
      z/down
      (z/insert-left :a)
      z/root)
  # =>
  [[:a :b] :c]

  )

# rights
(comment

  (-> (z/zip [:a :b])
      z/down
      z/rights)
  # =>
  [:b]

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/rights)
  # =>
  [:y]

  )

# lefts
(comment

  (-> (z/zip [:a :b])
      z/down
      z/right
      z/lefts)
  # =>
  [:a]

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/right
      z/lefts)
  # =>
  [:x]

  )

# leftmost
(comment

  (-> (z/zip [:a :b [:x :y]])
      z/down
      z/right
      z/right
      z/down
      z/leftmost
      z/node)
  # =>
  :x

  )

# path
(comment

  # XXX

  )

# right-until
(comment

  (-> (z/zip [:a :b :c
              [:crumb :h :j :k
               [:crumb :prize]]])
      z/down
      (z/right-until |(match (z/node $)
                        [:crumb]
                        true))
      z/down
      (z/right-until |(match (z/node $)
                        [:crumb]
                        true))
      z/down
      z/right
      z/node)
  # =>
  :prize

  )

# search-from
(comment

  (-> (z/zip [:a :b])
      z/down
      (z/search-from |(match (z/node $)
                        :a
                        true))
      (z/search-from |(match (z/node $)
                        :a
                        true))
      z/node)
  # =>
  :a

  )

# search-after
(comment

  (-> (z/zip [:a :b :c
              [:crumb :h :j :k
               [:fake-crumb :dwarf :elf :fiend
                [:crumb :prize]]]])
      (z/search-after |(match (z/node $)
                         [:crumb]
                         true))
      z/down
      (z/search-after |(match (z/node $)
                         [:crumb]
                         true))
      z/down
      z/right
      z/node)
  # =>
  :prize

  )

# unwrap
(comment

  (-> (z/zip [:a :b [:x [:y :z]]])
      z/down
      z/right
      z/right
      z/unwrap
      z/right
      z/unwrap
      z/root)
  # =>
  [:a :b :x :y :z]

  )

# wrap
(comment

  (def a-zloc
    (-> (z/zip [:a :b :c :x])
        z/down))

  (z/node a-zloc)
  # =>
  :a

  (def b-zloc
    (z/right a-zloc))

  (z/node b-zloc)
  # =>
  :b

  (def c-zloc
    (z/right b-zloc))

  (z/node c-zloc)
  # =>
  :c

  (def x-zloc
    (z/right c-zloc))

  (z/node x-zloc)
  # =>
  :x

  (-> (z/wrap a-zloc [] b-zloc)
      z/root)
  # =>
  [[:a :b] :c :x]

  (-> (z/wrap a-zloc [] c-zloc)
      z/root)
  # =>
  [[:a :b :c] :x]

  (-> (z/wrap a-zloc [] x-zloc)
      z/root)
  # =>
  [[:a :b :c :x]]

  (-> (z/wrap b-zloc [] x-zloc)
      z/root)
  # =>
  [:a [:b :c :x]]

  (-> (z/wrap c-zloc [])
      z/root)
  # =>
  [:a :b [:c] :x]

  (-> (z/wrap c-zloc [] x-zloc)
      z/root)
  # =>
  [:a :b [:c :x]]

  (-> (z/wrap x-zloc [])
      z/root)
  # =>
  [:a :b :c [:x]]

  )
