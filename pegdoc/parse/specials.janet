# XXX: does not have integers, strings, structs, and alias for repeat
# XXX: hard-wiring -- is there a better way?
(def specials
  (tabseq [k :in ['! '$ '% '* '+ '-> '/ '<- '> '?
                  'accumulate 'any 'argument 'at-least 'at-most
                  'backmatch 'backref 'between
                  'capture 'choice 'cmt 'column 'constant
                  'drop
                  'error
                  'group
                  'if 'if-not 'int 'int-be
                  'lenprefix 'line 'look
                  'not 'number
                  'opt
                  'position
                  'quote
                  'range 'repeat 'replace
                  'sequence 'set 'some
                  'thru 'to
                  'uint 'uint-be 'unref]]
    (string k) true))


