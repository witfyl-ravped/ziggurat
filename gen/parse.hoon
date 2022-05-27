/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
^-  *
|^
=/  text  .^(@t %cx pax)
=/  res=small-pile  (parse-pile pax (trip text))
~&  >  res
::  =/  smart-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
::  =/  hoon-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
::  =/  hoe  (slap !>(~) (ream hoon-txt))
::  =/  hoed  (slap hoe (ream smart-txt))
::  =/  contract  (slap hoed (ream text))
:-  %noun
~  ::  q:(slap contract (ream '-'))
+$  small-pile
    $:  raw=(list [face=term =path])
        =hoon
    ==
++  parse-pile
  |=  [pax=path tex=tape]
  ^-  small-pile
  =/  [=hair res=(unit [=small-pile =nail])]  (pile-rule [0 (lent tex)] tex)
  ?^  res  small-pile.u.res
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error at [{<lyn>} {<col>}] in {<pax>}"
      leaf+(trip (snag (dec lyn) (to-wain:format (crip tex))))
      leaf+(runt [(dec col) '-'] "^")
  ==
++  pile-rule
  %-  full
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