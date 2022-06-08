::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple town / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated town. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
::  Tests here should cover:
::  (all calls to exclusively zigs contract)
::
::  * executing a single call with +mill
::  * executing same call unsuccessfully -- not enough gas
::  * unsuccessfully -- some constraint in contract unfulfilled
::  * (test all constraints in contract: balance, gas, +give, etc)
::  * executing multiple calls with +mill-all
::
/+  *test, mill=zig-mill, *zig-sys-smart
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
/*  zigs-contract  %noun  /lib/zig/compiled/zigs/noun
|%
++  zigs
  |%
  +$  account-mold
    $:  balance=@ud
        allowances=(map sender=id @ud)
    ==
  ++  town-id    0
  ++  set-fee    7  :: arbitrary replacement for +bull calculations
  ++  beef-zigs-grain
    ^-  grain
    :*  0x1.beef
        zigs-wheat-id
        0xbeef
        0
        [%& `@`'zigs' [300.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  dead-zigs-grain
    ^-  grain
    :*  0x1.dead
        zigs-wheat-id
        0xdead
        0
        [%& `@`'zigs' [200.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  cafe-zigs-grain
    ^-  grain
    :*  0x1.cafe
        zigs-wheat-id
        0xcafe
        0
        [%& `@`'zigs' [100.000 ~ `@ux`'zigs-metadata']]
    ==
  ++  wheat-grain
    ^-  grain
    =/  =wheat  ;;(wheat (cue q.q.zigs-contract))
    :*  zigs-wheat-id  ::  id
        zigs-wheat-id  ::  lord
        zigs-wheat-id  ::  holders
        town-id              ::  town-id
        [%| wheat(owns (silt ~[0x1.beef 0x1.dead 0x1.cafe]))]
    ==
  ++  fake-granary
    ^-  granary
    =/  grains=(list (pair id grain))
      :~  [zigs-wheat-id wheat-grain]
          [0x1.beef beef-zigs-grain]
          [0x1.dead dead-zigs-grain]
          [0x1.cafe cafe-zigs-grain]
      ==
    (~(gas by *(map id grain)) grains)
  ++  fake-populace
    ^-  populace
    %-  %~  gas  by  *(map id @ud)
    ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
  ++  fake-town
    ^-  town
    [fake-granary fake-populace]
  --
++  test-trivial-fail
  =/  mil  ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))
  =/  caller  [0xbeef 1 0x1.beef] 
  =/  yok=yolk
    [caller `[%init ~] ~ ~]
  =/  shel=shell
    [caller [0 0 0] ~ zigs-wheat-id 1 333 0 0]
  =/  egg  [shel yok]
  =/  [=town fee=@ud err=errorcode]
    %+  ~(mill mil [0xdead 1 0x1.dead] 0 1)
      fake-town:zigs
    egg
  %+  expect-eq
  !>(err)  !>(6)
::
++  test-zigs-give
  =/  mil  ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))
  =/  caller  [0xbeef 1 0x1.beef]
  =/  yok=yolk
    [caller `[%give 0xdead `0x1.dead 777 333] (silt ~[0x1.beef]) (silt ~[0x1.dead])]
  =/  shel=shell
    [caller [0 0 0] ~ zigs-wheat-id 1 500 0 0]
  =/  egg  [shel yok]
  =/  [=town fee=@ud =errorcode]
    %+  ~(mill mil [0xcafe 1 0x1.cafe] 0 1)
      fake-town:zigs
    egg
  ::  ?>  =(fee set-fee:zigs)
  ::  ?>  =(errorcode %0)
  =/  correct  dead-zigs-grain:zigs
  =.  germ.correct  [%& `@`'zigs' [200.777 ~ `@ux`'zigs-metadata']]
  %+  expect-eq
    !>((~(got by p.town) 0x1.dead))
  !>(correct)
::
++  test-single-c-call
  =/  mil  ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))
  =/  caller  [0xbeef 1 0x1.beef] 
  =/  yok=yolk
    [caller `[%give 0x1234 ~ 777 333] (silt ~[0x1.beef]) ~]
  =/  shel=shell
    [caller [0 0 0] ~ zigs-wheat-id 1 500 0 0]
  =/  egg  [shel yok]
  =/  [=town fee=@ud =errorcode]
    %+  ~(mill mil [0xcafe 1 0x1.cafe] 0 1)
      fake-town:zigs
    egg
  ::  ?>  =(fee (mul 2 set-fee:zigs))
  ::  ?>  =(errorcode %0)
  =/  correct-id  (fry-rice 0x1234 zigs-wheat-id 0 `@`'zigs')
  =/  correct
    ^-  grain
    :*  correct-id
        zigs-wheat-id
        0x1234
        0
        [%& `@`'zigs' [777 ~ `@ux`'zigs-metadata']]
    ==
  %+  expect-eq
    !>((~(got by p.town) correct-id))
  !>(correct)
--