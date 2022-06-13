::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes diffs to rollup.hoon
::  Accepts transactions and batches them periodically as moves to town.
::
/+  *sequencer, default-agent, dbug, verb
::  Choose which library smart contracts are executed against here
::
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      town=(unit town)
      =basket  ::  mempool
      status=?(%available %off)
  ==
+$  inflated-state-0  [state-0 =mil]
+$  mil  $_  ~(mill mill !>(0))
--
::
=|  inflated-state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  `this(state [[%0 ~ ~ %off] ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))])
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::  on-load: pre-cue our compiled smart contract library
  ::
  `this(state [!<(state-0 old-vase) ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))])
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  =(%available status.state)
    ~|("%sequencer: error: got watch while not active" !!)
  ?>  (allowed-participant [src our now]:bowl)
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%sequencer-town-action mark)
    ~|("%sequencer: error: got erroneous %poke" !!)
  ::  remove this to disable whitelist
  ::
  ?>  (allowed-participant [src our now]:bowl)
  =^  cards  state
    (handle-poke !<(town-action vase))
  [cards this]
  ::
  ++  handle-poke
    |=  act=town-action
    ^-  (quip card _state)
    ?.  =(%available status.state)
      ~|("%sequencer: error: got poke while not active" !!)
    ?-    -.act
    ::
    ::  town administration
    ::
        %init
      ::  poke rollup ship with params of new town (will be rejected if id is taken)
      !!
    ::
        %clear-state
      ~&  >>  "sequencer: wiping state"
      `state(town ~, basket ~, status %off)
    ::
    ::  handle transactions
    ::
        %receive
      ~&  >>  "%sequencer: received eggs from {<src.bowl>}: {<eggs.act>}"
      `state(basket (~(uni in basket) eggs.act))
    ::
    ::  batching
    ::
        %trigger-batch
      ::  call into mill here
      !!
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%move-submit ~]
    ?:  ?=(%poke-ack -.sign)
      ?~  p.sign
        `this
      ::  TODO manage rejected moves here
      ~&  >>>  "%sequencer: our move was rejected by rollup!"
      `this
    `this
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  (on-arvo:def wire sign-arvo)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  all scrys return a unit
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%status ~]
    ``noun+!>(status.state)
  ::
      [%town-id ~]
    ?~  town.state  ``noun+!>(~)
    ``noun+!>(`id.u.town)
  ::
  ::  state reads fail if sequencer not active
  ::
      [%has @ ~]  ::  see if grain exists in state
    =/  id  (slav %ux i.t.t.path)
    ?~  town.state  [~ ~]
    ``noun+!>((~(has by p.state.u.town.state) id))
  ::
      [%grain @ ~]
    ?~  town.state  [~ ~]
    (read-grain t.path p.state.u.town.state)
  ::
      [%read @ @tas @ta ^]  ::  execute contract read
    ?~  town.state  [~ ~]
    ::  TODO pre-;; library
    (read-wheat t.path now.bowl id.u.town.state p.state.u.town.state ;;(vase q.q.smart-lib-noun))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
