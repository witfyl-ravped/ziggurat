/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
^-  *
|^
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile pax (trip contract-text))
~&  >  raw
::  take raw list, grab from paths, and slap.
=/  txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
=/  so-far  (slap !>(~) (ream txt))
~&  >>  "so-far: {<(met 3 (jam so-far))>}"
:-  %noun
|-
?~  raw
  =+  (slap so-far contract-hoon)
  q:(slap - (ream '-'))
::  TODO make desk-agnostic
~&  "adding {<face.i.raw>}"
=+  .^(@t %cx (weld /(scot %p p.bek)/zig/(scot %da now) path.i.raw))
$(so-far (slap so-far (ream -)), raw t.raw)
::  =/  smart-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
::  =/  hoon-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
::  =/  hoe  (slap !>(~) (ream hoon-txt))
::  =/  hoed  (slap hoe (ream smart-txt))
::  =/  contract  (slap hoed (ream text))
::  q:(slap contract (ream '-'))
+$  small-pile
    $:  raw=(list [face=term =path])
        =hoon
    ==
++  parse-pile
  |=  [pax=path tex=tape]
  ^-  small-pile
  =/  [=hair res=(unit [=small-pile =nail])]  (pile-rule [1 1] tex)
  ?^  res  small-pile.u.res
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error at [{<lyn>} {<col>}] in {<pax>}"
      leaf+(trip (snag (dec lyn) (to-wain:format (crip tex))))
      leaf+(runt [(dec col) '-'] "^")
  ==
++  pile-rule
  ::  TODO do we need full parse match?? currently causes fail
  ::  %-  full
  ;~  plug
    %+  rune  tis
    ;~(plug sym ;~(pfix gap stap))
  ::
    %+  stag  %tssg
    (most gap tall:vast)
  ==
++  vest
  |=  tub=nail
  ^-  (like hoon)
  %.  tub
  %-  full
  (ifix [gay gay] tall:vast)
::
++  pant
  |*  fel=rule
  ;~(pose fel (easy ~))
::
++  mast
  |*  [bus=rule fel=rule]
  ;~(sfix (more bus fel) bus)
::
++  rune
  |*  [bus=rule fel=rule]
  %-  pant
  %+  mast  gap
  ;~(pfix fas bus gap fel)
--