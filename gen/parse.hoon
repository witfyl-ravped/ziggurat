/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
^-  *
|^
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile (trip contract-text))
~&  >  raw
::  take raw list, grab from paths, and slap.
=/  txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
=/  so-far  (slap !>(~) (ream txt))
:-  %noun
|-
?~  raw
  =+  (slap so-far contract-hoon)
  q:(slap - (ream '-'))
::  TODO make desk-agnostic
~&  "adding {<face.i.raw>}"
=+  .^(@t %cx (weld /(scot %p p.bek)/zig/(scot %da now) path.i.raw))
$(so-far (slap so-far (ream -)), raw t.raw)
::
::  this seems to work nicely for getting the contract nock. now, there's the
::  question of being able to insert the resulting battery into a matching payload
::  when a sequencer wishes to run the contract.
::
::  thoughts:
::  -  libraries can be stored on-chain as well as contracts. can even customize our
::  library parser here to grab library cores from chain addresses.
::     CONS: sequencer has to re-compile frequently, massive cost
::
::  -  we can store libraries in the contract nock.
::     PROS: all in one place, pre-compiled
::     CONS: contract data footprint goes up
::
::  -  going with second option for now, as this is closer to what we're already doing
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