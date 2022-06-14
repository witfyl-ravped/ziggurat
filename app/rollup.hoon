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
++  on-load  on-load:def
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  =(%available status.state)
    ~|("%rollup: error: got watch while not active" !!)
  ?>  (allowed-participant [src our now]:bowl)
  ::  give new subscibing sequencer recent root from every town
  ::
  :_  this
  %+  turn  ~(tap by capitol)
  |=  [=id:smart =hall:sequencer]
  ^-  card
  =-  [%give %fact ~[/peer-root-update] -]
  [%rollup-update !>([%new-peer-root id (rear roots.hall)])]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%rollup-action mark)
    ~|("%rollup: error: got erroneous %poke" !!)
  ?>  (allowed-participant [src our now]:bowl)
  =^  cards  state
    (handle-poke !<(action vase))
  [cards this]
  ::
  ++  handle-poke
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %activate
      `state(status %available)
    ::
        %receive-move
      ::  validate move from sequencer and return a %batch-approve
      ?~  hall=(~(get by capitol.state) town-id.act)
        ~|("%rollup: error: town not found" !!)
      ?.  =([from.act src.bowl] sequencer.u.hall)
        ~|("%rollup: error: sequencer doesn't match town" !!)
      ?:  ?=(%committee -.mode.act)
        ::  handle DAC, TODO
        ::
        ?.  =(diff-hash.act (shax (jam state-diffs.act)))
          ~|("%rollup: error: diff hash not valid" !!)
        !!
      ::  handle full-publish mode
      ::
      ?.  (verify-sig:mill from.act new-root.act sig.act %.y)
        ~|("%rollup: error: sequencer signature not valid" !!)
      ::  check that other town state roots are up-to-date
      ::  recent-enough is a variable here that can be adjusted
      =/  recent-enough  2
      ?.  %+  levy
            %+  turn  ~(tap by peer-roots.act)
            |=  [=id:smart root=@ux]
            ?~  hall=(~(get by capitol.state) id)  %.n
            ?~  (find [root]~ (slag recent-enough roots.u.hall))  %.n
            %.y
          |=(a=? a)
        ~|("%rollup: error: peer roots not recent enough" !!)
      ::  batch is approved
      =+  %=  u.hall
            latest-diff-hash  diff-hash.act
            roots  (snoc roots.u.hall new-root.act)
          ==
      :_  state(capitol (~(put by capitol) town-id.act -))
      [%give %fact ~[/peer-root-update] %rollup-update !>([%new-peer-root town-id.act new-root.act])]~
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
