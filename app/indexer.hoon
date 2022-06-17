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
    zig=ziggurat
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
:: +$  parsed-block
::   $:  block-hash=(list [@ux block-location:ui])
::       egg=(list [@ux egg-location:ui])
::       from=(list [@ux second-order-location:ui])
::       grain=(list [@ux town-location:ui])
::       holder=(list [@ux second-order-location:ui])
::       lord=(list [@ux second-order-location:ui])
::       to=(list [@ux second-order-location:ui])
::   ==
::
+$  base-state-0
  $:  :: =epochs:zig
      =batches-by-town
      num-recent-headers=@ud
      :: recent-headers=(list [epoch-num=@ud =block-header:zig])
      :: previous-parsed-block=parsed-block
  ==
+$  indices-0
  $:  egg-index=(map @ux (jar @ux egg-location:ui))
      from-index=(map @ux (jar @ux second-order-location:ui))
      grain-index=(map @ux (jar @ux batch-location:ui))
      holder-index=(map @ux (jar @ux second-order-location:ui))
      lord-index=(map @ux (jar @ux second-order-location:ui))
      to-index=(map @ux (jar @ux second-order-location:ui))
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
  ++  on-save  !>(-.state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state [%0 old *indices-0])  ::  TODO: index old -> indices-0
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
    (on-watch:def path)
    :: ?+    path  (on-watch:def path)
    :: ::
    ::     [%chunk @ ~]
    ::   :_  this
    ::   =/  town-id=@ud  (slav %ud i.t.path)
    ::   ?~  newest-epoch=(pry:poc:zig epochs)  ~
    ::   ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
    ::     ~
    ::   =*  newest-block  q.val.u.newest-slot
    ::   ?~  newest-block  ~
    ::   =*  newest-chunks  chunks.u.newest-block
    ::   =/  newest-chunk  (~(get by newest-chunks) town-id)
    ::   ?~  newest-chunk  ~
    ::   =*  epoch-start-time  start-time.val.u.newest-epoch
    ::   :_  ~
    ::   %-  fact:io
    ::   :_  ~
    ::   :-  %indexer-update
    ::   !>  ^-  update:ui
    ::   :^  %chunk  epoch-start-time
    ::     :+  epoch-num=num.val.u.newest-epoch
    ::       block-num=num.p.val.u.newest-slot
    ::     town-id=town-id
    ::   u.newest-chunk
    :: ::
    ::     [%id @ ~]
    ::   =/  serve-previous-update=_serve-update
    ::     (make-one-block-serve-update previous-parsed-block)
    ::   :_  this
    ::   =/  payload=@ux  (slav %ux i.t.path)
    ::   =/  from=update:ui
    ::     (serve-previous-update %from payload)
    ::   =/  to=update:ui
    ::     (serve-previous-update %to payload)
    ::   =/  =update:ui  (combine-egg-updates ~[from to])
    ::   ?~  update  ~
    ::   :_  ~
    ::   %-  fact:io
    ::   :_  ~
    ::   [%indexer-update !>(`update:ui`update)]
    :: ::
    ::     ?([%grain @ ~] [%holder @ ~] [%lord @ ~])
    ::   =/  serve-previous-update=_serve-update
    ::     (make-one-block-serve-update previous-parsed-block)
    ::   :_  this
    ::   =/  query-type=?(%grain %holder %lord)  i.path
    ::   =/  payload=@ux  (slav %ux i.t.path)
    ::   ?~  update=(serve-previous-update query-type payload)
    ::     ~
    ::   :_  ~
    ::   %-  fact:io
    ::   :_  ~
    ::   [%indexer-update !>(`update:ui`update)]
    :: ::
    ::     [%slot ~]
    ::   :_  this
    ::   ?~  newest-epoch=(pry:poc:zig epochs)  ~
    ::   ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
    ::     ~
    ::   =*  epoch-num  num.val.u.newest-epoch
    ::   =*  slot  val.u.newest-slot
    ::   =*  block-header  p.slot
    ::   =*  epoch-start-time  start-time.val.u.newest-epoch
    ::   :_  ~
    ::   %-  fact:io
    ::   :_  ~
    ::   :-  %indexer-update
    ::   !>  ^-  update:ui
    ::   :-  %slot
    ::   %+  %~  put  by
    ::       *(map id:smart [@da block-location:ui slot:zig])
    ::     `@ux`data-hash.block-header
    ::   :+  epoch-start-time  [epoch-num num.block-header]
    ::   slot
    ::
    :: ==
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
    ^-  (unit (unit cage))
    (on-peek:def path)
  ::   |^  ^-  (unit (unit cage))
  ::   ?+    path  (on-peek:def path)
  ::   ::
  ::       [%x %block-height ~]
  ::     ?~  recent-headers  [~ ~]
  ::     =*  most-recent  i.recent-headers
  ::     :^  ~  ~  %noun
  ::     !>  ^-  [epoch-num=@ud block-num=@ud]
  ::     :-  epoch-num.most-recent
  ::     num.block-header.most-recent
  ::   ::
  ::       ?([%x %chunk-num @ @ @ ~] [%x %json %chunk-num @ @ @ ~])
  ::     =/  args=^path  ?.(=(%json i.t.path) t.t.path t.t.t.path)
  ::     ?.  ?=([@ @ @ ~] args)  (on-peek:def path)
  ::     =/  epoch-num=@ud  (slav %ud i.args)
  ::     =/  block-num=@ud  (slav %ud i.t.args)
  ::     =/  town-id=@ud  (slav %ud i.t.t.args)
  ::     =/  =update:ui
  ::       (serve-update %chunk [epoch-num block-num town-id])
  ::     (make-peek-update =(%json i.t.path) update)
  ::   ::
  ::       $?  [%x %block-hash @ ~]
  ::           :: [%x %chunk-hash @ @ ~]
  ::           [%x %egg @ ~]
  ::           [%x %from @ ~]
  ::           [%x %grain @ ~]
  ::           [%x %holder @ ~]
  ::           [%x %lord @ ~]
  ::           [%x %to @ ~]
  ::           [%x %json %block-hash @ ~]
  ::           :: [%x %json %chunk-hash @ @ ~]
  ::           [%x %json %egg @ ~]
  ::           [%x %json %from @ ~]
  ::           [%x %json %grain @ ~]
  ::           [%x %json %holder @ ~]
  ::           [%x %json %lord @ ~]
  ::           [%x %json %to @ ~]
  ::       ==
  ::     =/  args=^path  ?.(=(%json i.t.path) t.path t.t.path)
  ::     ?.  ?=([@ @ ~] args)  (on-peek:def path)
  ::     =/  =query-type:ui  ;;(query-type:ui i.args)
  ::     =/  hash=@ux  (slav %ux i.t.args)
  ::     =/  =update:ui  (serve-update query-type hash)
  ::     (make-peek-update =(%json i.t.path) update)
  ::   ::
  ::       [%x %headers @ ~]
  ::     =/  num-headers=@ud  (slav %ud i.t.t.path)
  ::     :^  ~  ~  %indexer-headers
  ::     !>  ^-  (list [epoch-num=@ud =block-header:zig])
  ::     ?~  recent-headers  ~
  ::     %+  scag
  ::       num-headers
  ::     ^-  (list [epoch-num=@ud =block-header:zig])
  ::     recent-headers
  ::   ::
  ::       ?([%x %slot ~] [%x %json %slot ~])
  ::     =/  up=(unit update:ui)  get-newest-slot-update
  ::     (make-peek-update =(%json i.t.path) ?~(up ~ u.up))
  ::   ::
  ::       ?([%x %slot-num @ @ ~] [%x %json %slot-num @ @ ~])
  ::     =/  args=^path  ?.(=(%json i.t.path) t.t.path t.t.t.path)
  ::     ?.  ?=([@ @ ~] args)  (on-peek:def path)
  ::     =/  epoch-num=@ud  (slav %ud i.args)
  ::     =/  block-num=@ud  (slav %ud i.t.args)
  ::     =/  =update:ui
  ::       (serve-update %slot epoch-num block-num)
  ::     (make-peek-update =(%json i.t.path) update)
  ::   ::
  ::       ?([%x %id @ ~] [%x %json %id @ ~])
  ::     =/  hash=@ux
  ::       %+  slav  %ux
  ::       ?.  =(%json i.t.path)
  ::         i.t.t.path 
  ::       ?.  ?=([@ @ @ @ ~] path)  (on-peek:def path)
  ::       i.t.t.t.path
  ::     =/  =update:ui  (get-ids hash)
  ::     (make-peek-update =(%json i.t.path) update)
  ::   ::
  ::       ?([%x %hash @ ~] [%x %json %hash @ ~])
  ::     =/  hash=@ux
  ::       %+  slav  %ux
  ::       ?.  =(%json i.t.path)
  ::         i.t.t.path 
  ::       ?.  ?=([@ @ @ @ ~] path)  (on-peek:def path)
  ::       i.t.t.t.path
  ::     =/  =update:ui  (get-hashes hash)
  ::     (make-peek-update =(%json i.t.path) update)
  ::   ::
  ::   ==
  ::   ::
  ::   ++  make-peek-update
  ::     |=  [is-json=? =update:ui]
  ::     ?.  is-json
  ::       [~ ~ %indexer-update !>(`update:ui`update)]
  ::     [~ ~ %json !>(`json`(update:enjs:ui-lib update))]
  ::   ::
  ::   ++  get-ids
  ::     |=  hash=@ux
  ::     ^-  update:ui
  ::     =/  egg=update:ui   (serve-update %egg hash)
  ::     =/  from=update:ui  (serve-update %from hash)
  ::     =/  to=update:ui    (serve-update %to hash)
  ::     (combine-egg-updates ~[egg from to])
  ::   ::
  ::   ++  get-hashes
  ::     |=  hash=@ux
  ::     ^-  update:ui
  ::     =/  egg=update:ui     (serve-update %egg hash)
  ::     =/  from=update:ui    (serve-update %from hash)
  ::     =/  grain=update:ui   (serve-update %grain hash)
  ::     =/  holder=update:ui  (serve-update %holder hash)
  ::     =/  lord=update:ui    (serve-update %lord hash)
  ::     :: =/  slot=update:ui    (serve-update %block-hash hash)
  ::     =/  to=update:ui      (serve-update %to hash)
  ::     %^  combine-updates  ~[egg from to]
  ::     ~[grain holder lord]  slot
  ::   ::
  ::   :: ++  get-newest-slot-update
  ::   ::   ^-  (unit update:ui)
  ::   ::   ?~  newest-epoch=(pry:poc:zig epochs)  ~
  ::   ::   ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
  ::   ::     ~
  ::   ::   =*  epoch-start-time  start-time.val.u.newest-epoch
  ::   ::   =*  epoch-num  num.val.u.newest-epoch
  ::   ::   =*  slot  val.u.newest-slot
  ::   ::   =*  block-header  p.slot
  ::   ::   :+  ~  %slot
  ::   ::   %+  %~  put  by
  ::   ::       *(map id:smart [@da block-location:ui slot:zig])
  ::   ::     `@ux`data-hash.block-header
  ::   ::   :+  epoch-start-time  [epoch-num num.block-header]
  ::   ::   slot
  ::   ::
  ::   --
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
          %-  consume-sequencer-update
          !<(indexer-update:seq q.cage.sign)
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
    ++  consume-sequencer-update
      |=  update=indexer-update:seq
      |^  ^-  (quip card _state)
      ?+    -.update
        ~|  "indexer: not consuming unexpected update {<-.update>}"
        !!
      ::
        ::   %epochs-catchup
        :: =/  =epochs:zig  epochs.update
        :: =|  cards=(list card)
        :: |-
        :: ?~  epochs  [cards state]
        :: =/  epoch  (pop:poc:zig epochs)
        :: =*  epoch-num         num.val.head.epoch
        :: =*  epoch-start-time  start-time.val.head.epoch
        :: =/  =slots:zig  slots.val.head.epoch
        :: =+  ^=  [new-cards new-state]
        ::     |-
        ::     ?~  slots  [cards state]
        ::     =/  slot  (pop:sot:zig slots)
        ::     =+  ^=  [new-cards new-state]
        ::         %^  consume-slot  epoch-num  epoch-start-time
        ::         val.head.slot
        ::     $(slots rest.slot, cards new-cards, state new-state)
        :: $(epochs rest.epoch, cards new-cards, state new-state)
      ::
          %update
        (consume-batch root.update eggs.update town.update)
      ::
      ::  add %chunk handling? see e.g.
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L923
      ==
      ::
      ++  jab-gas-ja
        |=  $:  index=(map town-id=@ux (jar @ux location:ui))
                new=(list [hash=@ux =location:ui])
                town-id=id:smart
            ==
        %+  ~(jab by index)  town-id
        |=  town-index=(jar @ux location:ui)
        |-
        ?~  new  town-index
        %=  $
            new  t.new
            town-index
          (~(add ja town-index) hash.i.new location.i.new)
        ==
      ::
      ++  consume-batch
        |=  [root=@ux eggs=(list [@ux egg:smart]) =town:seq]
        ^-  (quip card _state)
        =*  town-id  id.hall.town
        =/  [egg from grain holder lord to]
          (parse-batch root town-id eggs land.town)
        =:  egg-index     (jab-gas-ja egg-index egg)
            from-index    (jab-gas-ja from-index from)
            grain-index   (jab-gas-ja grain-index grain)
            holder-index  (jab-gas-ja holder-index holder)
            lord-index    (jab-gas-ja lord-index lord)
            to-index      (jab-gas-ja to-index to)
            batches-by-town
          %+  ~(put by batches-by-town)  town-id
          ?~  b=~(get by batches-by-town)
            :_  ~[root]
            (malt ~[[root [now.bowl eggs town]]])  ::  TODO: improve timestamping
          :_  [root batch-order.u.b]
          (~(put by batches.u.b) root [now.bowl eggs town])
          ::   recent-headers
          :: :-  [epoch-num header]
          :: %+  scag
          ::   (dec num-recent-headers)
          :: ^-  (list [epoch-num=@ud =block-header:zig])
          :: recent-headers
        ==
        |^
        [make-all-sub-cards state]
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
          ^-  (list card)
          =/  sub-paths=(jug @tas @u)  make-sub-paths
          |^
          %-  zing
          :~  :: (make-sub-cards %ud `[epoch-num block-num] %chunk /chunk)
              (make-sub-cards %ux ~ %from /id)
              (make-sub-cards %ux ~ %to /id)
              (make-sub-cards %ux ~ %grain /grain)
              (make-sub-cards %ux ~ %holder /holder)
              (make-sub-cards %ux ~ %lord /lord)
              :: ?~  (~(get by sub-paths) %slot)  ~
              :: :_  ~
              :: %+  fact:io
              ::   :-  %indexer-update
              ::   !>  ^-  update:ui
              ::   :-  %slot
              ::   %+  %~  put  by
              ::       *(map id:smart [@da block-location:ui slot:zig])
              ::     `@ux`data-hash.p.slot
              ::   :+  start-time.working-epoch
              ::   [epoch-num block-num]  slot
              :: ~[/slot]
          ==
          ::
          ++  make-sub-cards
            |=  $:  id-type=?(%ux %ud)
                    payload-prefix=(unit [@ud @ud])
                    =query-type:ui
                    path-prefix=path
                ==
            ^-  (list card)
            ::  for id-based subscriptions, get cards from both from and to
            =/  path-type
              ?:(?=(?(%from %to) query-type) %id query-type)
            %+  murn  ~(tap in (~(get ju sub-paths) path-type))
            |=  id=@u
            =/  payload=?(@u [@ud @ud @u])
              ?~  payload-prefix  id
              [-.u.payload-prefix +.u.payload-prefix id]
            ::  TODO: can improve performance here by:
            ::  * call get-locations
            ::  * handle second-order-locations
            ::  * compare batch-root with first element of batch-order
            ::  * same -> got diff; different -> pass
            =/  =update:ui  (serve-update query-type payload)
            ?~  update  ~
            ?.  %+  any  ~(val by +.update)
                |=  [timestamp=@da *]
                =(now.bowl timestamp)
              ~
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
                %batch
              ?.  ?=(%batch -.q)  %.n
              .=  (make-id-batch-set batches.p)
              (make-id-batch-set batches.q)
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
            ==
            ::
            ++  make-id-batch-set
              |=  batches=(map id:smart [@da town-location:ui batch:ui])
              ^-  (set [id:smart batch:ui])
              %-  silt
              %+  turn  ~(tap by batches)
              |=  [=id:smart @da town-location:ui =batch:ui]
              [id batch]
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
            --
          --
        --
      ::
      ++  parse-batch
        |=  [root=@ux town-id=@ux eggs=(list [@ux egg:smart]) =land:seq]
        ^-  $:  (list [@ux egg-location:ui])
                (list [@ux second-order-location:ui])
                (list [@ux batch-location:ui])
                (list [@ux second-order-location:ui])
                (list [@ux second-order-location:ui])
                (list [@ux second-order-location:ui])
            ==
        =*  granary  p.land
        =+  [new-grain new-holder new-lord]=(parse-granary root town-id granary)
        =+  [new-egg new-from new-to]=(parse-transactions root town-id eggs)
        [new-egg new-from new-grain new-holder new-lord new-to]
      ::
      ++  parse-granary
        |=  [root=@ux town-id=@ux =granary:smart]
        ^-  $:  (list [@ux batch-location:ui])
                (list [@ux second-order-location:ui])
                (list [@ux second-order-location:ui])
            ==
        =|  parsed-grain=(list [@ux batch-location:ui])
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
          [town-id root]
        ::
            parsed-holder
          [[holder-id grain-id] parsed-holder]
        ::
            parsed-lord
          [[lord-id grain-id] parsed-lord]
        ==
      ::
      ++  parse-transactions
        |=  [root=@ux town-id=@ux txs=(list [@ux egg:smart])]
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
        =/  =egg-location:ui  [town-id root egg-num]
        %=  $
            txs          t.txs
            parsed-egg   [[tx-hash egg-location] parsed-egg]
            parsed-from  [[from tx-hash] parsed-from]
            parsed-to    [[to tx-hash] parsed-to]
            egg-num      +(egg-num)
        ==
      --
    --
  ::
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
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
++  get-batch
  |=  [town-id=id:smart batch-root=id:smart]
  ^-  [@da (list [@ux egg:smart]) town]
  ?~  bs=(~(get by batches-by-town) town-id)  ~
  ?~  b=(~(get by batches.u.bs) batch-root)   ~
  u.b
::
++  combine-egg-updates
  |=  updates=(list update:ui)
  ^-  update:ui
  ?~  update=(combine-updates-to-map updates %egg)  ~
  :: ?~  update=(combine-egg-updates-to-map updates)  ~
  [%egg update]
::
++  combine-batch-updates-to-map
  |=  updates=(list update:ui)
  ^-  (map id:smart [@da town-location:ui batch:ui])
  ?~  updates  ~
  =/  combined=(map id:smart [@da town-location:ui batch:ui])
    %-  %~  gas  by
        *(map id:smart [@da town-location:ui batch:ui])
    %-  zing
    %+  turn  updates
    |=  =update:ui
    ?~  update               ~
    ?.  ?=(%batch -.update)  ~
    ~(tap by batches.update)
  combined
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
  ^-  (map id:smart [@da batch-location:ui grain:smart])
  ?~  updates  ~
  =/  combined=(map id:smart [@da batch-location:ui grain:smart])
    %-  %~  gas  by
        *(map id:smart [@da batch-location:ui grain:smart])
    %-  zing
    %+  turn  updates
    |=  =update:ui
    ?~  update               ~
    ?.  ?=(%grain -.update)  ~
    ~(tap by grains.update)
  combined
::
++  combine-updates-to-map
  |=  [updates=(list update:ui) type=?(%batch %egg %grain)]
  =/  map-type
    %+  map  id:smart
    :-  @da
    ?-  type
      %batch  [town-location:ui batch:ui]
      %egg    [egg-location:ui egg:smart]
      %grain  [batch-location:ui grain:smart]
    ==
  ^-  map-type
  ?~  updates  ~
  =/  combined=map-type
    %-  ~(gas by *map-type)
    %-  zing
    %+  turn  updates
    |=  =update:ui
    ?~  update            ~
    ?.  =(type -.update)  ~  ::  TODO: works? if yes, get rid of +combine-*-updates-to-map
    ~(tap by +.update)
  combined
::
++  combine-updates
  |=  $:  batch-updates=(list update:ui)
          egg-updates=(list update:ui)
          grain-updates=(list update:ui)
      ==
  ^-  update:ui
  ?:  ?&  ?=(~ batch-updates)
          ?=(~ egg-updates)
          ?=(~ grain-updates)
      ==
    ~
  :: =/  combined-batch=(map id:smart [@da town-location:ui batch:ui])
  ::   (combine-batch-updates-to-map batch-updates)
  :: =/  combined-egg=(map id:smart [@da egg-location:ui egg:smart])
  ::   (combine-egg-updates-to-map egg-updates)
  :: =/  combined-grain=(map id:smart [@da town-location:ui grain:smart])
  ::   (combine-grain-updates-to-map grain-updates)
  =/  combined-batch=(map id:smart [@da town-location:ui batch:ui])
    (combine-updates-to-map batch-updates %batch)
  =/  combined-egg=(map id:smart [@da egg-location:ui egg:smart])
    (combine-updates-to-map egg-updates %egg)
  =/  combined-grain=(map id:smart [@da town-location:ui grain:smart])
    (combine-updates-to-map grain-updates %grain)
  ?:  ?&  ?=(~ combined-batch)
          ?=(~ combined-egg)
          ?=(~ combined-grain)
      ==
    ~
  [%hash combined-batch combined-egg combined-grain]
::
++  serve-update
  |=  [=query-type:ui =query-payload:ui]
  |^  ^-  update:ui
  ?+    query-type  !!
    ::   %chunk
    :: ?.  ?=(town-location:ui query-payload)  ~
    :: =/  slot=(unit slot:zig)
    ::   %+  get-slot  epoch-num.query-payload
    ::   block-num.query-payload
    :: ?~  slot  ~
    :: ?~  q.u.slot  ~
    :: =/  epoch-start-time=(unit @da)
    ::   (get-epoch-start-time epoch-num.query-payload)
    :: ?~  epoch-start-time  ~
    :: =*  chunks  chunks.u.q.u.slot
    :: =/  chunk=(unit chunk:zig)
    ::   (~(get by chunks) town-id.query-payload)
    :: ?~  chunk  ~
    :: [%chunk u.epoch-start-time query-payload u.chunk]
  ::
  ::     %chunk-hash
  ::   get-chunk-update
  ::
      ?(%batch %egg %from %grain %holder %lord %to)
    get-from-index
  ::
  ==
  ::
  :: ++  get-slot-update
  ::   |=  [epoch-num=@ud block-num=@ud]
  ::   ^-  update:ui
  ::   ?~  slot=(get-slot epoch-num block-num)  ~
  ::   =/  epoch-start-time=(unit @da)
  ::     (get-epoch-start-time epoch-num)
  ::   ?~  epoch-start-time  ~
  ::   =*  block-header  p.u.slot
  ::   :-  %slot
  ::   %+  %~  put  by
  ::       *(map id:smart [@da block-location:ui slot:zig])
  ::     `@ux`data-hash.block-header
  ::   [u.epoch-start-time [epoch-num block-num] u.slot]
  :: ::
  :: ++  get-chunk-update
  ::   ^-  update:ui
  ::   =/  locations=(list location:ui)  get-locations
  ::   ?.  =(1 (lent locations))
  ::     ~&  >>>  "indexer: chunk not unique; returning null"
  ::     ~
  ::   =/  =location:ui  (snag 0 locations)
  ::   ?.  ?=(town-location:ui location)  ~
  ::   ?~  chunk=(get-chunk location)     ~
  ::   =/  epoch-start-time=(unit @da)
  ::     (get-epoch-start-time epoch-num.location)
  ::   ?~  epoch-start-time  ~
  ::   [%chunk u.epoch-start-time location u.chunk]
  ::
  ++  get-from-index
    ^-  update:ui
    ?.  ?=(?(@ [@ @]) query-payload)  ~
    =/  locations=(list location:ui)  get-locations
    |^
    ?+    query-type  !!
      ::   %batch  ::  TODO
      :: get-batch-hash
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
    :: ++  get-batch-hash
    ::   =/  num-locations=@ud  (lent locations)
    ::   ?:  =(0 num-locations)  ~
    ::   ?.  =(1 num-locations)
    ::     ~&  >>>  "indexer: batch hash not unique; returning null"
    ::     ~
    ::   =/  =location:ui  (snag 0 locations)
    ::   ?.  ?=(block-location:ui location)  ~
    ::   (get-slot-update location)
    ::
    ++  get-grain
      =|  grains=(map grain-id=id:smart [@da town-location:ui grain:smart])
      ::  TODO: is `jar` ordering correct to return most recent?
      |-
      ?~  locations  ?~(grains ~ [%grain grains])
      =*  location  i.locations
      ?.  ?=(batch-location:ui location)
        $(locations t.locations)
      =*  town-id  location
      =*  batch-root  batch-root.location
      =/  [timestamp=@da * [=granary:seq *] *]
        (get-batch town-id batch-root)
      ?~  grain=(~(get by granary) query-payload)
        $(locations t.locations)
      ::  TODO: get batch time
      :: =/  epoch-start-time=(unit @da)
      ::   (get-epoch-start-time epoch-num.location)
      :: ?~  epoch-start-time  $(locations t.locations)
      %=  $
          locations  t.locations
          grains
        %+  ~(put by grains)  query-payload
        [timestamp location u.grain]
      ==
    ::
    ++  get-egg
      =|  eggs=(map id:smart [@da egg-location:ui egg:smart])
      |-
      ?~  locations  ?~(eggs ~ [%egg eggs])
      =*  location  i.locations
      ?.  ?=(egg-location:ui location)
        $(locations t.locations)
      =*  town-id     town-id.location
      =*  batch-root  batch-root.location
      =*  egg-num     egg-num.location
      =/  [timestamp=@da eggs=(list [@ux egg:smart]) *]
        (get-batch town-id batch-root)
      ?.  (lth egg-num (lent eggs))  $(locations t.locations)
      ::  TODO: get batch time
      :: =/  epoch-start-time=(unit @da)
      ::   (get-epoch-start-time epoch-num.location)
      :: ?~  epoch-start-time  $(locations t.locations)
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ::  TODO: remove this paranoid check after testing
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
        (~(put by eggs) hash [timestamp location egg])
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
      ==
    ::
    ++  get-locations
      |^  ^-  (list location:ui)
      ?+    query-type  !!
        ::   %batch
        :: (~(get ja block-index) query-payload)
      ::
          %egg
        (get-by-get-ja egg-index query-payload)
      ::
          %from
        (get-by-get-ja from-index query-payload)
      ::
          %grain
        (get-by-get-ja grain-index query-payload)
      ::
          %holder
        (get-by-get-ja holder-index query-payload)
      ::
          %lord
        (get-by-get-ja lord-index query-payload)
      ::
          %to
        (get-by-get-ja to-index query-payload)
      ==
      ::
      ++  get-by-get-ja
        |=  [index=(map @ux (jar @ux location:ui)) =query-payload:ui]
        ^-  (list location:ui)
        ?:  ?=([@ @] query-payload)
          =*  town-id    -.query-payload
          =*  item-hash  +.query-payload
          (~(get ja (~(get by index) town-id)) item-hash)
        ?>  ?=(@ query-payload)
        =*  item-hash  query-payload
        %+  roll  ~(val by index)
        |=  [town-index=(jar @ux location:ui) out=(list location:ui)]
        (weld out (~(get ja town-index) item-hash))
      --
    --
  --
--
