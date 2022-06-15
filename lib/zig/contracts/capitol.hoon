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
/=  c  /lib/zig/contracts/lib/capitol
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments:c u.args.inp) (pin caller.inp))
  ::
  ::  process a call
  ::
  ++  process
    |=  [args=arguments:c caller-id=id]
    ?-    -.args
    ::
    ::  calls to join/exit as a sequencer on a town, or make a new one
    ::
        %init
      ::  start a new town if one with if that id doesn't exist
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world:c  ;;(world:c data.p.germ.worl)
      ?:  (~(has by world) town.args)  !!
      =.  data.p.germ.worl
        (~(put by world) town.args (malt ~[[q.sig.args [caller-id sig.args]]]))
      [%& (malt ~[[id.worl worl]]) ~ ~]
    ::
        %join
      ::  become a sequencer on an existing town
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world:c  ;;(world:c data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig:c]))`(~(get by world) town.args)  !!
      =/  new  (~(put by u.current) q.sig.args [caller-id sig.args])
      =.  data.p.germ.worl
        (~(put by world) town.args new)
      [%& (malt ~[[id.worl worl]]) ~ ~]
    ::
        %exit
      ::  leave a town that you're sequencing on
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world:c  ;;(world:c data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig:c]))`(~(get by world) town.args)  !!
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
      =/  =ziggurat:c  ;;(ziggurat:c data.p.germ.zigg)
      ?<  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(put by ziggurat) q.args +.args)
      [%& (malt ~[[id.zigg zigg]]) ~ ~]
    ::
        %stop-validating
      =/  zigg=grain  (~(got by owns.cart) `@ux`'ziggurat')
      ?>  ?=(%& -.germ.zigg)
      =/  =ziggurat:c  ;;(ziggurat:c data.p.germ.zigg)
      ?>  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(del by ziggurat) q.args)
      [%& (malt ~[[id.zigg zigg]]) ~ ~]
    ==
  --
::
++  read
  |_  args=path
  ++  json
    ^-  ^json
    ?+    args  !!
        [%rice-data ~]
      ?>  =(1 ~(wyt by owns.cart))
      =/  g=grain  -:~(val by owns.cart)
      ?>  ?=(%& -.germ.g)
      ?>  ?=(^ data.p.germ.g)
      ?.  ?=([@ @ @] +.-.data.p.germ.g)
        (world:enjs:c ;;(world:c data.p.germ.g))
      (ziggurat:enjs:c ;;(ziggurat:c data.p.germ.g))
    ::
        [%egg-args @ ~]
      %-  arguments:enjs:c
      ;;(arguments:c (cue (slav %ud i.t.args)))
    ==
  ++  noun
    ~
  --
--
