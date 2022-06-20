::
::  capitol.hoon
::
::  Contract for managing towns on the Uqbar blockchain.
::  capitol.hoon is deployed on the main chain, where
::  validators execute transactions related to town entry
::  and exit. For transactions submitted here, the sender
::  must include in each transaction a signature from the
::  Urbit star whose town status they wish to modify.
::
::  TODO: verify ship signatures!
::
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments u.args.inp) (pin caller.inp))
  ::
  ::  molds used by this contract
  ::
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
  ::  process a call
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
    ::
    ::  calls to join/exit as a sequencer on a town, or make a new one
    ::
        %init
      ::  start a new town if one with if that id doesn't exist
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  ;;(world data.p.germ.worl)
      ?:  (~(has by world) town.args)  !!
      =.  data.p.germ.worl
        (~(put by world) town.args (malt ~[[q.sig.args [caller-id sig.args]]]))
      [%& (malt ~[[id.worl worl]]) ~ ~]
    ::
        %join
      ::  become a sequencer on an existing town
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  ;;(world data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig]))`(~(get by world) town.args)  !!
      =/  new  (~(put by u.current) q.sig.args [caller-id sig.args])
      =.  data.p.germ.worl
        (~(put by world) town.args new)
      [%& (malt ~[[id.worl worl]]) ~ ~]
    ::
        %exit
      ::  leave a town that you're sequencing on
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  ;;(world data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig]))`(~(get by world) town.args)  !!
      =/  new  (~(del by u.current) q.sig.args)
      =.  data.p.germ.worl
        (~(put by world) town.args new)
      [%& (malt ~[[id.worl worl]]) ~ ~]
    ::
    ::  calls to join/exit as a validator on the main chain
    ::
        %become-validator
      =/  zigg=grain  (~(got by owns.cart) `@ux`'ziggurat')
      ?>  ?=(%& -.germ.zigg)
      =/  =ziggurat  ;;(ziggurat data.p.germ.zigg)
      ?<  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(put by ziggurat) q.args +.args)
      [%& (malt ~[[id.zigg zigg]]) ~ ~]
    ::
        %stop-validating
      =/  zigg=grain  (~(got by owns.cart) `@ux`'ziggurat')
      ?>  ?=(%& -.germ.zigg)
      =/  =ziggurat  ;;(ziggurat data.p.germ.zigg)
      ?>  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(del by ziggurat) q.args)
      [%& (malt ~[[id.zigg zigg]]) ~ ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    |^  ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?>  ?=(^ data.p.germ.g)
      ?.  ?=([@ @ @] +.-.data.p.germ.g)
        (enjs-world ;;(world data.p.germ.g))
      (enjs-ziggurat ;;(ziggurat data.p.germ.g))
    ::
        [%egg-args @ ~]
      %-  enjs-arguments
      ;;(arguments (cue (slav %ud i.t.args)))
    ==
    ::
    ++  enjs-ziggurat
      =,  enjs:format
      |=  zig=ziggurat
      ^-  ^json
      %-  pairs
      %+  turn  ~(tap by zig)
      |=  [signer=@p signature=sig]
      [(scot %p signer) (enjs-sig signature)]
    ::
    ++  enjs-world
      =,  enjs:format
      |^
      |=  worl=world
      ^-  ^json
      %-  pairs
      %+  turn  ~(tap by worl)
      |=  [town-id=@ud council=(map @p [id sig])]
      [(scot %ud town-id) (enjs-council council)]
      ::
      ++  enjs-council
        |=  council=(map @p [id sig])
        ^-  ^json
        %-  pairs
        %+  turn  ~(tap by council)
        |=  [signer-ship=@p signer-id=id signature=sig]
        :-  (scot %p signer-ship)
        %-  pairs
        :+  [%id %s (scot %ux signer-id)]
          [%sig (enjs-sig signature)]
        ~
      --
    ::
    ++  enjs-arguments
      =,  enjs:format
      |=  a=arguments
      ^-  ^json
      %+  frond  -.a
      ?-    -.a
          %init
        %-  pairs
        :+  [%sig (enjs-sig sig.a)]
          [%town (numb town.a)]
        ~
      ::
          %join
        %-  pairs
        :+  [%sig (enjs-sig sig.a)]
          [%town (numb town.a)]
        ~
      ::
          %exit
        %-  pairs
        :+  [%sig (enjs-sig sig.a)]
          [%town (numb town.a)]
        ~
      ::
          %become-validator
        (frond %sig (enjs-sig +.a))
      ::
          %stop-validating
        (frond %sig (enjs-sig +.a))
      ==
    ::
    ++  enjs-sig
      =,  enjs:format
      |=  s=sig
      ^-  ^json
      %-  pairs
      :^    [%p %s (scot %ux p.s)]
          [%q %s (scot %p q.s)]
        [%r (numb r.s)]
      ~
    ::
    ::  molds used by this contract
    ::
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
    --
  ++  noun
    ~
  --
--
