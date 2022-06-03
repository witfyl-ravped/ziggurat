/+  *zink-zink
|%
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
    ~&  %cache-hit
    u.ch
  =/  hh  $(n -.n)
  =/  ht  $(n +.n)
  (hash:pedersen hh ht)
::
++  conq
  |=  [hoonlib-txt=@t smartlib-txt=@t cax=cache bud=@ud]
  ^-  (map * phash)
  |^
  =.  cax
    %-  ~(gas by cax)
    %+  turn  (gulf 0 12)
    |=  n=@
    ^-  [* phash]
    [n (hash n ~)]
  =/  hoonlib   (slap !>(~) (ream hoonlib-txt))
  =/  smartlib  (slap hoonlib (ream smartlib-txt))
  =.  cax  (cache-hoon hoonlib cax)
  =.  cax  (cache-smart smartlib cax)
  =/  gun  (~(mint ut p.smartlib) %noun (ream '~'))
  =/  =book  (zebra bud cax [q.smartlib q.gun])
  cax.q.book
  ::
  ++  cache-hoon
    |=  [hoonlib=vase cax=cache]
    ^-  (map * phash)
    =/  l=(list @t)
      :~  '..add'
          '..biff'
          '..egcd'
          '..po'
      ==
    |-
    ?~  l
      cax
    $(l t.l, cax (hash-arms-per-layer hoonlib i.l cax))
  ::
  ++  cache-smart
    |=  [smartlib=vase cax=cache]
    ^-  (map * phash)
    =/  l=(list @t)
      :~  '..fry-contract'
      ==
    |-
    ?~  l
      cax
    $(l t.l, cax (hash-arms-per-layer smartlib i.l cax))
  ::
  ++  all-arms-to-axes
    |=  vax=vase
    %-  ~(gas by *(map term @))
    %+  turn  (list-arms vax)
    |=  t=term
    [t (arm-axis vax t)]
  ::
  ++  list-arms
    |=  vax=vase
    ^-  (list term)
    (sloe p.vax)
  ::
  ++  arm-axis
    |=  [vax=vase arm=term]
    ^-  @
    =/  r  (~(find ut p.vax) %read ~[arm])
    ?>  ?=(%& -.r)
    ?>  ?=(%| -.q.p.r)
    p.q.p.r
  ::
  ++  hash-all-arms
    |=  [vax=vase cax=(map * phash)]
    ^-  (map * phash)
    =/  lis=(list term)  (list-arms vax)
    |-
    ?~  lis  cax
    =*  t  i.lis
    =/  a=@  (arm-axis vax t)
    ~&  [t a]
    =/  n  q:(slot a vax)
    $(lis t.lis, cax (~(put by cax) n (hash n cax)))
  ::
  ++  hash-arms-per-layer
    |=  [vax=vase layer=@t cax=(map * phash)]
    ^-  (map * phash)
    =/  cor  (slap vax (ream layer))
    (hash-all-arms cor cax)
  --
--
