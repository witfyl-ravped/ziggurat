/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
^-  *
|^
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile (trip contract-text))
::
=/  hoon-path    /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon
=/  smart-path   /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/smart/hoon
=/  hoon-txt     .^(@t %cx hoon-path)
=/  smart-txt    .^(@t %cx smart-path)
=/  smart-lib    (slap (slap !>(~) (rain hoon-path hoon-txt)) (rain smart-path smart-txt))
::
~&  >  raw
=/  braw=(list hoon)
  %+  turn  raw
  |=  [face=term =path]
  =/  pax  (weld /(scot %p p.bek)/zig/(scot %da now) path)
  =/  txt  .^(@t %cx pax)
  `hoon`[%ktts face (rain pax txt)]
=/  full=hoon  [%clsg (weld ~[(rain smart-path smart-txt)] braw)]
=/  background=vase  (slap smart-lib full)
::
:-  %noun
=+  (slap background contract-hoon)
q:(slap - (ream '-'))
::
::  helpers
::
+$  small-pile
    $:  raw=(list [face=term =path])
        =hoon
    ==
++  parse-pile
  |=  tex=tape
  ^-  small-pile
  =/  [=hair res=(unit [=small-pile =nail])]  (pile-rule [1 1] tex)
  ?^  res  small-pile.u.res
  %-  mean  %-  flop
  =/  lyn  p.hair
  =/  col  q.hair
  :~  leaf+"syntax error at [{<lyn>} {<col>}] in {<pax>}"
      leaf+(runt [(dec col) '-'] "^")
      leaf+(trip (snag (dec lyn) (to-wain:format (crip tex))))
  ==
++  pile-rule
  %-  full
  %+  ifix  [gay gay]
  ;~  plug
    %+  rune  tis
    ;~(plug sym ;~(pfix gap stap))
  ::
    %+  stag  %tssg
    (most gap tall:vast)
  ==
::
++  rune
  |*  [bus=rule fel=rule]
  %-  pant
  %+  mast  gap
  ;~(pfix fas bus gap fel)
::
++  pant
  |*  fel=rule
  ;~(pose fel (easy ~))
::
++  mast
  |*  [bus=rule fel=rule]
  ;~(sfix (more bus fel) bus)
--
