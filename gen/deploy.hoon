/+  smart=zig-sys-smart
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
|^
=/  desk=path  (swag [0 3] pax)
::  parse contract code
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile (trip contract-text))
::  generate initial subject containing uHoon
=/  smart-lib=vase  ;;(vase (cue q.q.smart-lib-noun))
=/  braw=(list hoon)
  ::  compose libraries flatly against uHoon subject
  %+  turn  raw
  |=  [face=term =path]
  =/  pax  (weld desk path)
  `hoon`[%ktts face (rain pax .^(@t %cx (welp pax /hoon)))]
=/  full=hoon  [%clsg braw]
=/  full-nock=*  q:(~(mint ut p.smart-lib) %noun full)
=/  payload=vase  (slap smart-lib full)
=/  cont  (~(mint ut p:(slop smart-lib payload)) %noun contract-hoon)
=/  perfect  .*([q.smart-lib q.payload] q.cont)
=/  dor  [-:!>(*contract:smart) perfect]
::
:-  %noun
^-  wheat:smart
[`[bat=q.cont pay=full-nock] ~]
::
++  shut                                               ::  slam a door
  |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
  ^-  vase
  %+  slap
    (slop dor (slop dor-sam arm-sam))
  ^-  hoon
  :-  %cnsg
  :^    [%$ ~]
      [%cnsg [arm ~] [%$ 2] [%$ 6] ~]  ::  replace sample
    [%$ 7]
  ~
::
::  parser helpers
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
++  rune
  |*  [bus=rule fel=rule]
  %-  pant
  %+  mast  gap
  ;~(pfix fas bus gap fel)
++  pant
  |*  fel=rule
  ;~(pose fel (easy ~))
++  mast
  |*  [bus=rule fel=rule]
  ;~(sfix (more bus fel) bus)
--
