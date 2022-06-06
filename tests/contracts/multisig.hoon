::  Test suite for multisig.hoon
::
/+  *test, cont=zig-contracts-multisig, *zig-sys-smart
=>  ::  test data
    |%
    ::  XX import these when /= drops
    +$  tx-hash   @ux
    +$  proposal  [=egg votes=(set id)]
    +$  multisig-state
      $:  members=(set id)
          threshold=@ud
          pending=(map tx-hash proposal)
      ==
    ::
    ++  town-id  1
    ::
    ++  account-1
      ^-  grain
      :*  id=0x1.beef
          lord=`@ux`'zigs'
          holder=0xbeef
          town-id
          [%& salt=`@`'zigs' data=[50 ~ `@ux`'zigs']]
      ==
    ++  owner-1  ^-  account
      [id=0xbeef nonce=0 zigs=0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'zigs'
          0xdead
          town-id
          [%& `@`'zigs' [30 ~ `@ux`'zigs']]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'zigs'
          0xcafe
          town-id
          [%& `@`'zigs' [20 ~ `@ux`'zigs']]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    ::
    ::
    ++  multisig-wheat-id  0x2222.2222
    ++  multisig-1-state
      ^-  multisig-state
      [members=(silt ~[id:owner-1]) threshold=1 pending=~]
    ++  multisig-1-grain
        ^-  grain
        :*  `@ux`'multisig-1'
            lord=multisig-wheat-id
            holder=multisig-wheat-id
            town-id
            germ=[%& salt=`@`'multisig salt' data=multisig-1-state]
        ==
    --
::  testing arms
|%
++  test-create-multisig  ^-  tang
  ::  TODO why do we have to do id:owner-1 and why cant we just do id.owner-1
  ::~!  id.owner-1 (gives unexpected type)
  =/  =embryo
    :*  caller=owner-1
        args=`[%create-multisig threshold=1 members=(silt ~[id:owner-1])]
        grains=~
    ==
  =/  =cart  [multisig-wheat-id block=0 town-id owns=~]
  =/  res=chick  (~(write cont cart) embryo)
  =*  expected-state  multisig-1-state
  =/  state
    ;;  multisig-state
    ?>  ?=(%.y -.res)
    =/  grain  (snag 0 ~(val by issued.p.res))
    ?>  ?=(%.y -.germ.grain)
    data.p.germ.grain
  (expect-eq !>(expected-state) !>(state))
::
++  test-submit-tx  ^-  tang
  =|  =egg
  =.  p.egg
    %=  p.egg
      ::  setting the from of the tx to owner-1 seems incorrect, it should prob. be the multisig addr itself
      ::  maybe the multisig contract overwrites this automatically?
      ::from     owner-1
      from     multisig-wheat-id
      to       zigs-wheat-id
      rate     10
      budget   100.000
      town-id  town-id
    ==
  =.  q.egg
    %=  q.egg
      :: setting the caller of the tx to owner-1 seems incorrect, it should prob. be the multisig addr itself
      ::caller     owner-1
      caller     multisig-wheat-id
      args       `[%give to=id:owner-3 account=`id:account-3 amount=250 budget=10.000]
      my-grains  (silt ~[id:account-1])
    ==
  =/  =embryo
    :*  caller=owner-1
        args=`[%submit-tx egg]
        grains=(malt ~[[id:multisig-1-grain multisig-1-grain]])
    ==
  =/  =cart  [me=multisig-wheat-id block=0 town-id=1 owns=(malt ~[[id:multisig-1-grain multisig-1-grain]])]
  =/  res=chick  (~(write cont cart) embryo)
  ::=/  expected-state  multisig-1-state(pending (malt ~[[egg votes=~]])) :: doesn't work due to tack error (can't lookup wing properly)
  =/  expected-state=multisig-state
    :*  members:multisig-1-state
        threshold:multisig-1-state
        pending=(malt ~[[(mug egg) [egg votes=~]]])
    ==
  =/  state=multisig-state
    ;;  multisig-state
    ?>  ?=(%.y -.res)
    =/  grain  (snag 0 ~(val by changed.p.res))
    ?>  ?=(%.y -.germ.grain)
    data.p.germ.grain
  (expect-eq !>(expected-state) !>(state))
--