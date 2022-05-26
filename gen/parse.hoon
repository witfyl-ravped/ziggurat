/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [cont=path ~] ~]
^-  *
|^
=/  text  .^(@t %cx cont)
=/  parser
  %-  full
  ;~  plug
    %+  rune  tis
    ;~(plug sym ;~(pfix gap stap))
  ::
    %+  stag  %tssg
    (most gap tall:vast)
  ==
=/  res=parsed
  %+  parser
    [0 (met 3 text)]
  `(list @tas)`(trip text)
::~&  >  res
::  =/  smart-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
::  =/  hoon-txt  .^(@t %cx /(scot %p p.bek)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
::  =/  hoe  (slap !>(~) (ream hoon-txt))
::  =/  hoed  (slap hoe (ream smart-txt))
::  =/  contract  (slap hoed (ream text))
:-  %noun
~  ::  q:(slap contract (ream '-'))
++  parsed
  [(list [@tas path]) hoon]
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