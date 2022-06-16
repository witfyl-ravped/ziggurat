::  zane [uqbar-dao]
::
::  The "vane" for interacting with Uqbar. Provides read/write layer for userspace agents.
::
/+  *zane, *sequencer, default-agent, dbug, verb, agentio
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      sources=(jar town-id=@ud dock)
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
  ?+    -.path  !!
      ?(%id %grain %holder %lord)
    :_  this
    =/  watch-card=(unit card)  watch-indexer
    ?~(watch-card ~ ~[u.watch-card])
  ==
  ::
  ++  watch-indexer  ::  TODO: ping indexers and find responsive one?
    ^-  (unit card)
    ?.  ?=([@ @ @ ~] path)  ~
    =/  town=id:smart  (slav %ux i.t.path)
    ?~  town-source=(~(get ja sources) town)  ~
    :-  ~
    %+  ~(watch pass:io /[i.path]/[i.t.t.path])
    i.town-source  /[i.path]/[i.t.t.path]
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
          (~(add ja sources) dock.act)
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
        (oust [index 1] town-source)
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
    :_  this
    =/  agent-card=(unit card)
      ?+    -.sign  (on-agent:def wire sign)
          %kick
        rejoin
      ::
          %fact
        pass-through
      ==
    ?~(agent-card ~ ~[u.agent-card])
  ==
  ::
  ++  rejoin  ::  TODO: ping indexers and find responsive one?
    ^-  (unit card)
    ?~  old-source=(get-wex-dock-by-wire wire)  ~
    (~(watch pass:io wire) u.old-source wire)
  ::
  ++  get-wex-dock-by-wire
    ^-  (unit dock)
    ?:  =(0 ~(wyt by wex.bowl))  ~
    =/  wexs=(list [w=wire s=ship t=term])
      ~(tap in ~(key by wex.bowl))
    |-
    ?~  wexs  ~
    =*  wex  i.wexs
    ?.  =(wire w.wex)  $(wexs t.wexs)
    `[s.wex t.wex]
  ::
  ++  pass-through
    ^-  (unit card)
    ?.  ?=([@ @ ~] wire)  ~
    =/  town=id:smart  (slav %ux i.t.wire)
    =/  item=id:smart  (slav %ux i.t.t.wire)
    ?~  town-source=(~(get ja sources) town)  ~
    `(fact:io cage.sign wire)
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
