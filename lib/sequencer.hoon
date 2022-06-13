/-  *sequencer, *rollup
|%
::
::  +allowed-participant: grades whether a ship is permitted to participate
::  in Uqbar validation. currently using hardcoded whitelist
::
++  allowed-participant
  |=  [=ship our=ship now=@da]
  ^-  ?
  (~(has in whitelist) ship)
++  whitelist
  ^-  (set ship)
  %-  ~(gas in *(set ship))
  :~  ::  fakeships for localhost testnets
      ~zod  ~bus  ~nec  ~wet  ~rys
      ::  hodzod's testing moons
      ~watryp-loplyd-dozzod-bacrys
      ::  hosted's testing moons
      ~ricmun-lasfer-hosted-fornet
      ::  ~littel-wolfur's
      ~harden-ripped-littel-wolfur
      ~mipber
  ==
::
++  read-grain
  |=  [=path =granary:smart]
  ^-  (unit (unit cage))
  ?>  ?=([%rice @ux ~] path)
  =/  id  (slav %ux i.t.path)
  ``noun+!>((~(get by granary) id))
::
++  read-wheat
  |=  [=path now=time town-id=id =granary:smart]
  ^-  (unit (unit cage))
  ?>  ?=([%read @ux @tas @ta ^] path)
  =/  id  (slav %ux i.t.path)
  =/  read-type  (slav %tas i.t.t.path)  ::  %json or %noun
  =/  arg=^path  [i.t.t.t.path ~]
  =/  contract-rice=(list @ux)  ::  TODO need to figure this out
    %+  turn  t.t.t.t.path
    |=(addr=@ (slav %ux addr))
  ?~  res=(~(get by granary) id)  ``noun+!>(~)
  ?.  ?=(%| -.germ.u.res)         ``noun+!>(~)
  ?~  cont.p.germ.u.res           ``noun+!>(~)
  =/  owns
    %-  ~(gas by *(map id:smart grain:smart))
    %+  murn  contract-rice
    |=  find=id:smart
    ?~  found=(~(get by granary) find)  ~
    ?.  ?=(%& -.germ.u.found)           ~
    ?.  =(lord.u.found id)              ~
    `[find u.res]
  ::  this isn't an ideal method but okay for now
  ::  goal is to return ~ if some rice weren't found
  ?.  =(~(wyt by owns) (lent contract-rice))
    ``noun+!>(~)
  ::  TODO swap this with +zebra when able?
  =/  cont  !<(contract:smart [-:!>(*contract:smart) u.cont.p.germ.u.res])
  =/  cart  [id now town-id owns]
  ?+  read-type  ``noun+!>(~)
    %noun  ``noun+!>(`~(noun ~(read cont cart) arg))
    %json  ``json+!>(`~(json ~(read cont cart) arg))
  ==
--