/-  *zink
/+  *zink-pedersen
=>  |%
    +$  good      (unit *)
    +$  fail      (list [@ta *])
    +$  body      (each good fail)
    +$  cache     (map * phash)
    +$  appendix  [cax=cache hit=hints bud=@ tep=@]
    +$  book      (pair body appendix)
    --
|%
++  zebra                                                 ::  bounded zk +mule
  |=  [bud=@ud cax=cache [s=* f=*]]
  ^-  book
  %.  [s f]
  %*  .  zink
    app  [cax ~ bud 0]
  ==
::
++  hash
  |=  [n=* cax=(map * phash)]
  ^-  phash
  ?@  n
    ?:  (lte n 12)
      =/  ch  (~(get by cax) n)
      ?^  ch  u.ch
      (hash:pedersen n 0)
    (hash:pedersen n 0)
  ?^  ch=(~(get by cax) n)
    u.ch
  =/  hh  $(n -.n)
  =/  ht  $(n +.n)
  (hash:pedersen hh ht)
::
++  constrain
  |=  =hints
  ^-  [(unit thee-hint) ?]
  |^
  =/  b=?  %.y
  =/  hit  hints
  =/  i  0
  |-
  ?~  hit
    `b
  =*  the  i.hit
  =^  res  b
    (deep the)
  ?.  b  `b
  ::  TODO: branch off
  =.  b
    (broad res)
  $(hit t.hit, i +(i))
  ::
  ::  +broad: verify constraints across instructions in the list
  ++  broad
    |=  hin=(unit thee-hint)
    ?~  hin
      %.y
    %.n
  ::
  ::  +deep: verify constraints across instructions in the tree
  ++  deep
    |=  the=thee
    ^-  [(unit thee-hint) ?]
    ?~  the
      [~ %.y]
    ?-    -.the
        %0
      ::  TODO: verify
      [`the %.y]
    ::
        %1
      ::  TODO: verify
      [`the %.y]
    ::
        %2
      ::  TODO: verify
      =/  vf1
        (constrain f1.the)
      =/  vf2
        (constrain f2.the)
      [`the %.y]
    ::
        %cons
      ::  TODO: verify
      [`the %.y]
    ==
  --
::
++  pedometer
  |=  [tep=@ hin=thee-hint]
  ^-  @
  .+
  ?-    -.hin
    ?(%0 %1)  tep
  ::
      %2
    %+  add  tep
    %+  add  f1step.hin
    f2step.hin
  ::
      %cons
    %+  add  tep
    %+  add  f1step.hin
    f2step.hin
  ==
::
::++  create-hints
::  |=  [n=^ h=hints cax=cache]
::  ^-  json
::  =/  hs  (hash -.n cax)
::  =/  hf  (hash +.n cax)
::  %-  pairs:enjs:format
::  :~  hints+(hints:enjs h)
::      subject+s+(num:enjs hs)
::      formula+s+(num:enjs hf)
::  ==
::
++  zink
  =|  appendix
  =*  app  -
  =|  trace=fail
  |=  [s=* f=*]
  ^-  book
  |^
  |-
  ?+    f
    ~&  f
    [%|^trace app]
  ::
      [^ *]
    =/  old-hit  hit
    =/  old-tep  tep
    =^  hed=body  app
      $(f -.f, hit ~)
    ?:  ?=(%| -.hed)  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  hedp=(unit phash)  app  (hash u.p.hed)
    ?~  hedp  [%&^~ app]
    =/  hed-hit  hit
    =/  hed-tep  tep
    =^  tal=body  app
      $(f +.f, hit ~)
    ?:  ?=(%| -.tal)  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    =^  talp=(unit phash)  app  (hash u.p.tal)
    ?~  talp  [%&^~ app]
    =*  tal-hit  hit
    =*  tal-tep  tep
    =^  hhed=(unit phash)  app  (hash -.f)
    ?~  hhed  [%&^~ app]
    =^  htal=(unit phash)  app  (hash +.f)
    ?~  htal  [%&^~ app]
    :-  [%& ~ u.p.hed^u.p.tal]
    =+  [%cons u.hhed u.htal u.hedp u.talp hed-hit tal-hit hed-tep tal-tep]
    %_    app
      hit  [- old-hit]
      tep  (pedometer old-tep -)
    ==
  ::
      [%0 axis=@]
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  [%&^~ app]
    ?~  u.part  [%|^trace app]
    =^  hpart=(unit phash)         app  (hash u.u.part)
    ?~  hpart  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs s axis.f)
    ?~  hsibs  [%&^~ app]
    :-  [%& ~ u.u.part]
    =+  [%0 axis.f u.hpart u.hsibs]
    app(hit -^hit, tep 1)
  ::
      [%1 const=*]
    =^  hres=(unit phash)  app  (hash const.f)
    ?~  hres  [%&^~ app]
    :-  [%& ~ const.f]
    =+  [%1 u.hres]
    app(hit -^hit, tep 1)
  ::
      [%2 sub=* for=*]
    =^  hsub=(unit phash)  app  (hash sub.f)
    ?~  hsub  [%&^~ app]
    =^  hfor=(unit phash)  app  (hash for.f)
    ?~  hfor  [%&^~ app]
    =/  old-hit  hit
    =/  old-tep  tep
    =^  subject=body  app
      $(f sub.f, hit ~)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  hsubp=(unit phash)  app  (hash u.p.subject)
    ?~  hsubp  [%&^~ app]
    =/  sub-hit  hit
    =/  sub-tep  tep
    =^  formula=body  app
      $(f for.f, hit ~)
    ?:  ?=(%| -.formula)  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    =*  for-hit  hit
    =*  for-tep  tep
    =^  hforp=(unit phash)  app  (hash u.p.formula)
    ?~  hforp  [%&^~ app]
    =^  hres=(unit phash)  app  (hash [u.p.subject u.p.formula])
    ?~  hres  [%&^~ app]
    =+  [%2 u.hsub u.hfor u.hsubp u.hforp u.hres sub-hit for-hit sub-tep for-tep]
    %_  $
      s    u.p.subject
      f    u.p.formula
      hit  -^old-hit
      tep  (pedometer old-tep -)
    ==
  ==
  ::
  ++  frag
    |=  [axis=@ noun=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(0 axis)  [`~ bud]
    |-  ^-  [(unit (unit)) @ud]
    ?:  =(0 bud)  [~ bud]
    ?:  =(1 axis)  [``noun (dec bud)]
    ?@  noun  [`~ (dec bud)]
    =/  pick  (cap axis)
    %=  $
      axis  (mas axis)
      noun  ?-(pick %2 -.noun, %3 +.noun)
      bud   (dec bud)
    ==
  ::
  ++  edit
    |=  [axis=@ target=* value=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(1 axis)  [``value bud]
    ?@  target  [`~ bud]
    ?:  =(0 bud)  [~ bud]
    =/  pick  (cap axis)
    =^  mutant  bud
      %=  $
        axis    (mas axis)
        target  ?-(pick %2 -.target, %3 +.target)
        bud     (dec bud)
      ==
    ?~  mutant  [~ bud]
    ?~  u.mutant  [`~ bud]
    ?-  pick
      %2  [``[u.u.mutant +.target] bud]
      %3  [``[-.target u.u.mutant] bud]
    ==
  ::
  ++  hash
    |=  n=*
    ^-  [(unit phash) appendix]
    =/  mh  (~(get by cax) n)
    ?^  mh
      ?:  =(bud 0)  [~ app]
      [mh app(bud (dec bud))]
    ?@  n
      ?:  =(bud 0)  [~ app]
      =/  h  (hash:pedersen n 0)
      :-  `h
      app(cax (~(put by cax) n h), bud (dec bud))
    =^  hh=(unit phash)  app  $(n -.n)
    ?~  hh  [~ app]
    =^  ht=(unit phash)  app  $(n +.n)
    ?~  ht  [~ app]
    =/  h  (hash:pedersen u.hh u.ht)
    ?:  =(bud 0)  [~ app]
    :-  `h
    app(cax (~(put by cax) n h), bud (dec bud))
  ::
  ++  merk-sibs
    |=  [s=* axis=@]
    =|  path=(list phash)
    |-  ^-  [(unit (list phash)) appendix]
    ?:  =(1 axis)
      [`path app]
    ?~  axis  !!
    ?@  s  !!
    =/  pick  (cap axis)
    =^  sibling=(unit phash)  app
      %-  hash
      ?-(pick %2 +.s, %3 -.s)
    ?~  sibling  [~ app]
    =/  child  ?-(pick %2 -.s, %3 +.s)
    %=  $
      s     child
      axis  (mas axis)
      path  [u.sibling path]
    ==
  --
--
