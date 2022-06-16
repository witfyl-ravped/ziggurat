::  zane [uqbar-dao]
::
::  The "vane" for interacting with Uqbar. Provides read/write layer for userspace agents.
::
/+  *zane, *sequencer, default-agent, dbug, verb, agentio
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      sources=(jar town=id:smart dock)
      sequencers=(map id:smart sequencer)
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
    io    ~(. agentio bowl)
::
++  on-init  `this(state [%0 ~ ~])
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  `this(state !<(state-0 old-vase))
::
++  on-watch
  |=  =path
  |^  ^-  (quip card _this)
  ?>  =(src.bowl our.bowl)
  :_  this
  ?+    -.path  !!
      ?(%id %grain %holder %lord)
    ?.  ?=([@ @ @ ~] path)  ~
    =/  town=id:smart  (slav %ux i.t.path)
    ?~  card=(watch-indexer town ~ /[i.path]/[i.t.t.path])  ~
    ~[u.card]
  ::
      %scry
    ?.  ?=(?(%id %grain %holder %lord) -.+.path)  ~
    ?.  ?=([@ @ @ @ ~] path)                      ~
    =/  town=id:smart  (slav %ux i.t.t.path)
    =/  card=(unit card)
      (watch-indexer town /[i.path] /[i.t.path]/[i.t.t.t.path])
    ?~(card ~ ~[u.card])
  ==
  ::
  ++  watch-indexer  ::  TODO: ping indexers and find responsive one?
    |=  [town=id:smart wire-prefix=wire sub-path=^path]
    ^-  (unit card)
    ?~  town-source=(~(get ja sources) town)  ~
    :-  ~
    %+  ~(watch pass:io (weld wire-prefix sub-path))
    i.town-source  sub-path
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  =(src.bowl our.bowl)
  ?.  ?=(?(%zane-action %zane-write) mark)
    ~|("%zane: rejecting erroneous poke" !!)
  =^  cards  state
    ?-  mark
      %zane-action  (handle-action !<(action vase))
      %zane-write  (handle-write !<(write vase))
    ==
  [cards this]
  ::
  ++  handle-action
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %set-sources
      !!
    ::
        %add-source
      :-  ~
      %=  state
          sources
        ?~  town-source=(~(get ja sources) town.act)
          (~(add ja sources) town.act dock.act)
        ?>  ?=(^ (find [dock.act]~ town-source))
        %+  ~(put by sources)  town.act
        (snoc town-source dock.act)
      ==
    ::
        %remove-source
      :-  ~
      %=  state
          sources
        ?~  town-source=(~(get ja sources) town.act)  !!
        ?~  index=(find [dock.act]~ town-source)      !!
        %+  ~(put by sources)  town.act
        (oust [u.index 1] `(list dock)`town-source)
      ==
    ==
  ::
  ++  handle-write
    |=  =write
    ^-  (quip card _state)
    ?-    -.write
        %submit
      !!
    ::
        %submit-many
      !!
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  |^  ^-  (quip card _this)
  ?+    -.wire  (on-agent:def wire sign)
      ?(%id %grain %holder %lord)
    ?+    -.sign  (on-agent:def wire sign)
        %kick
      :_  this
      =/  agent-card=(unit card)  rejoin
      ?~(agent-card ~ ~[u.agent-card])
    ::
        %fact
      :_  this
      ~[(pass-through cage.sign)]
    ==
  ::
      %scry
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      :_  this
      =/  leave-card=(unit card)  leave
      ?~  leave-card
        ~&  >>>  "zane: failed to leave {<wire>}"
        ~[(pass-through cage.sign)]
      ~[(pass-through cage.sign) u.leave-card]
    ==
  ==
  ::
  ++  pass-through
    |=  =cage
    ^-  card
    (fact:io cage ~[wire])
  ::
  ++  leave
    ^-  (unit card)
    =/  old-source=(unit dock)
      get-wex-dock-by-wire
    ?~  old-source  ~
    `(~(leave pass:io wire) u.old-source)
  ::
  ++  rejoin  ::  TODO: ping indexers and find responsive one?
    ^-  (unit card)
    =/  old-source=(unit dock)
      get-wex-dock-by-wire
    ?~  old-source  ~
    `(~(watch pass:io wire) u.old-source wire)
  ::
  ++  get-wex-dock-by-wire
    ^-  (unit dock)
    ?:  =(0 ~(wyt by wex.bowl))  ~
    =/  wexs=(list [w=^wire s=ship t=term])
      ~(tap in ~(key by wex.bowl))
    |-
    ?~  wexs  ~
    =*  wex  i.wexs
    ?.  =(wire w.wex)  $(wexs t.wexs)
    `[s.wex t.wex]
  --
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  (on-arvo:def wire sign-arvo)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  all scrys should return a unit
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%contract @ @ @tas @ta ^]
    ``noun+!>(~)
  ::
      [%grain @ ~]
    !!
  ::
      [%transaction @ ~]
    !!
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--