::  zane [uqbar-dao]
::
::  The "vane" for interacting with Uqbar. Provides read/write layer for userspace agents.
::
/+  *zane, *sequencer, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      sources=(list ship)
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
  ^-  (quip card _this)
  ?>  =(src.bowl our.bowl)
  ?+    -.path  !!
      %id
    !!
  ::
      %grain
    !!
  ::
      %holder
    !!
  ::
      %lord
    !!
  ==
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
      !!
    ::
        %remove-source
      !!
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
