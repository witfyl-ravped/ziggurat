::  indexer [uqbar-dao]:
::
::  Index blocks
::
::    Receive new blocks, index them,
::    and update subscribers with full blocks
::    or with hashes of interest
::
::
::    ## Scry paths
::
::    /x/block-height:
::      The current block height
::    /x/block-hash/[@ux]:
::      The slot with given block hash
::    /x/chunk-num/[@ud]/[@ud]/[@ud]:
::      The chunk with given epoch/block/chunk number
::    /x/chunk-hash/[@ux]/[@ud]:
::      The chunk with given block hash/chunk number
::    /x/egg/[@ux]:
::      Info about egg (transaction) with the given hash
::    /x/from/[@ux]:
::      History of sender with the given hash
::    /x/grain/[@ux]:
::      State of grain with given hash
::    /x/hash/[@ux]:
::      Info about hash
::    /x/headers/[@ud]:
::      Most recent [@ud] block headers (up to some cached max)
::    /x/holder/[@ux]:
::      Grains held by id with given hash
::    /x/id/[@ux]:
::      History of id with the given hash
::    /x/lord/[@ux]:
::      Grains ruled by lord with given hash
::    /x/slot:
::      The most recent slot
::    /x/slot-num/[@ud]:
::      The slot with given block number
::    /x/to/[@ux]:
::      History of receiver with the given hash
::
::
::    ## Subscription paths
::
::    /chunk/[@ud]:
::      A stream of each new chunk for a given town.
::
::    /id/[@ux]:
::      A stream of new activity of given id.
::
::    /grain/[@ux]:
::      A stream of changes to given grain.
::
::    /holder/[@ux]:
::      A stream of new activity of given holder.
::
::    /lord/[@ux]:
::      A stream of new activity of given lord.
::
::    /slot:
::      A stream of each new slot.
::
::
::    ##  Pokes
::
::    %set-chain-source:
::      Subscribe to source for new blocks.
::
::    %consume-indexer-update:
::      Add a block or chunk to the index.
::
::    %serve-update:
::
::
/-  ui=indexer,
    zig=ziggurat,
    seq=sequencer
/+  agentio,
    dbug,
    default-agent,
    verb,
    indexer-lib=indexer-bowl,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-0
  ==
::
+$  parsed-block
  $:  block-hash=(list [@ux block-location:ui])
      egg=(list [@ux egg-location:ui])
      from=(list [@ux second-order-location:ui])
      grain=(list [@ux town-location:ui])
      holder=(list [@ux second-order-location:ui])
      lord=(list [@ux second-order-location:ui])
      to=(list [@ux second-order-location:ui])
  ==
::
+$  base-state-0
  $:  =epochs:zig
      num-recent-headers=@ud
      recent-headers=(list [epoch-num=@ud =block-header:zig])
      previous-parsed-block=parsed-block
  ==
+$  indices-0
  $:  block-index=(jug @ux block-location:ui)
      egg-index=(jug @ux egg-location:ui)
      from-index=(jug @ux second-order-location:ui)
      grain-index=(jug @ux town-location:ui)
      holder-index=(jug @ux second-order-location:ui)
      lord-index=(jug @ux second-order-location:ui)
      to-index=(jug @ux second-order-location:ui)
  ==
+$  state-0  [%0 base-state-0 indices-0]
::
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this          .
      def           ~(. (default-agent this %|) bowl)
      io            ~(. agentio bowl)
      ui-lib        ~(. indexer-lib bowl)
      indexer-core  +>
      ic            ~(. indexer-core bowl)
  ::
  ++  on-init  `this(num-recent-headers 50)
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+    mark  (on-poke:def mark vase)
      ::
          %set-chain-source
        ?>  (team:title our.bowl src.bowl)
        (set-chain-source:ic !<(dock vase))
      ::
          %set-num-recent-headers
        ?>  (team:title our.bowl src.bowl)
        `state(num-recent-headers !<(@ud vase))
      ::
      ::  TODO: add %consume-update and %serve-update pokes
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L138
      ::
      ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
    ::
        [%chunk @ ~]
      :_  this
      =/  town-id=@ud  (slav %ud i.t.path)
      ?~  newest-epoch=(pry:poc:zig epochs)  ~
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        ~
      =*  newest-block  q.val.u.newest-slot
      ?~  newest-block  ~
      =*  newest-chunks  chunks.u.newest-block
      =/  newest-chunk  (~(get by newest-chunks) town-id)
      ?~  newest-chunk  ~
      =*  epoch-start-time  start-time.val.u.newest-epoch
      :_  ~
      %-  fact:io
      :_  ~
      :-  %indexer-update
      !>  ^-  update:ui
      :^  %chunk  epoch-start-time
        :+  epoch-num=num.val.u.newest-epoch
          block-num=num.p.val.u.newest-slot
        town-id=town-id
      u.newest-chunk
    ::
        [%id @ ~]
      =/  serve-previous-update=_serve-update
        (make-one-block-serve-update previous-parsed-block)
      :_  this
      =/  payload=@ux  (slav %ux i.t.path)
      =/  from=update:ui
        (serve-previous-update %from payload)
      =/  to=update:ui
        (serve-previous-update %to payload)
      =/  =update:ui  (combine-egg-updates ~[from to])
      ?~  update  ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ::
        ?([%grain @ ~] [%holder @ ~] [%lord @ ~])
      =/  serve-previous-update=_serve-update
        (make-one-block-serve-update previous-parsed-block)
      :_  this
      =/  query-type=?(%grain %holder %lord)  i.path
      =/  payload=@ux  (slav %ux i.t.path)
      ?~  update=(serve-previous-update query-type payload)
        ~
      :_  ~
      %-  fact:io
      :_  ~
      [%indexer-update !>(`update:ui`update)]
    ::
        [%slot ~]
      :_  this
      ?~  newest-epoch=(pry:poc:zig epochs)  ~
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        ~
      =*  epoch-num  num.val.u.newest-epoch
      =*  slot  val.u.newest-slot
      =*  block-header  p.slot
      =*  epoch-start-time  start-time.val.u.newest-epoch
      :_  ~
      %-  fact:io
      :_  ~
      :-  %indexer-update
      !>  ^-  update:ui
      :-  %slot
      %+  %~  put  by
          *(map id:smart [@da block-location:ui slot:zig])
        `@ux`data-hash.block-header
      :+  epoch-start-time  [epoch-num num.block-header]
      slot
    ::
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
    ::
        $?  [%chunk @ ~]
            [%id @ ~]
            [%grain @ ~]
            [%holder @ ~]
            [%lord @ ~]
            [%slot ~]
        ==
      `this
    ::
    ==
  ::
  ++  on-peek
    |=  =path
    |^  ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
    ::
        [%x %block-height ~]
      ?~  recent-headers  [~ ~]
      =*  most-recent  i.recent-headers
      :^  ~  ~  %noun
      !>  ^-  [epoch-num=@ud block-num=@ud]
      :-  epoch-num.most-recent
      num.block-header.most-recent
    ::
        ?([%x %chunk-num @ @ @ ~] [%x %json %chunk-num @ @ @ ~])
      =/  args=^path  ?.(=(%json i.t.path) t.t.path t.t.t.path)
      ?.  ?=([@ @ @ ~] args)  (on-peek:def path)
      =/  epoch-num=@ud  (slav %ud i.args)
      =/  block-num=@ud  (slav %ud i.t.args)
      =/  town-id=@ud  (slav %ud i.t.t.args)
      =/  =update:ui
        (serve-update %chunk [epoch-num block-num town-id])
      (make-peek-update =(%json i.t.path) update)
    ::
        $?  [%x %block-hash @ ~]
            :: [%x %chunk-hash @ @ ~]
            [%x %egg @ ~]
            [%x %from @ ~]
            [%x %grain @ ~]
            [%x %holder @ ~]
            [%x %lord @ ~]
            [%x %to @ ~]
            [%x %json %block-hash @ ~]
            :: [%x %json %chunk-hash @ @ ~]
            [%x %json %egg @ ~]
            [%x %json %from @ ~]
            [%x %json %grain @ ~]
            [%x %json %holder @ ~]
            [%x %json %lord @ ~]
            [%x %json %to @ ~]
        ==
      =/  args=^path  ?.(=(%json i.t.path) t.path t.t.path)
      ?.  ?=([@ @ ~] args)  (on-peek:def path)
      =/  =query-type:ui  ;;(query-type:ui i.args)
      =/  hash=@ux  (slav %ux i.t.args)
      =/  =update:ui  (serve-update query-type hash)
      (make-peek-update =(%json i.t.path) update)
    ::
        [%x %headers @ ~]
      =/  num-headers=@ud  (slav %ud i.t.t.path)
      :^  ~  ~  %indexer-headers
      !>  ^-  (list [epoch-num=@ud =block-header:zig])
      ?~  recent-headers  ~
      %+  scag
        num-headers
      ^-  (list [epoch-num=@ud =block-header:zig])
      recent-headers
    ::
        ?([%x %slot ~] [%x %json %slot ~])
      =/  up=(unit update:ui)  get-newest-slot-update
      (make-peek-update =(%json i.t.path) ?~(up ~ u.up))
    ::
        ?([%x %slot-num @ @ ~] [%x %json %slot-num @ @ ~])
      =/  args=^path  ?.(=(%json i.t.path) t.t.path t.t.t.path)
      ?.  ?=([@ @ ~] args)  (on-peek:def path)
      =/  epoch-num=@ud  (slav %ud i.args)
      =/  block-num=@ud  (slav %ud i.t.args)
      =/  =update:ui
        (serve-update %slot epoch-num block-num)
      (make-peek-update =(%json i.t.path) update)
    ::
        ?([%x %id @ ~] [%x %json %id @ ~])
      =/  hash=@ux
        %+  slav  %ux
        ?.  =(%json i.t.path)
          i.t.t.path 
        ?.  ?=([@ @ @ @ ~] path)  (on-peek:def path)
        i.t.t.t.path
      =/  =update:ui  (get-ids hash)
      (make-peek-update =(%json i.t.path) update)
    ::
        ?([%x %hash @ ~] [%x %json %hash @ ~])
      =/  hash=@ux
        %+  slav  %ux
        ?.  =(%json i.t.path)
          i.t.t.path 
        ?.  ?=([@ @ @ @ ~] path)  (on-peek:def path)
        i.t.t.t.path
      =/  =update:ui  (get-hashes hash)
      (make-peek-update =(%json i.t.path) update)
    ::
    ==
    ::
    ++  make-peek-update
      |=  [is-json=? =update:ui]
      ?.  is-json
        [~ ~ %indexer-update !>(`update:ui`update)]
      [~ ~ %json !>(`json`(update:enjs:ui-lib update))]
    ::
    ++  get-ids
      |=  hash=@ux
      ^-  update:ui
      =/  egg=update:ui   (serve-update %egg hash)
      =/  from=update:ui  (serve-update %from hash)
      =/  to=update:ui    (serve-update %to hash)
      (combine-egg-updates ~[egg from to])
    ::
    ++  get-hashes
      |=  hash=@ux
      ^-  update:ui
      =/  egg=update:ui     (serve-update %egg hash)
      =/  from=update:ui    (serve-update %from hash)
      =/  grain=update:ui   (serve-update %grain hash)
      =/  holder=update:ui  (serve-update %holder hash)
      =/  lord=update:ui    (serve-update %lord hash)
      =/  slot=update:ui    (serve-update %block-hash hash)
      =/  to=update:ui      (serve-update %to hash)
      %^  combine-updates  ~[egg from to]
      ~[grain holder lord]  slot
    ::
    ++  get-newest-slot-update
      ^-  (unit update:ui)
      ?~  newest-epoch=(pry:poc:zig epochs)  ~
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        ~
      =*  epoch-start-time  start-time.val.u.newest-epoch
      =*  epoch-num  num.val.u.newest-epoch
      =*  slot  val.u.newest-slot
      =*  block-header  p.slot
      :+  ~  %slot
      %+  %~  put  by
          *(map id:smart [@da block-location:ui slot:zig])
        `@ux`data-hash.block-header
      :+  epoch-start-time  [epoch-num num.block-header]
      slot
    ::
    --
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    |^  ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
    ::
        [%chain-update ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        =/  old-source=(unit dock)
          (get-wex-dock-by-wire:ic wire)
        ?~  old-source  ~
        ~[(watch-chain-source:ic u.old-source)]
      ::
          %fact
        =^  cards  state
          %-  consume-ziggurat-update
          !<(update:zig q.cage.sign)
        [cards this]
      ::
      ==
    ::
        [%epochs-catchup ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        `this
      ::
          %fact
        =^  cards  state
          %-  consume-ziggurat-update
          !<(update:zig q.cage.sign)
        [cards this]
      ::
      ==
    ::
    ==
    ::
    :: +consume-indexer-update:
    :: https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L697
    ::
    ++  consume-ziggurat-update
      |=  =update:zig
      |^  ^-  (quip card _state)
      ?+    -.update
        ~|  "indexer: not consuming unexpected update {<-.update>}"
        !!
      ::
          %epochs-catchup
        =/  =epochs:zig  epochs.update
        =|  cards=(list card)
        |-
        ?~  epochs  [cards state]
        =/  epoch  (pop:poc:zig epochs)
        =*  epoch-num         num.val.head.epoch
        =*  epoch-start-time  start-time.val.head.epoch
        =/  =slots:zig  slots.val.head.epoch
        =+  ^=  [new-cards new-state]
            |-
            ?~  slots  [cards state]
            =/  slot  (pop:sot:zig slots)
            =+  ^=  [new-cards new-state]
                %^  consume-slot  epoch-num  epoch-start-time
                val.head.slot
            $(slots rest.slot, cards new-cards, state new-state)
        $(epochs rest.epoch, cards new-cards, state new-state)
      ::
          %indexer-block
        %^  consume-slot  epoch-num.update
        epoch-start-time.update  [header.update blk.update]
      ::
      ::  add %chunk handling? see e.g.
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L923
      ==
      ::
      ++  consume-slot
        |=  [epoch-num=@ud epoch-start-time=@da =slot:zig]
        ^-  (quip card _state)
        =*  header  p.slot
        =*  block   q.slot
        ?~  block  `state  :: TODO: log block header?
        =*  block-num  num.header
        =/  working-epoch=epoch:zig
          ?~  existing-epoch=(get:poc:zig epochs epoch-num)
            :^    num=epoch-num
                start-time=epoch-start-time
              order=~
            slots=(put:sot:zig *slots:zig block-num slot)
          %=  u.existing-epoch  ::  TODO: do more checks to avoid overwriting (unnecessary work)
              slots
            %^    put:sot:zig
                slots.u.existing-epoch
              block-num
            slot
          ==
        ::  store and index the new block
        ::
        =/  most-recent-parsed-block=parsed-block
          ((parse-block epoch-num block-num) slot)
        =*  block-hash  block-hash.most-recent-parsed-block
        =*  egg         egg.most-recent-parsed-block
        =*  from        from.most-recent-parsed-block
        =*  grain       grain.most-recent-parsed-block
        =*  holder      holder.most-recent-parsed-block
        =*  lord        lord.most-recent-parsed-block
        =*  to          to.most-recent-parsed-block
        =:  block-index     (~(gas ju block-index) block-hash)
            egg-index       (~(gas ju egg-index) egg)
            from-index      (~(gas ju from-index) from)
            grain-index     (~(gas ju grain-index) grain)
            holder-index    (~(gas ju holder-index) holder)
            lord-index      (~(gas ju lord-index) lord)
            to-index        (~(gas ju to-index) to)
            epochs          (put:poc:zig epochs epoch-num working-epoch)
            recent-headers
          :-  [epoch-num header]
          %+  scag
            (dec num-recent-headers)
          ^-  (list [epoch-num=@ud =block-header:zig])
          recent-headers
        ::
        ==
        |^
        :-  (make-all-sub-cards epoch-num block-num)
        state(previous-parsed-block most-recent-parsed-block)
        ::
        ++  make-sub-paths
          ^-  (jug @tas @u)
          %-  ~(gas ju *(jug @tas @u))
          %+  turn  ~(val by sup.bowl)
          |=  [ship sub-path=path]
          ^-  [@tas @u]
          :-  `@tas`-.sub-path
          ?:  ?=(%slot -.sub-path)  0  ::  unused placeholder
          ?:  ?=(%chunk -.sub-path)
            (slav %ud -.+.sub-path)
          (slav %ux -.+.sub-path)
        ::
        ++  make-all-sub-cards
          |=  [epoch-num=@ud block-num=@ud]
          ^-  (list card)
          =/  sub-paths=(jug @tas @u)  make-sub-paths
          |^
          %-  zing
          :~  (make-sub-cards %ud `[epoch-num block-num] %chunk /chunk)
              (make-sub-cards %ux ~ %from /id)
              (make-sub-cards %ux ~ %to /id)
              (make-sub-cards %ux ~ %grain /grain)
              (make-sub-cards %ux ~ %holder /holder)
              (make-sub-cards %ux ~ %lord /lord)
              ?~  (~(get by sub-paths) %slot)  ~
              :_  ~
              %+  fact:io
                :-  %indexer-update
                !>  ^-  update:ui
                :-  %slot
                %+  %~  put  by
                    *(map id:smart [@da block-location:ui slot:zig])
                  `@ux`data-hash.p.slot
                :+  start-time.working-epoch
                [epoch-num block-num]  slot
              ~[/slot]
          ==
          ::
          ++  make-sub-cards
            |=  $:  id-type=?(%ux %ud)
                    payload-prefix=(unit [@ud @ud])
                    =query-type:ui
                    path-prefix=path
                ==
            ^-  (list card)
            =/  serve-previous-update=_serve-update
              (make-one-block-serve-update previous-parsed-block)
            =/  serve-most-recent-update=_serve-update
              (make-one-block-serve-update most-recent-parsed-block)
            ::  for id-based subscriptions, get cards from both from and to.
            =/  path-type
              ?:(?=(?(%from %to) query-type) %id query-type)
            %+  murn  ~(tap in (~(get ju sub-paths) path-type))
            |=  id=@u
            =/  payload=?(@u [@ud @ud @u])
              ?~  payload-prefix  id
              [-.u.payload-prefix +.u.payload-prefix id]
            =/  old-update=update:ui
              (serve-previous-update query-type payload)
            =/  =update:ui
              (serve-most-recent-update query-type payload)
            ?:  (are-updates-same old-update update)  ~
            ?~  update  ~
            :-  ~
            %+  fact:io
              [%indexer-update !>(`update:ui`update)]
            ~[(snoc path-prefix (scot id-type id))]
          ::
          ++  are-updates-same
            ::  %.y if non-location portion of update is same
            ::  %.n if different
            |=  [p=update:ui q=update:ui]
            |^  ^-  ?
            ?~  p  ?=(~ q)
            ?~  q  %.n
            ?+    -.p  !!
            ::
                %chunk
              ?.  ?=(%chunk -.q)  %.n
              =(chunk.p chunk.q)
            ::
                %egg
              ?.  ?=(%egg -.q)  %.n
              .=  (make-id-egg-set eggs.p)
              (make-id-egg-set eggs.q)
            ::
                %grain
              ?.  ?=(%grain -.q)  %.n
              .=  (make-id-grain-set grains.p)
              (make-id-grain-set grains.q)
            ::
                %slot
              ?.  ?=(%slot -.q)  %.n
              .=  (make-id-slot-set slots.p)
              (make-id-slot-set slots.q)
            ::
            ==
            ::
            ++  make-id-egg-set
              |=  eggs=(map id:smart [@da egg-location:ui egg:smart])
              ^-  (set [id:smart egg:smart])
              %-  silt
              %+  turn  ~(tap by eggs)
              |=  [=id:smart @da egg-location:ui =egg:smart]
              [id egg]
            ::
            ++  make-id-grain-set
              |=  grains=(map id:smart [@da town-location:ui grain:smart])
              ^-  (set [id:smart grain:smart])
              %-  silt
              %+  turn  ~(tap by grains)
              |=  [=id:smart @da town-location:ui =grain:smart]
              [id grain]
            ::
            ++  make-id-slot-set
              |=  slots=(map id:smart [@da block-location:ui slot:zig])
              ^-  (set [id:smart slot:zig])
              %-  silt
              %+  turn  ~(tap by slots)
              |=  [=id:smart @da block-location:ui =slot:zig]
              [id slot]
            ::
            --
          ::
          --
        ::
        --
      ::
      ::  parse a given block into hash:location
      ::  pairs to be added to *-index
      ::
      ++  parse-block
        |_  [epoch-num=@ud block-num=@ud]
        ++  $
          |=  [=slot:zig]
          ^-  parsed-block
          ~|  "indexer: parse-block bailing on slot with null block"
          ?>  ?=(^ q.slot)
          =*  block-header  p.slot
          =*  block         u.q.slot
          =/  block-hash=(list [@ux block-location:ui])
            ~[[`@ux`data-hash.block-header epoch-num block-num]]  :: TODO: should key be @uvH?
          =|  egg=(list [@ux egg-location:ui])
          =|  from=(list [@ux second-order-location:ui])
          =|  grain=(list [@ux town-location:ui])
          =|  holder=(list [@ux second-order-location:ui])
          =|  lord=(list [@ux second-order-location:ui])
          =|  to=(list [@ux second-order-location:ui])
          =/  chunks=(list [town-id=@ud =chunk:zig])
            ~(tap by chunks.block)
          :-  block-hash
          |-
          ?~  chunks  [egg from grain holder lord to]
          =*  town-id  town-id.i.chunks
          =*  chunk    chunk.i.chunks
          ::
          =+  ^=  [new-egg new-from new-grain new-holder new-lord new-to]
              (parse-chunk town-id chunk)
          %=  $
              chunks  t.chunks
              egg     (weld egg new-egg)
              from    (weld from new-from)
              grain   (weld grain new-grain)
              holder  (weld holder new-holder)
              lord    (weld lord new-lord)
              to      (weld to new-to)
          ==
        ::
        ++  parse-chunk
          |=  [town-id=@ud =chunk:zig]
          ^-  $:  (list [@ux egg-location:ui])
                  (list [@ux second-order-location:ui])
                  (list [@ux town-location:ui])
                  (list [@ux second-order-location:ui])
                  (list [@ux second-order-location:ui])
                  (list [@ux second-order-location:ui])
              ==
          =*  txs      -.chunk
          =*  granary  p.+.chunk
          ::
          =+  [new-grain new-holder new-lord]=(parse-granary town-id granary)
          =+  [new-egg new-from new-to]=(parse-transactions town-id txs)
          [new-egg new-from new-grain new-holder new-lord new-to]
        ::
        ++  parse-granary
          |=  [town-id=@ud =granary:seq]
          ^-  $:  (list [@ux town-location:ui])
                  (list [@ux second-order-location:ui])
                  (list [@ux second-order-location:ui])
              ==
          =|  parsed-grain=(list [@ux town-location:ui])
          =|  parsed-holder=(list [@ux second-order-location:ui])
          =|  parsed-lord=(list [@ux second-order-location:ui])
          =/  grains=(list [@ux grain:smart])
            ~(tap by granary)
          |-
          ?~  grains  [parsed-grain parsed-holder parsed-lord]
          =*  grain-id   id.i.grains
          =*  holder-id  holder.i.grains
          =*  lord-id    lord.i.grains
          %=  $
              grains  t.grains
              parsed-grain
            :_  parsed-grain
            :-  grain-id
            [epoch-num block-num town-id]
          ::
              parsed-holder
            [[holder-id grain-id] parsed-holder]
          ::
              parsed-lord
            [[lord-id grain-id] parsed-lord]
          ::
          ==
        ::
        ++  parse-transactions
          |=  [town-id=@ud txs=(list [@ux egg:smart])]
          ^-  $:  (list [@ux egg-location:ui])
                  (list [@ux second-order-location:ui])
                  (list [@ux second-order-location:ui])
              ==
          =|  parsed-egg=(list [@ux egg-location:ui])
          =|  parsed-from=(list [@ux second-order-location:ui])
          =|  parsed-to=(list [@ux second-order-location:ui])
          =/  egg-num=@ud  0
          |-
          ?~  txs  [parsed-egg parsed-from parsed-to]
          =*  tx-hash  -.i.txs
          =*  egg      +.i.txs
          =*  to       to.p.egg
          =*  from
            ?:  ?=(@ux from.p.egg)  from.p.egg
            id.from.p.egg
          =/  =egg-location:ui
            [epoch-num block-num town-id egg-num]
          %=  $
              txs          t.txs
              parsed-egg   [[tx-hash egg-location] parsed-egg]
              parsed-from  [[from tx-hash] parsed-from]
              parsed-to    [[to tx-hash] parsed-to]
              egg-num      +(egg-num)
          ==
        ::
        --
      ::
      --
    ::
    --
  ::
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  epochs-catchup-wire
  ^-  wire
  /epochs-catchup
::
++  chain-update-wire
  ^-  wire
  /chain-update
::
++  get-epoch-catchup
  |=  d=dock
  ^-  card
  %+  ~(watch pass:io epochs-catchup-wire)
  d  /validator/epoch-catchup/0
::
++  watch-chain-source
  |=  d=dock
  ^-  card
  %+  ~(watch pass:io chain-update-wire)
  :: TODO: improve (maybe metadata from zig and chunks from seq?)
  d  /indexer/updates
::
++  get-wex-dock-by-wire
  |=  w=wire
  ^-  (unit dock)
  ?:  =(0 ~(wyt by wex.bowl))  ~
  =/  wexs=(list [w=wire s=ship t=term])
    ~(tap in ~(key by wex.bowl))
  |-
  ?~  wexs  ~
  =*  wex  i.wexs
  ?.  =(w w.wex)
    $(wexs t.wexs)
  :-  ~
  [s.wex t.wex]
::
++  leave-chain-source
  ::  will only leave first chain-update wire;
  ::  should only ever be subscribed to one;
  ::  should we generalize anyways just in case?
  ^-  (unit card)
  =/  old-source=(unit dock)
    (get-wex-dock-by-wire chain-update-wire)
  ?~  old-source  ~
  :-  ~
  %-  ~(leave pass:io chain-update-wire)
  u.old-source
::
++  set-chain-source  :: TODO: is this properly generalized?
  |=  d=dock
  ^-  (quip card _state)
  =/  watch-card=card  (watch-chain-source d)
  :_  state
  =/  leave-card=(unit card)  leave-chain-source
  ?~  leave-card
    ~[(get-epoch-catchup d) watch-card]
  ~[u.leave-card watch-card]
::
++  get-slot
  |=  [epoch-num=@ud block-num=@ud]
  ^-  (unit slot:zig)
  ?~  epoch=(get:poc:zig epochs epoch-num)  ~
  (get:sot:zig slots.u.epoch block-num)
::
++  get-chunk
  |=  [epoch-num=@ud block-num=@ud town-id=@ud]
  ^-  (unit chunk:zig)
  ?~  slot=(get-slot epoch-num block-num)  ~
  ?~  block=q.u.slot                       ~
  (~(get by chunks.u.block) town-id)
::
++  get-epoch-start-time
  |=  epoch-num=@ud
  ^-  (unit @da)
  ?~  epoch=(get:poc:zig epochs epoch-num)  ~
  `start-time.u.epoch
::
++  combine-egg-updates
  |=  updates=(list update:ui)
  ^-  update:ui
  ?~  update=(combine-egg-updates-to-map updates)  ~
  [%egg update]
::
++  combine-egg-updates-to-map
  |=  updates=(list update:ui)
  ^-  (map id:smart [@da egg-location:ui egg:smart])
  ?~  updates  ~
  =/  combined=(map id:smart [@da egg-location:ui egg:smart])
    %-  %~  gas  by
        *(map id:smart [@da egg-location:ui egg:smart])
    %-  zing
    %+  turn  updates
    |=  =update:ui
    ?~  update             ~
    ?.  ?=(%egg -.update)  ~
    ~(tap by eggs.update)
  combined
::
++  combine-grain-updates-to-map
  |=  updates=(list update:ui)
  ^-  (map id:smart [@da town-location:ui grain:smart])
  ?~  updates  ~
  =/  combined=(map id:smart [@da town-location:ui grain:smart])
    %-  %~  gas  by
        *(map id:smart [@da town-location:ui grain:smart])
    %-  zing
    %+  turn  updates
    |=  =update:ui
    ?~  update               ~
    ?.  ?=(%grain -.update)  ~
    ~(tap by grains.update)
  combined
::
++  combine-updates
  |=  $:  egg-updates=(list update:ui)
          grain-updates=(list update:ui)
          slot-update=update:ui
      ==
  ^-  update:ui
  ?:  ?&  ?=(~ egg-updates)
          ?=(~ grain-updates)
          ?=(~ slot-update)
      ==
    ~
  =/  combined-egg=(map id:smart [@da egg-location:ui egg:smart])
    (combine-egg-updates-to-map egg-updates)
  =/  combined-grain=(map id:smart [@da town-location:ui grain:smart])
    (combine-grain-updates-to-map grain-updates)
  =/  slot=(map id:smart [@da block-location:ui slot:zig])
    ?.  &(?=(^ slot-update) ?=(%slot -.slot-update))  ~
    slots.slot-update
  ?:  ?&  ?=(~ combined-egg)
          ?=(~ combined-grain)
          ?=(~ slot)
      ==
    ~
  [%hash combined-egg combined-grain slot]
::
++  make-one-block-serve-update
  |=  $:  block-hash=(list [@ux block-location:ui])
          egg=(list [@ux egg-location:ui])
          from=(list [@ux second-order-location:ui])
          grain=(list [@ux town-location:ui])
          holder=(list [@ux second-order-location:ui])
          lord=(list [@ux second-order-location:ui])
          to=(list [@ux second-order-location:ui])
      ==
  ::  pass only most recent update to subs
  ^-  _serve-update
  %=  serve-update
      block-index
    (~(gas ju *(jug @ux block-location:ui)) block-hash)
  ::
      egg-index
    (~(gas ju *(jug @ux egg-location:ui)) egg)
  ::
      from-index
    (~(gas ju *(jug @ux second-order-location:ui)) from)
  ::
      grain-index
    (~(gas ju *(jug @ux town-location:ui)) grain)
  ::
      holder-index
    (~(gas ju *(jug @ux second-order-location:ui)) holder)
  ::
      lord-index
    (~(gas ju *(jug @ux second-order-location:ui)) lord)
  ::
      to-index
    (~(gas ju *(jug @ux second-order-location:ui)) to)
  ::
  ==
::
++  serve-update
  |=  [=query-type:ui =query-payload:ui]
  |^  ^-  update:ui
  ?+    query-type  !!
  ::
      %chunk
    ?.  ?=(town-location:ui query-payload)  ~
    =/  slot=(unit slot:zig)
      %+  get-slot  epoch-num.query-payload
      block-num.query-payload
    ?~  slot  ~
    ?~  q.u.slot  ~
    =/  epoch-start-time=(unit @da)
      (get-epoch-start-time epoch-num.query-payload)
    ?~  epoch-start-time  ~
    =*  chunks  chunks.u.q.u.slot
    =/  chunk=(unit chunk:zig)
      (~(get by chunks) town-id.query-payload)
    ?~  chunk  ~
    [%chunk u.epoch-start-time query-payload u.chunk]
  ::
  ::     %chunk-hash
  ::   get-chunk-update
  ::
      ?(%block-hash %egg %from %grain %holder %lord %to)
    get-from-index
  ::
      %slot
    ?.  ?=(block-location:ui query-payload)  ~
    (get-slot-update query-payload)
  ::
  ==
  ::
  ++  get-slot-update
    |=  [epoch-num=@ud block-num=@ud]
    ^-  update:ui
    ?~  slot=(get-slot epoch-num block-num)  ~
    =/  epoch-start-time=(unit @da)
      (get-epoch-start-time epoch-num)
    ?~  epoch-start-time  ~
    =*  block-header  p.u.slot
    :-  %slot
    %+  %~  put  by
        *(map id:smart [@da block-location:ui slot:zig])
      `@ux`data-hash.block-header
    [u.epoch-start-time [epoch-num block-num] u.slot]
  ::
  ++  get-chunk-update
    ^-  update:ui
    =/  locations=(list location:ui)
      ~(tap in get-locations)
    ?.  =(1 (lent locations))
      ~&  >>>  "indexer: chunk not unique; returning null"
      ~
    =/  =location:ui  (snag 0 locations)
    ?.  ?=(town-location:ui location)  ~
    ?~  chunk=(get-chunk location)     ~
    =/  epoch-start-time=(unit @da)
      (get-epoch-start-time epoch-num.location)
    ?~  epoch-start-time  ~
    [%chunk u.epoch-start-time location u.chunk]
  ::
  ++  get-from-index
    ^-  update:ui
    ?.  ?=(@ux query-payload)  ~
    =/  locations=(list location:ui)
      ~(tap in get-locations)
    |^
    ?+    query-type  !!
    ::
        %block-hash
      get-block-hash
    ::
        %grain
      get-grain
    ::
        %egg
      get-egg
    ::
        ?(%from %holder %lord %to)
      get-second-order
    ::
    ==
    ::
    ++  get-block-hash
      =/  num-locations=@ud  (lent locations)
      ?:  =(0 num-locations)  ~
      ?.  =(1 num-locations)
        ~&  >>>  "indexer: block hash not unique; returning null"
        ~
      =/  =location:ui  (snag 0 locations)
      ?.  ?=(block-location:ui location)  ~
      (get-slot-update location)
    ::
    ++  get-grain
      =|  grains=(map grain-id=id:smart [@da town-location:ui grain:smart])
      =.  locations
        %+  sort  ;;((list town-location:ui) locations)
        |=  [p=town-location:ui q=town-location:ui]
        ^-  ?
        ?:  (lth epoch-num.p epoch-num.q)  %.y
        ?.  =(epoch-num.p epoch-num.q)     %.n
        ?:  (lth block-num.p block-num.q)  %.y
        ?.  =(block-num.p block-num.q)     %.n
        (gte town-id.p town-id.q)
      |-
      ?~  locations
        ?~  grains  ~
        [%grain grains]
      =*  location  i.locations
      ?.  ?=(town-location:ui location)
        $(locations t.locations)
      ?~  chunk=(get-chunk location)
        $(locations t.locations)
      =*  granary  p.+.u.chunk
      ?~  grain=(~(get by granary) query-payload)
        $(locations t.locations)
      =/  epoch-start-time=(unit @da)
        (get-epoch-start-time epoch-num.location)
      ?~  epoch-start-time  $(locations t.locations)
      %=  $
          locations  t.locations
          grains
        %+  ~(put by grains)  id.u.grain
        [u.epoch-start-time location u.grain]
      ==
    ::
    ++  get-egg
      =|  eggs=(map id:smart [@da egg-location:ui egg:smart])
      |-
      ?~  locations
        ?~  eggs  ~
        [%egg eggs]
      =*  location  i.locations
      ?.  ?=(egg-location:ui location)
        $(locations t.locations)
      =/  chunk=(unit chunk:zig)
        %^  get-chunk  epoch-num.location
        block-num.location  town-id.location
      ?~  chunk  $(locations t.locations)  :: TODO: can we do better here?
      =*  egg-num  egg-num.location
      =*  txs  -.u.chunk
      ?.  (lth egg-num (lent txs))  $(locations t.locations)
      =/  epoch-start-time=(unit @da)
        (get-epoch-start-time epoch-num.location)
      ?~  epoch-start-time  $(locations t.locations)
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ?.  ?|  =(query-payload hash)
              ?:  ?=(id:smart from.p.egg)
                =(query-payload from.p.egg)
              =(query-payload id.from.p.egg)
              =(query-payload to.p.egg)
          ==
        ~&  >>>  "uqbar-indexer: location points to incorrect egg. query type, payload, hash, location, egg: {<query-type>}, {<query-payload>}, {<hash>}, {<location>}, {<egg>}"
        $(locations t.locations)
      %=  $
          locations  t.locations
          eggs
        (~(put by eggs) hash [u.epoch-start-time location egg])
      ==
    ::
    ++  get-second-order
      %+  roll  locations
      |=  $:  second-order-id=location:ui
              out=update:ui
          ==
      =/  next-update=update:ui
        %=  get-from-index
            query-payload  second-order-id
            query-type
          ?:  |(?=(%holder query-type) ?=(%lord query-type))
            %grain
          %egg
        ==
      ?~  next-update  out
      ?~  out          next-update
      ?+  -.out  !!
      ::
          %egg
        ?.  ?=(%egg -.next-update)  out
        %=  out
            eggs
          (~(uni by eggs.out) eggs.next-update)
        ==
      ::
          %grain
        ?.  ?=(%grain -.next-update)  out
        %=  out
            grains
          (~(uni by grains.out) grains.next-update)
        ==
      ::
      ==
    ::
    --
  ::
  ++  get-locations
    ^-  (set location:ui)
    ?>  ?=(@ux query-payload)
    ?+    query-type  !!
    ::
        %block-hash
      (~(get ju block-index) query-payload)
    ::
        %egg
      (~(get ju egg-index) query-payload)
    ::
        %from
      (~(get ju from-index) query-payload)
    ::
        %grain
      (~(get ju grain-index) query-payload)
    ::
        %holder
      (~(get ju holder-index) query-payload)
    ::
        %lord
      (~(get ju lord-index) query-payload)
    ::
        %to
      (~(get ju to-index) query-payload)
    ::
    ==
  ::
  --
--
