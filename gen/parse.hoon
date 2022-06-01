/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [pax=path ~] ~]
^-  *
|^
=/  contract-text  .^(@t %cx pax)
=/  [raw=(list [face=term =path]) contract-hoon=hoon]  (parse-pile (trip contract-text))
~&  >  raw
::  take raw list, grab from paths, and slap.
=/  hoon-path  /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon
=/  hoon-txt  .^(@t %cx hoon-path)
=/  so-far  (slap !>(~) (rain hoon-path hoon-txt))
:-  %noun
|-
?~  raw
  =+  (slap so-far contract-hoon)
  q:(slap - (ream '-'))
::  TODO make desk-agnostic
~&  "adding {<face.i.raw>}"
::  TODO make faces real
=+  .^(@t %cx (weld /(scot %p p.bek)/zig/(scot %da now) path.i.raw))
$(so-far (slap so-far (ream -)), raw t.raw)
::
::  this seems to work nicely for getting the contract nock. now, there's the
::  question of being able to insert the resulting battery into a matching payload
::  when a sequencer wishes to run the contract.
::
::  PLAN:
::  automatically compile all contracts against hoon.hoon and smart.hoon
::  if a contract imports smart.hoon, ignore that specific /=
::  (letting them import in-file makes it easier for them to test)
::  grab all compiled nock for every real import
::  return that noun
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
