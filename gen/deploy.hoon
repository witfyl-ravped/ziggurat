/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
|^
=/  desk=path  (swag [0 3] pax)
::  parse contract code
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile (trip contract-text))
::  generate initial subject containing uHoon
=/  hoon-path    (weld desk /lib/zig/sys/hoon/hoon)
=/  smart-path   (weld desk /lib/zig/sys/smart/hoon)
=/  hoon-txt     .^(@t %cx hoon-path)
=/  smart-txt    .^(@t %cx smart-path)
=/  hoon-lib     (slap !>(~) (rain hoon-path hoon-txt))
=/  smart-lib    (slap hoon-lib (rain smart-path smart-txt))
::  compose libraries flatly against uHoon subject
=/  braw=(list hoon)
  %+  turn  raw
  |=  [face=term =path]
  =/  pax  (weld desk path)
  `hoon`[%ktts face (rain pax .^(@t %cx pax))]
=/  full=hoon  [%clsg braw] ::  [%cltr (weld ~[(rain smart-path smart-txt)] braw)]
=/  payload=vase  (slap smart-lib full)
::  generate nock for each library
=/  libs=(list *)
  %+  turn  braw
  |=  gen=hoon
  =/  gun  (~(mint ut p.smart-lib) %noun gen)
  ~&  p.gun
  q.gun
=/  dumb-libs
  %+  turn  libs
  |=  lib=*
  .*(q.smart-lib lib)
=/  dumb-payload=*
  [*cart:smart [q.smart-lib dumb-libs]]
::  return contract with nock battery and payload
=/  cont  (~(mint ut p:(slop smart-lib payload)) %noun contract-hoon)
=/  perfect  .*([q.smart-lib dumb-payload] q.cont)
=/  dor  [-:!>(*contract:smart) perfect]
:-  %noun
[`[q.cont libs] ~]
::  =+  (shut dor %write !>(*cart:smart) !>(*embryo:smart))
::  ~&  p
::  q
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
