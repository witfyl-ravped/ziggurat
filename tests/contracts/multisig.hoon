::  Test suite for multisig.hoon
::
/+  *test, cont=zig-contracts-multisig, *zig-sys-smart
=>  ::  test data
    |%
    ++  account-1  ^-  grain
      :*  id=0x1.beef
          lord=`@ux`'zigs'
          holder=0xbeef
          town-id=1
          [%& salt=`@`'zigs' data=[50 ~ `@ux`'zigs']]
      ==
    ++  owner-1  ^-  account
      [id=0xbeef nonce=0 zigs=0x1234.5678]
    ::
    ++  account-2  ^-  grain
      :*  0x1.dead
          `@ux`'zigs'
          0xdead
          1
          [%& `@`'zigs' [30 ~ `@ux`'zigs']]
      ==
    ++  owner-2  ^-  account
      [0xdead 0 0x1234.5678]
    ::
    ++  account-3  ^-  grain
      :*  0x1.cafe
          `@ux`'zigs'
          0xcafe
          1
          [%& `@`'zigs' [20 ~ `@ux`'zigs']]
      ==
    ++  owner-3  ^-  account
      [0xcafe 0 0x1234.5678]
    --
::  testing arms
|%
++  test-scenario-1  ^-  tang
  =/  thresh=@ud        1
  ::~!  id.owner-1
  =/  id-owner-1  (id.owner-1)  :: wtf ???
  =/  members=(set id)  (silt ~[id-owner-1])
  =/  =embryo
    :*  caller=owner-1 
        args=`[%create-multisig thresh members]
        grains=~
    ==
  =/  =cart  [0x2222.2222 block=0 town-id=1 owns=~]
  =/  res=chick  (~(write cont cart) embryo)
  =/  expected-state
    :*  members
        thresh
        pending=~
    ==
  =/  state
    ?>  ?=(%.y -.res)
    =/  grain  (snag 0 ~(val by issued.p.res))
    ?>  ?=(%.y -.germ.grain)
    data.p.germ.grain
  (expect-eq !>(expected-state) !>(state))
::
--