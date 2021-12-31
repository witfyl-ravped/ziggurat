::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      =epochs
      =helices
      =mempools
      seen-sigs=(map @ux (set signature))
  ==
++  new-epoch-timers
  |=  [=epoch our=ship]
  ^-  (list card)
  =/  order  order.epoch
  =/  i  0
  =|  cards=(list card)
  |-  ^-  (list card)
  ?~  order  cards
  %_    $
    i      +(i)
    order  t.order
  ::
      cards
    :_  cards
    (wait num.epoch i start-time.epoch =(our i.order))
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
++  on-init  `this(state [%0 %none ~ ~ ~ ~])
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  `this(state old-state)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?([%epoch-catchup @ ~] [%updates ~])]
    ?:  =(mode %none)
      `this
    ~|  "only validators can listen to block production!"
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?>  (~(has in (silt order.cur)) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %updates
      ::  do nothing here, but send all new blocks and epochs on this path
      `this
    ::
        %epoch-catchup
      ~|  "we must be a validator to be listened to on this path!"
      ?>  =(mode %validator)
      ::  TODO: figure out whether to use this number or not
      ::=/  start=(unit @ud)
      ::  =-  ?:(=(- 0) ~ `(dec -))
      ::  (slav %ud i.t.t.path)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup epochs]
        [%give %kick ~ ~]
      ~
    ==
  ::
      [%fisherman %updates ~]
    ~|  "comets and moons may not be fishermen, tiny dos protection"
    ?>  (lte (met 3 src.bowl) 4)
    ::  do nothing here, but send all new blocks and epochs on this path
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %zig-action
    =^  cards  state
      (poke-zig-action !<(action vase))
    [cards this]
      %zig-mempool-action
    =^  cards  state
      (poke-mempool-action !<(mempool-action vase))
    [cards this]
      %zig-chunk-action
    =^  cards  state
      (poke-chunk-action !<(chunk-action vase))
    [cards this]
      %noun
    ?>  (validate-history our.bowl epochs)
    `this
  ==
  ::
  ++  poke-zig-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %start
      ?>  =(src.bowl our.bowl)
      ~|  "we have already started in this mode"
      ?<  =(mode mode.action)
      =?  epochs  ?=(^ history.action)
        history.action
      ?:  ?=(%validator mode.action)
        ?>  ?|(?=(^ epochs) ?=(^ validators.action))
        :_  state(mode %validator)
        %-  zing
        :~  cleanup-fisherman
            cleanup-validator
            (watch-updates validators.action)
            ?~  epochs  ~
            =/  cur=epoch  +:(need (pry:poc epochs))
            (new-epoch-timers cur our.bowl)
        ==
      :_  state(mode %fisherman)
      (weld cleanup-validator cleanup-fisherman)
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      :_  state(mode %none, epochs ~, helices ~, mempools ~, seen-sigs ~)
      (weld cleanup-validator cleanup-fisherman)
    ::
        %new-epoch
      ?>  =(src.bowl our.bowl)
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  last-slot-num=@ud
        (need (bind (pry:sot slots.cur) head))
      =/  prev-hash
        (got-hed-hash last-slot-num epochs cur)
      =/  new-epoch=epoch
        :^    +(num.cur)
            (deadline start-time.cur +((lent order.cur)))
          (shuffle (silt order.cur) (mug prev-hash))
        ~
      =/  validators=(list ship)
        ~(tap in (~(del in (silt order.cur)) our.bowl))
      ?:  ?&  ?=(^ validators)
              %+  lth  start-time.new-epoch
              (sub now.bowl (mul +((lent order.new-epoch)) epoch-interval))
          ==
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ~&  num.new-epoch^(sham epochs)
      :_  state(epochs (put:poc epochs num.new-epoch new-epoch))
      %+  weld
        (watch-updates (silt (murn order.new-epoch filter-by-wex)))
      (new-epoch-timers new-epoch our.bowl)
    ==
  ::
  ++  poke-mempool-action
    |=  act=mempool-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %receive
      ::  getting a tx from user
      ::  share with all other validators
      ::  (TODO only send to our helix chunk producer)
      ~&  >  "received a tx: {<tx.act>}"
      ?~  helix=(~(get by helices.state) helix-id.act)
        ~&  >>  "ignoring tx, we're not active in that helix"
        [~ state]
      ~&  >  "forwarding to {<leader.u.helix>}'s mempool"
      :_  state
      :_  ~
      :*  %pass  /mempool-gossip
          %agent  [leader.u.helix %ziggurat]  %poke
          %zig-mempool-action  !>(`mempool-action`[%hear helix-id.act tx.act])
      ==
    ::
        %hear
      ::  :ziggurat &mempool [%hear [%send [0x1 100 10 0x1234 [0xa 0xb %schnorr]] 0x2 (malt ~[[0x0 [%tok 0x0 500]]])]]
      ::  getting tx from other validator
      ::  should only accept from other validators
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?~  (find [src.bowl]~ order.cur)  !!
      ::  don't need to gossip forward
      ~&  >  "received a gossiped tx from {<src.bowl>}: {<tx.act>}"
      ?.  (~(has by helices.state) helix-id.act)
        ~&  >>  "ignoring tx, we're not active in that helix"
        [~ state]
      :-  ~
      =-  state(mempools (~(jab by mempools) helix-id.act -))
      |=(=mempool (~(put in mempool) tx.act))
      
    ::
        %forward-set
      ?>  =(src.bowl our.bowl)
      ::  forward our mempool to another validator
      ::  used when we pass producer status to a new
      ::  validator, give them existing mempool
      ::  clear mempool for ourselves
      =/  to-send=(set tx:tx)  (~(gut by mempools) helix-id.act ~)
      :_  state(mempools (~(put by mempools) helix-id.act ~))
      :_  ~
      :*  %pass  /mempool-gossip
          %agent  [to.act %ziggurat]  %poke
          %zig-mempool-action  !>(`mempool-action`[%receive-set helix-id.act to-send])
      ==
    ::
        %receive-set
      ::  integrate a set of txs into our mempool
      ::  should only accept from other validators
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?~  (find [src.bowl]~ order.cur)  !!
      :-  ~
      =-  state(mempools (~(jab by mempools) helix-id.act -))
      |=(=mempool (~(uni in mempool) txs.act))
    ==
  ::
  ++  poke-chunk-action
    |=  act=chunk-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %hear
      ::  receiving chunk to be signed from chunk leader
      ?~  helix=(~(get by helices.state) helix-id.chunk.act)
        ~&  >>>  "ignoring received chunk, not active in a helix"
        [~ state]
      ::  only accept from our helix leader
      ?>  =(src.bowl leader.u.helix)
      ::  sign chunk and return it
      ::  TODO validate chunk here if even needed
      :_  state
      :_  ~
      (~(sign lix u.helix (~(gut by mempools.state) helix-id.chunk.act ~) [our now src]:bowl) chunk.act)
    ::
        %signed
      ?~  helix=(~(get by helices.state) helix-id.act)
        ~&  >>>  "ignoring received sig, not active in a helix"
        [~ state]
      ::  should only accept from other validators in helix
      ~|  "received signature from validator in wrong helix"
      ?~  (find [src.bowl]~ order.u.helix)  !!
      ::  only take if we're the chunk producer
      ?.  =(our.bowl leader.u.helix)
        ~&  >>>  "ignoring chunk signature, not leader in our helix"
        [~ state]
      ::  validate signature given
      ~|  "received invalid signature on chunk"
      ?>  (validate:zig-sig our.bowl signature.act hash.act now.bowl)
      :-  ~
      =-  state(seen-sigs (~(jab by seen-sigs) helix-id.act -))
      |=(seen=(set signature) (~(put in seen) signature.act))
    ::
        %submit
      ::  should only get this as a block producer
      ::  TODO
      [~ state]
    ==
  ::
  ++  filter-by-wex
    |=  shp=ship
    ^-  (unit ship)
    ?:  %-  ~(any in ~(key by wex.bowl))
        |=([* =ship *] =(shp ship))
      ~
    `shp
  ::
  ++  watch-updates
    |=  validators=(set ship)
    ^-  (list card)
    =.  validators  (~(del in validators) our.bowl)
    %+  turn  ~(tap in validators)
    |=  s=ship
    ^-  card
    =/  =^wire  /validator/updates/(scot %p s)
    [%pass wire %agent [s %ziggurat] %watch /validator/updates]
  ::
  ++  cleanup-validator
    ^-  (list card)
    %+  weld
      %+  murn  ~(tap by wex.bowl)
      |=  [[=wire =ship =term] *]
      ^-  (unit card)
      ?.  ?=([%validator %updates *] wire)  ~
      `[%pass wire %agent [ship term] %leave ~]
    %+  murn  ~(tap by sup.bowl)
    |=  [* [p=ship q=path]]
    ^-  (unit card)
    ?.  ?=([%validator *] q)  ~
    `[%give %kick q^~ `p]
  ::
  ++  cleanup-fisherman
    ^-  (list card)
    %+  murn  ~(tap by wex.bowl)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%fisherman %updates *] wire)  ~
    `[%pass wire %agent [ship term] %leave ~]
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
      [%validator ?([%epoch-catchup @ @ ~] [%updates @ ~])]
    ~|  "can only receive validator updates when we are a validator!"
    ?>  =(mode %validator)
    =*  kind  i.t.wire
    ?-    kind
        %updates
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%watch-ack -.sign)
        ?~  p.sign
          `this
        ~&  u.p.sign
        `this
      ?:  ?=(%kick -.sign)
        ::  resubscribe to validators for updates if kicked
        ::
        :_  this
        [%pass wire %agent [src.bowl %ziggurat] %watch (snip `path`wire)]~
      =^  cards  state
        (update-fact !<(update q.cage.sign))
      [cards this]
    ::
        %epoch-catchup
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%kick -.sign)  `this
      ?:  ?=(%watch-ack -.sign)
        ?.  ?=(^ p.sign)    `this
        =/  cur=epoch  +:(need (pry:poc epochs))
        =/  validators=(list ship)
          ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
        ?>  ?=(^ validators)
        :_  this
        (start-epoch-catchup i.validators num.cur)^~
      ?>  ?=(%fact -.sign)
      =^  cards  state
        (epoch-catchup !<(update q.cage.sign))
      [cards this]
    ==
  ::
      [%fisherman %updates ~]
    ~|  "can only receive fisherman updates when we are a fisherman!"
    ?>  =(%fisherman mode)
    `this
  ==
  ::
  ++  update-fact
    |=  =update
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  prev-hash
      (got-hed-hash next-slot-num epochs cur)
    ?:  ?=(%new-block -.update)
      ~|  "new blocks cannot be applied to past epochs"
      ?<  (lth epoch-num.update num.cur)
      ?:  (gth epoch-num.update num.cur)
        =/  validators=(list ship)
          ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
        ?>  ?=(^ validators)
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      =^  cards  cur
        %-  ~(their-block epo cur prev-hash [our now src]:bowl)
        [header `block]:update
      [cards state(epochs (put:poc epochs num.cur cur))]
    ?.  ?=(%saw-block -.update)  !!
    :_  state
    %+  ~(see-block epo cur prev-hash [our now src]:bowl)
      epoch-num.update
    header.update
  ::
  ++  epoch-catchup
    |=  =update
    ^-  (quip card _state)
    ~|  "must be an %epoch-catchup update"
    ?>  ?=(%epochs-catchup -.update)
    ~&  catching-up-to+src.bowl
    =/  a=(list (pair @ud epoch))  (bap:poc epochs.update)
    =/  b=(list (pair @ud epoch))  (bap:poc epochs)
    ?~  epochs.update  `state
    ?~  epochs
      ?>  (validate-history our.bowl epochs.update)
      `state(epochs epochs.update)
    ~|  "invalid history"
    ?>  (validate-history our.bowl epochs.update)
    :-  ~
    |-  ^-  _state
    ?~  a
      ~&  %picked-our-history
      state
    ?~  b
      ~&  %picked-their-history
      state(epochs epochs.update)
    ?:  =(i.a i.b)
      $(a t.a, b t.b)
    =/  a-s=(list (pair @ud slot))  (tap:sot slots.q.i.a)
    =/  b-s=(list (pair @ud slot))  (tap:sot slots.q.i.b)
    |-  ^-  _state
    ?~  a-s        ^$(a t.a, b t.b)
    ?~  b-s        ^$(a t.a, b t.b)
    ?~  q.q.i.a-s  ~&  %picked-our-history    state
    ?~  q.q.i.b-s  ~&  %picked-their-history  state(epochs epochs.update)
    $(a-s t.a-s, b-s t.b-s)
  --
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  |^  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers ?([%slot @ @ ~] [%epoch-catchup @ @ ~])]
    ~|  "these timers are only relevant for validators!"
    ?>  =(%validator mode)
    =*  kind  i.t.wire
    ?:  ?=(%epoch-catchup kind)
      `this
    =/  epoch-num  (slav %ud i.t.t.wire)
    =/  slot-num  (slav %ud i.t.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    ?^  error.sign-arvo
      ~&  error.sign-arvo
      `this
    =^  cards  state
      (slot-timer epoch-num slot-num)
    [cards this]
  ==
  ::
  ++  slot-timer
    |=  [epoch-num=@ud slot-num=@ud]
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?.  =(num.cur epoch-num)
      `state
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  =ship  (snag slot-num order.cur)
    ?.  =(next-slot-num slot-num)
      ?.  =(ship our.bowl)  `state
      ~|("we can only produce the next block, not past or future blocks" !!)
    =/  prev-hash
      (got-hed-hash slot-num epochs cur)
    ::  check if we're chunk producer for any helix
    ::  and create a chunk for that helix if so
    ::
    ::  =/  dispersion-cards=(list card)
    ::    ::  for helix in helices:
    ::    ?:  =(leader.helix our.bowl)
    ::      =-  (~(disperse lix helix mempool.state [our now src]:bowl) -)
    ::      ~(produce lix helix mempool.state [our now src]:bowl)
    ::    ~
    ::  try to submit chunk if above sig threshold 
    ::  ?:  (gte +(~(wyt in seen-sigs.u.helix)) (div (lent order.u.helix) 2))
    ::    :_  state
    ::    %^    ~(submit lix u.helix mempool.state [our now src]:bowl)
    ::        [signature.act ~(tap in seen-sigs.u.helix)]
    ::      (need our-chunk.u.helix)
    ::    ship
    ?:  =(ship our.bowl)
      ::  we're block producer so should collect chunks here
      ::  
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) eny.bowl^~) 
      [cards state(epochs (put:poc epochs num.cur cur))]
    =/  cur=epoch  +:(need (pry:poc epochs))
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    ~&  skip-block+[num.cur slot-num]
    [cards state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
