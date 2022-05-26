!.
=>  %a50
~%  %a.50  ~  ~
|%
::  Types
::
+$  ship  @p
+$  life  @ud
+$  rift  @ud
+$  pass  @
+$  bloq  @
+$  step  _`@u`1
+$  bite  $@(bloq [=bloq =step])
+$  octs  [p=@ud q=@]
+$  mold  $~(* $-(* *))
+$  knot  @ta
+$  noun  *
+$  path  (list knot)
++  unit  |$  [item]  $@(~ [~ u=item])
++  list  |$  [item]  $@(~ [i=item t=(list item)])
++  lest  |$  [item]  [i=item t=(list item)]
++  tree  |$  [node]  $@(~ [n=node l=(tree node) r=(tree node)])
++  pair  |$  [head tail]  [p=head q=tail]
++  each
  |$  [this that]
  $%  [%| p=that]
      [%& p=this]
  ==
+$  gate
  $-(* *)
++  trap
  |$  [product]
  _|?($:product)
++  map
  |$  [key value]
  $|  (tree (pair key value))
  |=(a=(tree (pair)) ?:(=(~ a) & ~(apt by a)))
::
++  set
  |$  [item]
  $|  (tree item)
  |=(a=(tree) ?:(=(~ a) & ~(apt in a)))
::
++  jug   |$  [key value]  (map key (set value))
::
::  Bits
::
++  dec                                                 ::  decrement
  ~/  %dec
  |=  a=@
  ~_  leaf+"decrement-underflow"
  ?<  =(0 a)
  =+  b=0
  |-  ^-  @
  ?:  =(a +(b))  b
  $(b +(b))
::
++  add                                                 ::  plus
  ~/  %add
  |=  [a=@ b=@]
  ^-  @
  ?:  =(0 a)  b
  $(a (dec a), b +(b))
::
++  sub                                                 ::  subtract
  ~/  %sub
  |=  [a=@ b=@]
  ~_  leaf+"subtract-underflow"
  ::  difference
  ^-  @
  ?:  =(0 b)  a
  $(a (dec a), b (dec b))
::
++  mul                                                 ::  multiply
  ~/  %mul
  |:  [a=`@`1 b=`@`1]
  ^-  @
  =+  c=0
  |-
  ?:  =(0 a)  c
  $(a (dec a), c (add b c))
::
++  div                                                 ::  divide
  ~/  %div
  |:  [a=`@`1 b=`@`1]
  ^-  @
  ~_  leaf+"divide-by-zero"
  ?<  =(0 b)
  =+  c=0
  |-
  ?:  (lth a b)  c
  $(a (sub a b), c +(c))
::
++  dvr                                                 ::  divide w/remainder
  ~/  %dvr
  |:  [a=`@`1 b=`@`1]
  ^-  [p=@ q=@]
  [(div a b) (mod a b)]
::
++  mod                                                 ::  modulus
  ~/  %mod
  |:  [a=`@`1 b=`@`1]
  ^-  @
  ?<  =(0 b)
  (sub a (mul b (div a b)))
::
++  con                                                 ::  binary or
  ~/  %con
  |=  [a=@ b=@]
  =+  [c=0 d=0]
  |-  ^-  @
  ?:  ?&(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   %+  add  d
          %+  lsh  [0 c]
          ?&  =(0 (end 0 a))
              =(0 (end 0 b))
          ==
  ==
::
++  dis                                                 ::  binary and
  ~/  %dis
  |=  [a=@ b=@]
  =|  [c=@ d=@]
  |-  ^-  @
  ?:  ?|(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   %+  add  d
          %+  lsh  [0 c]
          ?|  =(0 (end 0 a))
              =(0 (end 0 b))
          ==
  ==
::
++  mix                                                 ::  binary xor
  ~/  %mix
  |=  [a=@ b=@]
  ^-  @
  =+  [c=0 d=0]
  |-
  ?:  ?&(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   (add d (lsh [0 c] =((end 0 a) (end 0 b))))
  ==
::
++  lth                                                 ::  less
  ~/  %lth
  |=  [a=@ b=@]
  ^-  ?
  ?&  !=(a b)
      |-
      ?|  =(0 a)
          ?&  !=(0 b)
              $(a (dec a), b (dec b))
  ==  ==  ==
::
++  lte                                                 ::  less or equal
  ~/  %lte
  |=  [a=@ b=@]
  |(=(a b) (lth a b))
::
++  gte                                                 ::  greater or equal
  ~/  %gte
  |=  [a=@ b=@]
  ^-  ?
  !(lth a b)
::
++  gth                                                 ::  greater
  ~/  %gth
  |=  [a=@ b=@]
  ^-  ?
  !(lte a b)
::
::  Hashes
::
++  muk                                                 ::  standard murmur3
  ~%  %muk  ..muk  ~
  =+  ~(. fe 5)
  |=  [syd=@ len=@ key=@]
  =.  syd      (end 5 syd)
  =/  pad      (sub len (met 3 key))
  =/  data     (welp (rip 3 key) (reap pad 0))
  =/  nblocks  (div len 4)  ::  intentionally off-by-one
  =/  h1  syd
  =+  [c1=0xcc9e.2d51 c2=0x1b87.3593]
  =/  blocks  (rip 5 key)
  =/  i  nblocks
  =.  h1  =/  hi  h1  |-
    ?:  =(0 i)  hi
    =/  k1  (snag (sub nblocks i) blocks)  ::  negative array index
    =.  k1  (sit (mul k1 c1))
    =.  k1  (rol 0 15 k1)
    =.  k1  (sit (mul k1 c2))
    =.  hi  (mix hi k1)
    =.  hi  (rol 0 13 hi)
    =.  hi  (sum (sit (mul hi 5)) 0xe654.6b64)
    $(i (dec i))
  =/  tail  (slag (mul 4 nblocks) data)
  =/  k1    0
  =/  tlen  (dis len 3)
  =.  h1
    ?+  tlen  h1  ::  fallthrough switch
      %3  =.  k1  (mix k1 (lsh [0 16] (snag 2 tail)))
          =.  k1  (mix k1 (lsh [0 8] (snag 1 tail)))
          =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
      %2  =.  k1  (mix k1 (lsh [0 8] (snag 1 tail)))
          =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
      %1  =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
    ==
  =.  h1  (mix h1 len)
  |^  (fmix32 h1)
  ++  fmix32
    |=  h=@
    =.  h  (mix h (rsh [0 16] h))
    =.  h  (sit (mul h 0x85eb.ca6b))
    =.  h  (mix h (rsh [0 13] h))
    =.  h  (sit (mul h 0xc2b2.ae35))
    =.  h  (mix h (rsh [0 16] h))
    h
  --
::
++  mug                                                 ::  mug with murmur3
  ~/  %mug
  |=  a=*
  |^  ?@  a  (mum 0xcafe.babe 0x7fff a)
      =/  b  (cat 5 $(a -.a) $(a +.a))
      (mum 0xdead.beef 0xfffe b)
  ::
  ++  mum
    |=  [syd=@uxF fal=@F key=@]
    =/  wyd  (met 3 key)
    =|  i=@ud
    |-  ^-  @F
    ?:  =(8 i)  fal
    =/  haz=@F  (muk syd wyd key)
    =/  ham=@F  (mix (rsh [0 31] haz) (end [0 31] haz))
    ?.(=(0 ham) ham $(i +(i), syd +(syd)))
  --
::
++  gor                                                 ::  mug order
  ~/  %gor
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(mug a) d=(mug b)]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
++  mor                                                 ::  more mug order
  ~/  %mor
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(mug (mug a)) d=(mug (mug b))]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
++  dor                                                 ::  tree order
  ~/  %dor
  |=  [a=* b=*]
  ^-  ?
  ?:  =(a b)  &
  ?.  ?=(@ a)
    ?:  ?=(@ b)  |
    ?:  =(-.a -.b)
      $(a +.a, b +.b)
    $(a -.a, b -.b)
  ?.  ?=(@ b)  &
  (lth a b)
::
++  por                                                 ::  parent order
  ~/  %por
  |=  [a=@p b=@p]
  ^-  ?
  ?:  =(a b)  &
  =|  i=@
  |-
  ?:  =(i 2)
    ::  second two bytes
    (lte a b)
  ::  first two bytes
  =+  [c=(end 3 a) d=(end 3 b)]
  ?:  =(c d)
    $(a (rsh 3 a), b (rsh 3 b), i +(i))
  (lth c d)
::
::  Maps
::
++  by
  ~/  %by
  =|  a=(tree (pair))  ::  (map)
  =*  node  ?>(?=(^ a) n.a)
  |@
  ++  get
    ~/  %get
    |*  b=*
    =>  .(b `_?>(?=(^ a) p.n.a)`b)
    |-  ^-  (unit _?>(?=(^ a) q.n.a))
    ?~  a
      ~
    ?:  =(b p.n.a)
      `q.n.a
    ?:  (gor b p.n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  put
    ~/  %put
    |*  [b=* c=*]
    |-  ^+  a
    ?~  a
      [[b c] ~ ~]
    ?:  =(b p.n.a)
      ?:  =(c q.n.a)
        a
      a(n [b c])
    ?:  (gor b p.n.a)
      =+  d=$(a l.a)
      ?>  ?=(^ d)
      ?:  (mor p.n.a p.n.d)
        a(l d)
      d(r a(l r.d))
    =+  d=$(a r.a)
    ?>  ?=(^ d)
    ?:  (mor p.n.a p.n.d)
      a(r d)
    d(l a(r l.d))
  ::
  ++  del
    ~/  %del
    |*  b=*
    |-  ^+  a
    ?~  a
      ~
    ?.  =(b p.n.a)
      ?:  (gor b p.n.a)
        a(l $(a l.a))
      a(r $(a r.a))
    |-  ^-  [$?(~ _a)]
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (mor p.n.l.a p.n.r.a)
      l.a(r $(l.a r.l.a))
    r.a(l $(r.a l.r.a))
  ::
  ++  gas                                               ::  concatenate
    ~/  %gas
    |*  b=(list [p=* q=*])
    =>  .(b `(list _?>(?=(^ a) n.a))`b)
    |-  ^+  a
    ?~  b
      a
    $(b t.b, a (put p.i.b q.i.b))
  ::
  ++  apt
    =<  $
    ~/  %apt
    =|  [l=(unit) r=(unit)]
    |.  ^-  ?
    ?~  a   &
    ?&  ?~(l & &((gor p.n.a u.l) !=(p.n.a u.l)))
        ?~(r & &((gor u.r p.n.a) !=(u.r p.n.a)))
        ?~  l.a   &
        &((mor p.n.a p.n.l.a) !=(p.n.a p.n.l.a) $(a l.a, l `p.n.a))
        ?~  r.a   &
        &((mor p.n.a p.n.r.a) !=(p.n.a p.n.r.a) $(a r.a, r `p.n.a))
    ==
  --
::
++  on                                                  ::  ordered map
  ~/  %on
  |*  [key=mold val=mold]
  =>  |%
      +$  item  [key=key val=val]
      --
  ::
  ~%  %comp  +>+  ~
  |=  compare=$-([key key] ?)
  ~%  %core    +  ~
  |%
  ::
  ++  apt
    ~/  %apt
    |=  a=(tree item)
    =|  [l=(unit key) r=(unit key)]
    |-  ^-  ?
    ?~  a  %.y
    ?&  ?~(l %.y (compare key.n.a u.l))
        ?~(r %.y (compare u.r key.n.a))
        ?~(l.a %.y &((mor key.n.a key.n.l.a) $(a l.a, l `key.n.a)))
        ?~(r.a %.y &((mor key.n.a key.n.r.a) $(a r.a, r `key.n.a)))
    ==
  ::
  ++  get
    ~/  %get
    |=  [a=(tree item) b=key]
    ^-  (unit val)
    ?~  a  ~
    ?:  =(b key.n.a)
      `val.n.a
    ?:  (compare b key.n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  has
    ~/  %has
    |=  [a=(tree item) b=key]
    ^-  ?
    !=(~ (get a b))
  ::
  ++  put
    ~/  %put
    |=  [a=(tree item) =key =val]
    ^-  (tree item)
    ?~  a  [n=[key val] l=~ r=~]
    ?:  =(key.n.a key)  a(val.n val)
    ?:  (compare key key.n.a)
      =/  l  $(a l.a)
      ?>  ?=(^ l)
      ?:  (mor key.n.a key.n.l)
        a(l l)
      l(r a(l r.l))
    =/  r  $(a r.a)
    ?>  ?=(^ r)
    ?:  (mor key.n.a key.n.r)
      a(r r)
    r(l a(r l.r))
  --
::
::  Sets
::
++  in
  ~/  %in
  =|  a=(tree)  :: (set)
  |@
  ++  put
    ~/  %put
    |*  b=*
    |-  ^+  a
    ?~  a
      [b ~ ~]
    ?:  =(b n.a)
      a
    ?:  (gor b n.a)
      =+  c=$(a l.a)
      ?>  ?=(^ c)
      ?:  (mor n.a n.c)
        a(l c)
      c(r a(l r.c))
    =+  c=$(a r.a)
    ?>  ?=(^ c)
    ?:  (mor n.a n.c)
      a(r c)
    c(l a(r l.c))
  ::
  ++  del
    ~/  %del
    |*  b=*
    |-  ^+  a
    ?~  a
      ~
    ?.  =(b n.a)
      ?:  (gor b n.a)
        a(l $(a l.a))
      a(r $(a r.a))
    |-  ^-  [$?(~ _a)]
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (mor n.l.a n.r.a)
      l.a(r $(l.a r.l.a))
    r.a(l $(r.a l.r.a))
  ::
  ++  apt
    =<  $
    ~/  %apt
    =|  [l=(unit) r=(unit)]
    |.  ^-  ?
    ?~  a   &
    ?&  ?~(l & (gor n.a u.l))
        ?~(r & (gor u.r n.a))
        ?~(l.a & ?&((mor n.a n.l.a) $(a l.a, l `n.a)))
        ?~(r.a & ?&((mor n.a n.r.a) $(a r.a, r `n.a)))
    ==
  --
::
::  Jugs
::
++  ju
  =|  a=(tree (pair * (tree)))  ::  (jug)
  |@
  ++  get
    |*  b=*
    =+  c=(~(get by a) b)
    ?~(c ~ u.c)
  ::
  ++  del
    |*  [b=* c=*]
    ^+  a
    =+  d=(get b)
    =+  e=(~(del in d) c)
    ?~  e
      (~(del by a) b)
    (~(put by a) b e)
  ::
  ++  put
    |*  [b=* c=*]
    ^+  a
    =+  d=(get b)
    (~(put by a) b (~(put in d) c))
  --
::::
::::  JSON
::::
+$  json                                                ::  normal json value
  $@  ~                                                 ::  null
  $%  [%a p=(list json)]                                ::  array
      [%b p=?]                                          ::  boolean
      [%o p=(map @t json)]                              ::  object
      [%n p=@ta]                                        ::  number
      [%s p=@t]                                         ::  string
  ==                                                    ::
::
+$  tape  (list @tD)                                    ::  utf8 string as list
++  crip  |=(a=tape `@t`(rap 3 a))                      ::  tape to cord
++  trip                                                ::  cord to tape
  ~/  %trip
  |=  a=@  ^-  tape
  ?:  =(0 (met 3 a))
    ~
  [^-(@ta (end 3 a)) $(a (rsh 3 a))]
::
::                                                    ::  ++enjs:format
++  enjs  ^?                                          ::  json encoders
  |%
  ::                                                  ::  ++frond:enjs:format
  ++  frond                                           ::  object from k-v pair
    |=  [p=@t q=json]
    ^-  json
    [%o [[p q] ~ ~]]
  ::                                                  ::  ++pairs:enjs:format
  ++  pairs                                           ::  object from k-v list
    |=  a=(list [p=@t q=json])
    ^-  json
    [%o (~(gas by *(map @t json)) a)]
  ::                                                  ::  ++tape:enjs:format
  ++  tape                                            ::  string from tape
    |=  a=^tape
    ^-  json
    [%s (crip a)]
  ::  ::                                                  ::  ++wall:enjs:format
  ::  ++  wall                                            ::  string from wall
  ::    |=  a=^wall
  ::    ^-  json
  ::    (tape (of-wall a))
  ::                                                      ::  ++ship:enjs:format
  ::  ++  ship                                            ::  string from ship
  ::    |=  a=^ship
  ::    ^-  json
  ::    [%n (rap 3 '"' (rsh [3 1] (scot %p a)) '"' ~)]
  ::                                                  ::  ++numb:enjs:format
  ++  numb                                            ::  number from unsigned
    |=  a=@u
    ^-  json
    :-  %n
    ?:  =(0 a)  '0'
    %-  crip
    %-  flop
    |-  ^-  ^tape
    ?:(=(0 a) ~ [(add '0' (mod a 10)) $(a (div a 10))])
  ::  TODO see if we want chrono
  ::  ::                                                  ::  ++sect:enjs:format
  ::  ++  sect                                            ::  s timestamp
  ::    |=  a=^time
  ::    (numb (unt:chrono:userlib a))
  ::  ::                                                  ::  ++time:enjs:format
  ::  ++  time                                            ::  ms timestamp
  ::    |=  a=^time
  ::    (numb (unm:chrono:userlib a))
  ::                                                      ::  ++path:enjs:format
  ::  ++  path                                            ::  string from path
  ::    |=  a=^path
  ::    ^-  json
  ::    [%s (spat a)]
  --  ::enjs
::                                                      ::
::::  2a: unit logic                                    ::
  ::                                                    ::
  ::    biff, bind, bond, both, clap, drop,             ::
  ::    fall, flit, lift, mate, need, some              ::
  ::
++  biff                                                ::  apply
  |*  [a=(unit) b=$-(* (unit))]
  ?~  a  ~
  (b u.a)
::
++  bind                                                ::  argue
  |*  [a=(unit) b=gate]
  ?~  a  ~
  [~ u=(b u.a)]
::
++  bond                                                ::  replace
  |*  a=(trap)
  |*  b=(unit)
  ?~  b  $:a
  u.b
::
++  both                                                ::  all the above
  |*  [a=(unit) b=(unit)]
  ?~  a  ~
  ?~  b  ~
  [~ u=[u.a u.b]]
::
++  clap                                                ::  combine
  |*  [a=(unit) b=(unit) c=_=>(~ |=(^ +<-))]
  ?~  a  b
  ?~  b  a
  [~ u=(c u.a u.b)]
::
++  clef                                                ::  compose
  |*  [a=(unit) b=(unit) c=_=>(~ |=(^ `+<-))]
  ?~  a  ~
  ?~  b  ~
  (c u.a u.b)
::
++  drop                                                ::  enlist
  |*  a=(unit)
  ?~  a  ~
  [i=u.a t=~]
::
++  fall                                                ::  default
  |*  [a=(unit) b=*]
  ?~(a b u.a)
::
++  flit                                                ::  make filter
  |*  a=$-(* ?)
  |*  b=*
  ?.((a b) ~ [~ u=b])
::
++  hunt                                                ::  first of units
  |*  [ord=$-(^ ?) a=(unit) b=(unit)]
  ^-  %-  unit
      $?  _?>(?=(^ a) u.a)
          _?>(?=(^ b) u.b)
      ==
  ?~  a  b
  ?~  b  a
  ?:((ord u.a u.b) a b)
::
++  lift                                                ::  lift mold (fmap)
  |*  a=mold                                            ::  flipped
  |*  b=(unit)                                          ::  curried
  (bind b a)                                            ::  bind
::
++  mate                                                ::  choose
  |*  [a=(unit) b=(unit)]
  ?~  b  a
  ?~  a  b
  ?.(=(u.a u.b) ~>(%mean.'mate' !!) a)
::
++  need                                                ::  demand
  ~/  %need
  |*  a=(unit)
  ?~  a  ~>(%mean.'need' !!)
  u.a
::
++  some                                                ::  lift (pure)
  |*  a=*
  [~ u=a]
::
::::  2b: list logic                                    ::
  ::                                                    ::
  ::                                                    ::
::
::  +snoc: append an element to the end of a list
::
++  snoc
  |*  [a=(list) b=*]
  (weld a ^+(a [b]~))
::
++  fand                                                ::  all indices
  ~/  %fand
  |=  [nedl=(list) hstk=(list)]
  =|  i=@ud
  =|  fnd=(list @ud)
  |-  ^+  fnd
  =+  [n=nedl h=hstk]
  |-
  ?:  |(?=(~ n) ?=(~ h))
    (flop fnd)
  ?:  =(i.n i.h)
    ?~  t.n
      ^$(i +(i), hstk +.hstk, fnd [i fnd])
    $(n t.n, h t.h)
  ^$(i +(i), hstk +.hstk)
::
++  find                                                ::  first index
  ~/  %find
  |=  [nedl=(list) hstk=(list)]
  =|  i=@ud
  |-   ^-  (unit @ud)
  =+  [n=nedl h=hstk]
  |-
  ?:  |(?=(~ n) ?=(~ h))
     ~
  ?:  =(i.n i.h)
    ?~  t.n
      `i
    $(n t.n, h t.h)
  ^$(i +(i), hstk +.hstk)
::
++  flop                                                ::  reverse
  ~/  %flop
  |*  a=(list)
  =>  .(a (homo a))
  ^+  a
  =+  b=`_a`~
  |-
  ?~  a  b
  $(a t.a, b [i.a b])
::
++  gulf                                                ::  range inclusive
  |=  [a=@ b=@]
  ?>  (lte a b)
  |-  ^-  (list @)
  ?:(=(a +(b)) ~ [a $(a +(a))])
::
++  homo                                                ::  homogenize
  |*  a=(list)
  ^+  =<  $
    |@  ++  $  ?:(*? ~ [i=(snag 0 a) t=$])
    --
  a
::  +join: construct a new list, placing .sep between every pair in .lit
::
++  join
  |*  [sep=* lit=(list)]
  =.  sep  `_?>(?=(^ lit) i.lit)`sep
  ?~  lit  ~
  =|  out=(list _?>(?=(^ lit) i.lit))
  |-  ^+  out
  ?~  t.lit
    (flop [i.lit out])
  $(out [sep i.lit out], lit t.lit)
::
::  +bake: convert wet gate to dry gate by specifying argument mold
::
++  bake
  |*  [f=gate a=mold]
  |=  arg=a
  (f arg)
::
++  lent                                                ::  length
  ~/  %lent
  |=  a=(list)
  ^-  @
  =+  b=0
  |-
  ?~  a  b
  $(a t.a, b +(b))
::
++  levy
  ~/  %levy                                             ::  all of
  |*  [a=(list) b=$-(* ?)]
  |-  ^-  ?
  ?~  a  &
  ?.  (b i.a)  |
  $(a t.a)
::
++  lien                                                ::  some of
  ~/  %lien
  |*  [a=(list) b=$-(* ?)]
  |-  ^-  ?
  ?~  a  |
  ?:  (b i.a)  &
  $(a t.a)
::
++  limo                                                ::  listify
  |*  a=*
  ^+  =<  $
    |@  ++  $  ?~(a ~ ?:(*? [i=-.a t=$] $(a +.a)))
    --
  a
::
++  murn                                                ::  maybe transform
  ~/  %murn
  |*  [a=(list) b=$-(* (unit))]
  =>  .(a (homo a))
  |-  ^-  (list _?>(?=(^ a) (need (b i.a))))
  ?~  a  ~
  =/  c  (b i.a)
  ?~  c  $(a t.a)
  [+.c $(a t.a)]
::
++  oust                                                ::  remove
  ~/  %oust
  |*  [[a=@ b=@] c=(list)]
  (weld (scag +<-< c) (slag (add +<-< +<->) c))
::
++  reap                                                ::  replicate
  ~/  %reap
  |*  [a=@ b=*]
  |-  ^-  (list _b)
  ?~  a  ~
  [b $(a (dec a))]
::
++  rear                                                ::  last item of list
  ~/  %rear
  |*  a=(list)
  ^-  _?>(?=(^ a) i.a)
  ?>  ?=(^ a)
  ?:  =(~ t.a)  i.a  ::NOTE  avoiding tmi
  $(a t.a)
::
++  reel                                                ::  right fold
  ~/  %reel
  |*  [a=(list) b=_=>(~ |=([* *] +<+))]
  |-  ^+  ,.+<+.b
  ?~  a
    +<+.b
  (b i.a $(a t.a))
::
++  roll                                                ::  left fold
  ~/  %roll
  |*  [a=(list) b=_=>(~ |=([* *] +<+))]
  |-  ^+  ,.+<+.b
  ?~  a
    +<+.b
  $(a t.a, b b(+<+ (b i.a +<+.b)))
::
++  scag                                                ::  prefix
  ~/  %scag
  |*  [a=@ b=(list)]
  |-  ^+  b
  ?:  |(?=(~ b) =(0 a))  ~
  [i.b $(b t.b, a (dec a))]
::
++  skid                                                ::  separate
  ~/  %skid
  |*  [a=(list) b=$-(* ?)]
  |-  ^+  [p=a q=a]
  ?~  a  [~ ~]
  =+  c=$(a t.a)
  ?:((b i.a) [[i.a p.c] q.c] [p.c [i.a q.c]])
::
++  skim                                                ::  only
  ~/  %skim
  |*  [a=(list) b=$-(* ?)]
  |-
  ^+  a
  ?~  a  ~
  ?:((b i.a) [i.a $(a t.a)] $(a t.a))
::
++  skip                                                ::  except
  ~/  %skip
  |*  [a=(list) b=$-(* ?)]
  |-
  ^+  a
  ?~  a  ~
  ?:((b i.a) $(a t.a) [i.a $(a t.a)])
::
++  slag                                                ::  suffix
  ~/  %slag
  |*  [a=@ b=(list)]
  |-  ^+  b
  ?:  =(0 a)  b
  ?~  b  ~
  $(b t.b, a (dec a))
::
++  snag                                                ::  index
  ~/  %snag
  |*  [a=@ b=(list)]
  |-  ^+  ?>(?=(^ b) i.b)
  ?~  b
    ~_  leaf+"snag-fail"
    !!
  ?:  =(0 a)  i.b
  $(b t.b, a (dec a))
::
++  snip                                                ::  drop tail off list
  ~/  %snip
  |*  a=(list)
  ^+  a
  ?~  a  ~
  ?:  =(~ t.a)  ~
  [i.a $(a t.a)]
::
++  sort  !.                                            ::  quicksort
  ~/  %sort
  |*  [a=(list) b=$-([* *] ?)]
  =>  .(a ^.(homo a))
  |-  ^+  a
  ?~  a  ~
  =+  s=(skid t.a |:(c=i.a (b c i.a)))
  %+  weld
    $(a p.s)
  ^+  t.a
  [i.a $(a q.s)]
::
++  spin                                                ::  stateful turn
  ::
  ::  a: list
  ::  b: state
  ::  c: gate from list-item and state to product and new state
  ~/  %spin
  |*  [a=(list) b=* c=_|=(^ [** +<+])]
  =>  .(c `$-([_?>(?=(^ a) i.a) _b] [_-:(c) _b])`c)
  =/  acc=(list _-:(c))  ~
  ::  transformed list and updated state
  |-  ^-  (pair _acc _b)
  ?~  a
    [(flop acc) b]
  =^  res  b  (c i.a b)
  $(acc [res acc], a t.a)
::
++  spun                                                ::  internal spin
  ::
  ::  a: list
  ::  b: gate from list-item and state to product and new state
  ~/  %spun
  |*  [a=(list) b=_|=(^ [** +<+])]
  ::  transformed list
  p:(spin a +<+.b b)
::
++  swag                                                ::  slice
  |*  [[a=@ b=@] c=(list)]
  (scag +<-> (slag +<-< c))
::  +turn: transform each value of list :a using the function :b
::
++  turn
  ~/  %turn
  |*  [a=(list) b=gate]
  =>  .(a (homo a))
  ^-  (list _?>(?=(^ a) (b i.a)))
  |-
  ?~  a  ~
  [i=(b i.a) t=$(a t.a)]
::
++  weld                                                ::  concatenate
  ~/  %weld
  |*  [a=(list) b=(list)]
  =>  .(a ^.(homo a), b ^.(homo b))
  |-  ^+  b
  ?~  a  b
  [i.a $(a t.a)]
::
++  snap                                               ::  replace item
  ~/  %snap
  |*  [a=(list) b=@ c=*]
  ^+  a
  (weld (scag b a) [c (slag +(b) a)])
::
++  into                                               ::  insert item
  ~/  %into
  |*  [a=(list) b=@ c=*]
  ^+  a
  (weld (scag b a) [c (slag b a)])
::
++  welp                                                ::  faceless weld
  ~/  %welp
  =|  [* *]
  |@
  ++  $
    ?~  +<-
      +<-(. +<+)
    +<-(+ $(+<- +<->))
  --
::
++  zing                                                ::  promote
  ~/  %zing
  =|  *
  |@
  ++  $
    ?~  +<
      +<
    (welp +<- $(+< +<+))
  --
::                                                      ::
::::  2c: bit arithmetic                                ::
  ::                                                    ::
  ::
++  bex                                                 ::  binary exponent
  ~/  %bex
  |=  a=bloq
  ^-  @
  ?:  =(0 a)  1
  (mul 2 $(a (dec a)))
::
++  can                                                 ::  assemble
  ~/  %can
  |=  [a=bloq b=(list [p=step q=@])]
  ^-  @
  ?~  b  0
  (add (end [a p.i.b] q.i.b) (lsh [a p.i.b] $(b t.b)))
::
++  cat                                                 ::  concatenate
  ~/  %cat
  |=  [a=bloq b=@ c=@]
  (add (lsh [a (met a b)] c) b)
::
++  cut                                                 ::  slice
  ~/  %cut
  |=  [a=bloq [b=step c=step] d=@]
  (end [a c] (rsh [a b] d))
::
++  end                                                 ::  tail
  ~/  %end
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (mod b (bex (mul (bex bloq) step)))
::
++  fil                                                 ::  fill bloqstream
  ~/  %fil
  |=  [a=bloq b=step c=@]
  =|  n=@ud
  =.  c  (end a c)
  =/  d  c
  |-  ^-  @
  ?:  =(n b)
    (rsh a d)
  $(d (add c (lsh a d)), n +(n))
::
++  lsh                                                 ::  left-shift
  ~/  %lsh
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (mul b (bex (mul (bex bloq) step)))
::
++  met                                                 ::  measure
  ~/  %met
  |=  [a=bloq b=@]
  ^-  @
  =+  c=0
  |-
  ?:  =(0 b)  c
  $(b (rsh a b), c +(c))
::
++  rap                                                 ::  assemble variable
  ~/  %rap
  |=  [a=bloq b=(list @)]
  ^-  @
  ?~  b  0
  (cat a i.b $(b t.b))
::
++  rep                                                 ::  assemble fixed
  ~/  %rep
  |=  [a=bite b=(list @)]
  =/  [=bloq =step]  ?^(a a [a *step])
  =|  i=@ud
  |-  ^-  @
  ?~  b   0
  %+  add  $(i +(i), b t.b)
  (lsh [bloq (mul step i)] (end [bloq step] i.b))
::
++  rev
  ::  reverses block order, accounting for leading zeroes
  ::
  ::  boz: block size
  ::  len: size of dat, in boz
  ::  dat: data to flip
  ~/  %rev
  |=  [boz=bloq len=@ud dat=@]
  ^-  @
  =.  dat  (end [boz len] dat)
  %+  lsh
    [boz (sub len (met boz dat))]
  (swp boz dat)
::
++  rip                                                 ::  disassemble
  ~/  %rip
  |=  [a=bite b=@]
  ^-  (list @)
  ?:  =(0 b)  ~
  [(end a b) $(b (rsh a b))]
::
++  rsh                                                 ::  right-shift
  ~/  %rsh
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (div b (bex (mul (bex bloq) step)))
::
++  run                                                 ::  +turn into atom
  ~/  %run
  |=  [a=bite b=@ c=$-(@ @)]
  (rep a (turn (rip a b) c))
::
++  rut                                                 ::  +turn into list
  ~/  %rut
  |*  [a=bite b=@ c=$-(@ *)]
  (turn (rip a b) c)
::
++  sew                                                 ::  stitch into
  ~/  %sew
  |=  [a=bloq [b=step c=step d=@] e=@]
  ^-  @
  %+  add
    (can a b^e c^d ~)
  =/  f  [a (add b c)]
  (lsh f (rsh f e))
::
++  swp                                                 ::  naive rev bloq order
  ~/  %swp
  |=  [a=bloq b=@]
  (rep a (flop (rip a b)))
::
++  xeb                                                 ::  binary logarithm
  ~/  %xeb
  |=  a=@
  ^-  @
  (met 0 a)
::
++  fe                                                  ::  modulo bloq
  |_  a=bloq
  ++  dif                                               ::  difference
    |=([b=@ c=@] (sit (sub (add out (sit b)) (sit c))))
  ++  inv  |=(b=@ (sub (dec out) (sit b)))              ::  inverse
  ++  net  |=  b=@  ^-  @                               ::  flip byte endianness
           =>  .(b (sit b))
           ?:  (lte a 3)
             b
           =+  c=(dec a)
           %+  con
             (lsh c $(a c, b (cut c [0 1] b)))
           $(a c, b (cut c [1 1] b))
  ++  out  (bex (bex a))                                ::  mod value
  ++  rol  |=  [b=bloq c=@ d=@]  ^-  @                  ::  roll left
           =+  e=(sit d)
           =+  f=(bex (sub a b))
           =+  g=(mod c f)
           (sit (con (lsh [b g] e) (rsh [b (sub f g)] e)))
  ++  ror  |=  [b=bloq c=@ d=@]  ^-  @                  ::  roll right
           =+  e=(sit d)
           =+  f=(bex (sub a b))
           =+  g=(mod c f)
           (sit (con (rsh [b g] e) (lsh [b (sub f g)] e)))
  ++  sum  |=([b=@ c=@] (sit (add b c)))                ::  wrapping add
  ++  sit  |=(b=@ (end a b))                            ::  enforce modulo
  --
::
::::  2p: serialization                                 ::
  ::                                                    ::
  ::
++  cue                                                 ::  unpack
  ~/  %cue
  |=  a=@
  ^-  *
  =+  b=0
  =+  m=`(map @ *)`~
  =<  q
  |-  ^-  [p=@ q=* r=(map @ *)]
  ?:  =(0 (cut 0 [b 1] a))
    =+  c=(rub +(b) a)
    [+(p.c) q.c (~(put by m) b q.c)]
  =+  c=(add 2 b)
  ?:  =(0 (cut 0 [+(b) 1] a))
    =+  u=$(b c)
    =+  v=$(b (add p.u c), m r.u)
    =+  w=[q.u q.v]
    [(add 2 (add p.u p.v)) w (~(put by r.v) b w)]
  =+  d=(rub c a)
  [(add 2 p.d) (need (~(get by m) q.d)) m]
::
++  jam                                                 ::  pack
  ~/  %jam
  |=  a=*
  ^-  @
  =+  b=0
  =+  m=`(map * @)`~
  =<  q
  |-  ^-  [p=@ q=@ r=(map * @)]
  =+  c=(~(get by m) a)
  ?~  c
    =>  .(m (~(put by m) a b))
    ?:  ?=(@ a)
      =+  d=(mat a)
      [(add 1 p.d) (lsh 0 q.d) m]
    =>  .(b (add 2 b))
    =+  d=$(a -.a)
    =+  e=$(a +.a, b (add b p.d), m r.d)
    [(add 2 (add p.d p.e)) (mix 1 (lsh [0 2] (cat 0 q.d q.e))) r.e]
  ?:  ?&(?=(@ a) (lte (met 0 a) (met 0 u.c)))
    =+  d=(mat a)
    [(add 1 p.d) (lsh 0 q.d) m]
  =+  d=(mat u.c)
  [(add 2 p.d) (mix 3 (lsh [0 2] q.d)) m]
::
++  mat                                                 ::  length-encode
  ~/  %mat
  |=  a=@
  ^-  [p=@ q=@]
  ?:  =(0 a)
    [1 1]
  =+  b=(met 0 a)
  =+  c=(met 0 b)
  :-  (add (add c c) b)
  (cat 0 (bex c) (mix (end [0 (dec c)] b) (lsh [0 (dec c)] a)))
::
++  rub                                                 ::  length-decode
  ~/  %rub
  |=  [a=@ b=@]
  ^-  [p=@ q=@]
  =+  ^=  c
      =+  [c=0 m=(met 0 b)]
      |-  ?<  (gth c m)
      ?.  =(0 (cut 0 [(add a c) 1] b))
        c
      $(c +(c))
  ?:  =(0 c)
    [1 0]
  =+  d=(add a +(c))
  =+  e=(add (bex (dec c)) (cut 0 [d (dec c)] b))
  [(add (add c c) e) (cut 0 [(add d (dec c)) e] b)]
::                                                      ::
::::  3d: SHA hash family                               ::
  ::                                                    ::
  ::
++  shad  |=(ruz=@ (shax (shax ruz)))                   ::  double sha-256
++  shaf                                                ::  half sha-256
  |=  [sal=@ ruz=@]
  =+  haz=(shas sal ruz)
  (mix (end 7 haz) (rsh 7 haz))
::
++  sham                                                ::  128bit noun hash
  |=  yux=*  ^-  @uvH  ^-  @
  ?@  yux
    (shaf %mash yux)
  (shaf %sham (jam yux))
::
++  shas                                                ::  salted hash
  ~/  %shas
  |=  [sal=@ ruz=@]
  (shax (mix sal (shax ruz)))
::
++  shax                                                ::  sha-256
  ~/  %shax
  |=  ruz=@  ^-  @
  (shay [(met 3 ruz) ruz])
::
++  shay                                                ::  sha-256 with length
  ~/  %shay
  |=  [len=@u ruz=@]  ^-  @
  =>  .(ruz (cut 3 [0 len] ruz))
  =+  [few==>(fe .(a 5)) wac=|=([a=@ b=@] (cut 5 [a 1] b))]
  =+  [sum=sum.few ror=ror.few net=net.few inv=inv.few]
  =+  ral=(lsh [0 3] len)
  =+  ^=  ful
      %+  can  0
      :~  [ral ruz]
          [8 128]
          [(mod (sub 960 (mod (add 8 ral) 512)) 512) 0]
          [64 (~(net fe 6) ral)]
      ==
  =+  lex=(met 9 ful)
  =+  ^=  kbx  0xc671.78f2.bef9.a3f7.a450.6ceb.90be.fffa.
                 8cc7.0208.84c8.7814.78a5.636f.748f.82ee.
                 682e.6ff3.5b9c.ca4f.4ed8.aa4a.391c.0cb3.
                 34b0.bcb5.2748.774c.1e37.6c08.19a4.c116.
                 106a.a070.f40e.3585.d699.0624.d192.e819.
                 c76c.51a3.c24b.8b70.a81a.664b.a2bf.e8a1.
                 9272.2c85.81c2.c92e.766a.0abb.650a.7354.
                 5338.0d13.4d2c.6dfc.2e1b.2138.27b7.0a85.
                 1429.2967.06ca.6351.d5a7.9147.c6e0.0bf3.
                 bf59.7fc7.b003.27c8.a831.c66d.983e.5152.
                 76f9.88da.5cb0.a9dc.4a74.84aa.2de9.2c6f.
                 240c.a1cc.0fc1.9dc6.efbe.4786.e49b.69c1.
                 c19b.f174.9bdc.06a7.80de.b1fe.72be.5d74.
                 550c.7dc3.2431.85be.1283.5b01.d807.aa98.
                 ab1c.5ed5.923f.82a4.59f1.11f1.3956.c25b.
                 e9b5.dba5.b5c0.fbcf.7137.4491.428a.2f98
  =+  ^=  hax  0x5be0.cd19.1f83.d9ab.9b05.688c.510e.527f.
                 a54f.f53a.3c6e.f372.bb67.ae85.6a09.e667
  =+  i=0
  |-  ^-  @
  ?:  =(i lex)
    (run 5 hax net)
  =+  ^=  wox
      =+  dux=(cut 9 [i 1] ful)
      =+  wox=(run 5 dux net)
      =+  j=16
      |-  ^-  @
      ?:  =(64 j)
        wox
      =+  :*  l=(wac (sub j 15) wox)
              m=(wac (sub j 2) wox)
              n=(wac (sub j 16) wox)
              o=(wac (sub j 7) wox)
          ==
      =+  x=:(mix (ror 0 7 l) (ror 0 18 l) (rsh [0 3] l))
      =+  y=:(mix (ror 0 17 m) (ror 0 19 m) (rsh [0 10] m))
      =+  z=:(sum n x o y)
      $(wox (con (lsh [5 j] z) wox), j +(j))
  =+  j=0
  =+  :*  a=(wac 0 hax)
          b=(wac 1 hax)
          c=(wac 2 hax)
          d=(wac 3 hax)
          e=(wac 4 hax)
          f=(wac 5 hax)
          g=(wac 6 hax)
          h=(wac 7 hax)
      ==
  |-  ^-  @
  ?:  =(64 j)
    %=  ^$
      i  +(i)
      hax  %+  rep  5
           :~  (sum a (wac 0 hax))
               (sum b (wac 1 hax))
               (sum c (wac 2 hax))
               (sum d (wac 3 hax))
               (sum e (wac 4 hax))
               (sum f (wac 5 hax))
               (sum g (wac 6 hax))
               (sum h (wac 7 hax))
           ==
    ==
  =+  l=:(mix (ror 0 2 a) (ror 0 13 a) (ror 0 22 a))    ::  s0
  =+  m=:(mix (dis a b) (dis a c) (dis b c))            ::  maj
  =+  n=(sum l m)                                       ::  t2
  =+  o=:(mix (ror 0 6 e) (ror 0 11 e) (ror 0 25 e))    ::  s1
  =+  p=(mix (dis e f) (dis (inv e) g))                 ::  ch
  =+  q=:(sum h o p (wac j kbx) (wac j wox))            ::  t1
  $(j +(j), a (sum q n), b a, c b, d c, e (sum d q), f e, g f, h g)
::
++  shaw                                                ::  hash to nbits
  |=  [sal=@ len=@ ruz=@]
  (~(raw og (shas sal (mix len ruz))) len)
::
++  shaz                                                ::  sha-512
  |=  ruz=@  ^-  @
  (shal [(met 3 ruz) ruz])
::
++  shal                                                ::  sha-512 with length
  ~/  %shal
  |=  [len=@ ruz=@]  ^-  @
  =>  .(ruz (cut 3 [0 len] ruz))
  =+  [few==>(fe .(a 6)) wac=|=([a=@ b=@] (cut 6 [a 1] b))]
  =+  [sum=sum.few ror=ror.few net=net.few inv=inv.few]
  =+  ral=(lsh [0 3] len)
  =+  ^=  ful
      %+  can  0
      :~  [ral ruz]
          [8 128]
          [(mod (sub 1.920 (mod (add 8 ral) 1.024)) 1.024) 0]
          [128 (~(net fe 7) ral)]
      ==
  =+  lex=(met 10 ful)
  =+  ^=  kbx  0x6c44.198c.4a47.5817.5fcb.6fab.3ad6.faec.
                 597f.299c.fc65.7e2a.4cc5.d4be.cb3e.42b6.
                 431d.67c4.9c10.0d4c.3c9e.be0a.15c9.bebc.
                 32ca.ab7b.40c7.2493.28db.77f5.2304.7d84.
                 1b71.0b35.131c.471b.113f.9804.bef9.0dae.
                 0a63.7dc5.a2c8.98a6.06f0.67aa.7217.6fba.
                 f57d.4f7f.ee6e.d178.eada.7dd6.cde0.eb1e.
                 d186.b8c7.21c0.c207.ca27.3ece.ea26.619c.
                 c671.78f2.e372.532b.bef9.a3f7.b2c6.7915.
                 a450.6ceb.de82.bde9.90be.fffa.2363.1e28.
                 8cc7.0208.1a64.39ec.84c8.7814.a1f0.ab72.
                 78a5.636f.4317.2f60.748f.82ee.5def.b2fc.
                 682e.6ff3.d6b2.b8a3.5b9c.ca4f.7763.e373.
                 4ed8.aa4a.e341.8acb.391c.0cb3.c5c9.5a63.
                 34b0.bcb5.e19b.48a8.2748.774c.df8e.eb99.
                 1e37.6c08.5141.ab53.19a4.c116.b8d2.d0c8.
                 106a.a070.32bb.d1b8.f40e.3585.5771.202a.
                 d699.0624.5565.a910.d192.e819.d6ef.5218.
                 c76c.51a3.0654.be30.c24b.8b70.d0f8.9791.
                 a81a.664b.bc42.3001.a2bf.e8a1.4cf1.0364.
                 9272.2c85.1482.353b.81c2.c92e.47ed.aee6.
                 766a.0abb.3c77.b2a8.650a.7354.8baf.63de.
                 5338.0d13.9d95.b3df.4d2c.6dfc.5ac4.2aed.
                 2e1b.2138.5c26.c926.27b7.0a85.46d2.2ffc.
                 1429.2967.0a0e.6e70.06ca.6351.e003.826f.
                 d5a7.9147.930a.a725.c6e0.0bf3.3da8.8fc2.
                 bf59.7fc7.beef.0ee4.b003.27c8.98fb.213f.
                 a831.c66d.2db4.3210.983e.5152.ee66.dfab.
                 76f9.88da.8311.53b5.5cb0.a9dc.bd41.fbd4.
                 4a74.84aa.6ea6.e483.2de9.2c6f.592b.0275.
                 240c.a1cc.77ac.9c65.0fc1.9dc6.8b8c.d5b5.
                 efbe.4786.384f.25e3.e49b.69c1.9ef1.4ad2.
                 c19b.f174.cf69.2694.9bdc.06a7.25c7.1235.
                 80de.b1fe.3b16.96b1.72be.5d74.f27b.896f.
                 550c.7dc3.d5ff.b4e2.2431.85be.4ee4.b28c.
                 1283.5b01.4570.6fbe.d807.aa98.a303.0242.
                 ab1c.5ed5.da6d.8118.923f.82a4.af19.4f9b.
                 59f1.11f1.b605.d019.3956.c25b.f348.b538.
                 e9b5.dba5.8189.dbbc.b5c0.fbcf.ec4d.3b2f.
                 7137.4491.23ef.65cd.428a.2f98.d728.ae22
  =+  ^=  hax  0x5be0.cd19.137e.2179.1f83.d9ab.fb41.bd6b.
                 9b05.688c.2b3e.6c1f.510e.527f.ade6.82d1.
                 a54f.f53a.5f1d.36f1.3c6e.f372.fe94.f82b.
                 bb67.ae85.84ca.a73b.6a09.e667.f3bc.c908
  =+  i=0
  |-  ^-  @
  ?:  =(i lex)
    (run 6 hax net)
  =+  ^=  wox
      =+  dux=(cut 10 [i 1] ful)
      =+  wox=(run 6 dux net)
      =+  j=16
      |-  ^-  @
      ?:  =(80 j)
        wox
      =+  :*  l=(wac (sub j 15) wox)
              m=(wac (sub j 2) wox)
              n=(wac (sub j 16) wox)
              o=(wac (sub j 7) wox)
          ==
      =+  x=:(mix (ror 0 1 l) (ror 0 8 l) (rsh [0 7] l))
      =+  y=:(mix (ror 0 19 m) (ror 0 61 m) (rsh [0 6] m))
      =+  z=:(sum n x o y)
      $(wox (con (lsh [6 j] z) wox), j +(j))
  =+  j=0
  =+  :*  a=(wac 0 hax)
          b=(wac 1 hax)
          c=(wac 2 hax)
          d=(wac 3 hax)
          e=(wac 4 hax)
          f=(wac 5 hax)
          g=(wac 6 hax)
          h=(wac 7 hax)
      ==
  |-  ^-  @
  ?:  =(80 j)
    %=  ^$
      i  +(i)
      hax  %+  rep  6
           :~  (sum a (wac 0 hax))
               (sum b (wac 1 hax))
               (sum c (wac 2 hax))
               (sum d (wac 3 hax))
               (sum e (wac 4 hax))
               (sum f (wac 5 hax))
               (sum g (wac 6 hax))
               (sum h (wac 7 hax))
           ==
    ==
  =+  l=:(mix (ror 0 28 a) (ror 0 34 a) (ror 0 39 a))   ::  S0
  =+  m=:(mix (dis a b) (dis a c) (dis b c))            ::  maj
  =+  n=(sum l m)                                       ::  t2
  =+  o=:(mix (ror 0 14 e) (ror 0 18 e) (ror 0 41 e))   ::  S1
  =+  p=(mix (dis e f) (dis (inv e) g))                 ::  ch
  =+  q=:(sum h o p (wac j kbx) (wac j wox))            ::  t1
  $(j +(j), a (sum q n), b a, c b, d c, e (sum d q), f e, g f, h g)
::
++  og                                                  ::  shax-powered rng
  ~/  %og
  |_  a=@
  ++  rad                                               ::  random in range
    |=  b=@  ^-  @
    ~_  leaf+"rad-zero"
    ?<  =(0 b)
    =+  c=(raw (met 0 b))
    ?:((lth c b) c $(a +(a)))
  ::
  ++  rads                                              ::  random continuation
    |=  b=@
    =+  r=(rad b)
    [r +>.$(a (shas %og-s (mix a r)))]
  ::
  ++  raw                                               ::  random bits
    ~/  %raw
    |=  b=@  ^-  @
    %+  can
      0
    =+  c=(shas %og-a (mix b a))
    |-  ^-  (list [@ @])
    ?:  =(0 b)
      ~
    =+  d=(shas %og-b (mix b (mix a c)))
    ?:  (lth b 256)
      [[b (end [0 b] d)] ~]
    [[256 d] $(c d, b (sub b 256))]
  ::
  ++  raws                                              ::  random bits
    |=  b=@                                             ::  continuation
    =+  r=(raw b)
    [r +>.$(a (shas %og-s (mix a r)))]
  --
--
