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
++  test-adding-member  ^-  tang
  !!
::
++  test-submitting-tx  ^-  tang
  !!
::
++  test-submitting-vote
  !!
--