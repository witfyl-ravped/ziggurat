::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes diffs to rollup.hoon
::  Accepts transactions and batches them periodically as moves to town.
::
/+  *sequencer, *rollup, default-agent, dbug, verb
::  Choose which library smart contracts are executed against here
::
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      rollup=(unit ship)  ::  replace in future with ETH/starknet contract address
      town=(unit town)                ::  state
      =basket                         ::  mempool
      peer-roots=(map id:smart root)  ::  track updates from rollup
      status=?(%available %off)
  ==
+$  inflated-state-0  [state-0 =mil]
+$  mil  $_  ~(mill mill !>(0))
--
::
=|  inflated-state-0
=*  state  -
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  `this(state [[%0 ~ ~ ~ ~ %off] ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))])
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::  on-load: pre-cue our compiled smart contract library
  ::
  `this(state [!<(state-0 old-vase) ~(mill mill ;;(vase (cue q.q.smart-lib-noun)))])
::
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
    ?-    -.act
    ::
    ::  town administration
    ::
        %init
      ?>  =(src.bowl our.bowl)
      ::  poke rollup ship with params of new town
      ::  (will be rejected if id is taken)
      !!
    ::
        %clear-state
      ?>  =(src.bowl our.bowl)
      ~&  >>  "sequencer: wiping state"
      `state(rollup ~, town ~, basket ~, peer-roots ~, status %off)
    ::
    ::  handle transactions
    ::
        %receive
      ?.  =(%available status.state)
        ~|("%sequencer: error: got poke while not active" !!)
      ~&  >>  "%sequencer: received eggs from {<src.bowl>}: {<eggs.act>}"
      `state(basket (~(uni in basket) eggs.act))
    ::
    ::  batching
    ::
        %trigger-batch
      ?>  =(src.bowl our.bowl)
      ?.  =(%available status.state)
        ~|("%sequencer: error: got poke while not active" !!)
      ?~  town.state
        ~|("%sequencer: error: no state" !!)
      ?~  rollup.state
        ~|("%sequencer: error: no known rollup host" !!)
      =*  town  u.town.state
      ?:  ?=(%committee -.mode.hall.town)
        ::  TODO data-availability committee
        ::
        ~|("%sequencer: error: DAC not implemented" !!)
      ::  publish full diff data
      ::
      ::  1. produce diff and new state with mill
      ::  TODO: make mill parallel, return diff
      =/  new-root  (shax 123.456)
      ::  2. generate our signature
      ::  (address sig, that is)
      =/  sig  [0 0 0]
      ::  3. poke rollup
      :_  state
      =+  :-  %rollup-action
          !>  :-  %receive-move
              :*  mode.hall.town
                  new-root
                  new-state=*land
                  peer-roots.state
                  sig
              ==
      ~[[%pass /move-submit/(scot %ux new-root) %agent [u.rollup.state %rollup] %poke -]]
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%move-submit @ ~]
    ?:  ?=(%poke-ack -.sign)
      ?~  p.sign
        ::  TODO transition state here, move was approved
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
    ``noun+!>(status)
  ::
      [%town-id ~]
    ?~  town  ``noun+!>(~)
    ``noun+!>(`id.hall.u.town)
  ::
  ::  state reads fail if sequencer not active
  ::
      [%has @ ~]  ::  see if grain exists in state
    =/  id  (slav %ux i.t.t.path)
    ?~  town  [~ ~]
    ``noun+!>((~(has by p.land.u.town) id))
  ::
      [%grain @ ~]
    ?~  town  [~ ~]
    (read-grain t.path p.land.u.town)
  ::
      [%read @ @tas @ta ^]  ::  execute contract read
    ?~  town  [~ ~]
    ::  TODO pre-;; library
    (read-wheat t.path now.bowl id.hall.u.town p.land.u.town ;;(vase q.q.smart-lib-noun))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
