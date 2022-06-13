::  rollup [uqbar-dao]
::
::  Agent that simulates a rollup contract on another chain.
::  Receives state transitions (moves) for towns, verifies them,
::  and allows sequencer ships to continue processing batches.
::
/+  *sequencer, *rollup, mill=zig-mill, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      =capitol
      status=?(%available %off)
  ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this(state [%0 ~ %off])
++  on-save  !>(-.state)
++  on-load  `this
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  =(%available status.state)
    ~|("%rollup: error: got watch while not active" !!)
  ?>  (allowed-participant [src our now]:bowl)
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%rollup-action mark)
    ~|("%rollup: error: got erroneous %poke" !!)
  ::  remove this to disable whitelist
  ::
  ?>  (allowed-participant [src our now]:bowl)
  =^  cards  state
    (handle-poke !<(action vase))
  [cards this]
  ::
  ++  handle-poke
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %receive-move
      ::  validate move from sequencer and return a %batch-approve
      ?~  hall=(~(get by capitol.state) town-id.act)
        ~|("%rollup: error: town not found" !!)
      ?.  =([from.act src.bowl] sequencer.u.hall)
        ~|("%rollup: error: sequencer doesn't match town" !!)
      ::  TODO validate signature here
      ?:  ?=(%committee -.mode.act)
        ::  TODO implement DAC
        !!
      ::  handle full-publish mode
      ::
      ::  TODO check that other town state roots are valid/recent
      ::
      ?.  =(hash.mode.act (shax diffs.mode.act))
        ~|("%rollup: error: diff hash not valid" !!)
      ?.  (verify-sig from.act new-root.act sig.act %.y)
        ~|("%rollup: error: sequencer signature not valid" !!)
      =-  `state(capitol (~(put by capitol) town-id.act -))
      %=  hall
        latest-diff-hash  hash.mode.act
        roots  (snoc roots new-root.act)
      ==
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  (on-agent:def wire sign)
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
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
