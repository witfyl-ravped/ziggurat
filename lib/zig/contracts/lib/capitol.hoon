::  /+  *zig-sys-smart
|%
+$  sig       [p=@ux q=ship r=@ud]
+$  ziggurat  (map ship sig)
+$  world     (map town-id=@ud council=(map ship [id sig]))
::
+$  arguments
  $%  [%init =sig town=@ud]
      [%join =sig town=@ud]
      [%exit =sig town=@ud]
      [%become-validator sig]
      [%stop-validating sig]
  ==
::
++  enjs
  =,  enjs:format
  |%
  ++  ziggurat
    |=  zig=^ziggurat
    ^-  json
    %-  pairs
    %+  turn  ~(tap by zig)
    |=  [signer=@p signature=^sig]
    [(scot %p signer) (sig signature)]
  ::
  ++  world
    |^
    |=  worl=^world
    ^-  json
    %-  pairs
    %+  turn  ~(tap by worl)
    |=  [town-id=@ud cncl=(map @p [id ^sig])]
    [(scot %ud town-id) (council cncl)]
    ::
    ++  council
      |=  council=(map @p [id ^sig])
      ^-  json
      %-  pairs
      %+  turn  ~(tap by council)
      |=  [signer-ship=@p signer-id=id signature=^sig]
      :-  (scot %p signer-ship)
      %-  pairs
      :+  [%id %s (scot %ux signer-id)]
        [%sig (sig signature)]
      ~
    --
  ::
  ++  arguments
    |=  a=^arguments
    ^-  json
    %+  frond  -.a
    ?-    -.a
        %init
      %-  pairs
      :+  [%sig (sig sig.a)]
        [%town (numb town.a)]
      ~
    ::
        %join
      %-  pairs
      :+  [%sig (sig sig.a)]
        [%town (numb town.a)]
      ~
    ::
        %exit
      %-  pairs
      :+  [%sig (sig sig.a)]
        [%town (numb town.a)]
      ~
    ::
        %become-validator
      (frond %sig (sig +.a))
    ::
        %stop-validating
      (frond %sig (sig +.a))
    ==
  ::
  ++  sig
    |=  s=^sig
    ^-  json
    %-  pairs
    :^    [%p %s (scot %ux p.s)]
        [%q %s (scot %p q.s)]
      [%r (numb r.s)]
    ~
  --
--
