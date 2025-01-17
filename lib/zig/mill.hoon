/+  *zink-zink, smart=zig-sys-smart, ethereum
/*  zink-cax   %noun  /lib/zig/compiled/hash-cache/noun
=,  smart
|_  library=vase
::
++  shut                                               ::  slam a door
  |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
  ^-  vase
  %+  slap
    (slop dor (slop dor-sam arm-sam))
  ^-  hoon
  :-  %cnsg
  :^    [%$ ~]
      [%cnsg [arm ~] [%$ 2] [%$ 6] ~]  ::  replace sample
    [%$ 7]
  ~
::
++  ajar                                               ::  partial shut
  |=  [dor=vase arm=@tas dor-sam=vase arm-sam=vase]
  ^-  (pair)
  =/  typ=type
    [%cell p.dor [%cell p.dor-sam p.arm-sam]]
  =/  gen=hoon
    :-  %cnsg
    :^    [%$ ~]
        [%cnsg [arm ~] [%$ 2] [%$ 6] ~]
      [%$ 7]
    ~
  =/  gun  (~(mint ut typ) %noun gen)
  [[q.dor [q.dor-sam q.arm-sam]] q.gun]
::
::  +hole: vase-checks your types for you
::
++  hole
  |*  [typ=mold val=*]
  ^-  typ
  !<(typ [-:!>(*typ) val])
::
++  mill
  |_  [miller=account town-id=@ud blocknum=@ud]
  ::
  ::  +mill-all: mills all eggs in basket
  ::
  ++  mill-all
    |=  [=town basket=(list egg)]
    =/  pending
      %+  sort  basket
      |=  [a=egg b=egg]
      (gth rate.p.a rate.p.b)
    =|  [processed=(list [@ux egg]) reward=@ud]
    |-
    ^-  [(list [@ux egg]) ^town]  ::  TODO add 'crow's to chunk -- list of announcements
    ?~  pending
      [processed town(p (~(pay tax p.town) reward))]
    =+  [res fee err]=(mill town i.pending)
    =+  i.pending(status.p err)
    %_  $
      pending    t.pending
      processed  [[`@ux`(shax (jam -)) -] processed]
      town       res
      reward     (add reward fee)
    ==
  ::
  ::  +mill: processes a single egg and returns updated town
  ::
  ++  mill
    |=  [=town =egg]
    ^-  [^town fee=@ud =errorcode]
    ?.  ?=(account from.p.egg)  [town 0 %1]
    ::  validate transaction signature
    ::  using ecdsa-raw-sign in wallet, TODO review this
    ::  comment this out if testing mill
    ::  TODO figure out how to guarantee raw-recover non-crashing
    =?  v.sig.p.egg  (gte v.sig.p.egg 27)  (sub v.sig.p.egg 27)
    =/  recovered
      %+  ecdsa-raw-recover:secp256k1:secp:crypto
        ?~(eth-hash.p.egg (sham (jam q.egg)) u.eth-hash.p.egg)
      sig.p.egg
    =/  caller-address
      ?~  eth-hash.p.egg
        %-  compress-point:secp256k1:secp:crypto
        recovered
      %-  address-from-pub:key:ethereum
      %-  serialize-point:secp256k1:secp:crypto
      recovered
    ?.  =(id.from.p.egg caller-address)
    ~&  >>>  "mill: signature mismatch: expected {<id.from.p.egg>}, got {<`@ux`caller-address>}"
      [town 0 %2]  ::  signed tx doesn't match account
    ::
    ?.  =(nonce.from.p.egg +((~(gut by q.town) id.from.p.egg 0)))
      ~&  >>>  "tx rejected; bad nonce"
      [town 0 %3]  ::  bad nonce
    ::
    ?.  (~(audit tax p.town) egg)
      ~&  >>>  "tx rejected; not enough budget"
      [town 0 %4]  ::  can't afford gas
    ::
    =+  [gan rem err]=(~(work farm p.town) egg)
    =/  fee=@ud   (sub budget.p.egg rem)
    :_  [fee err]
    :-  (~(charge tax ?~(gan p.town u.gan)) from.p.egg fee)
    (~(put by q.town) id.from.p.egg nonce.from.p.egg)
  ::
  ::  +tax: manage payment for egg in zigs
  ::
  ++  tax
    |_  =granary
    +$  token-account
      $:  balance=@ud
          allowances=(map sender=id:smart @ud)
          metadata=id:smart
      ==
    ::  +audit: evaluate whether a caller can afford gas
    ++  audit
      |=  =egg
      ^-  ?
      ?.  ?=(account from.p.egg)                    %.n
      ?~  zigs=(~(get by granary) zigs.from.p.egg)  %.n
      ?.  =(zigs-wheat-id lord.u.zigs)              %.n
      ?.  ?=(%& -.germ.u.zigs)                      %.n
      =/  acc  (hole token-account data.p.germ.u.zigs)
      (gth balance.acc budget.p.egg)
    ::  +charge: extract gas fee from caller's zigs balance
    ++  charge
      |=  [payee=account fee=@ud]
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.payee)  granary
      ?.  ?=(%& -.germ.u.zigs)                 granary
      =/  acc  (hole token-account data.p.germ.u.zigs)
      =.  balance.acc  (sub balance.acc fee)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.payee u.zigs)
    ::  +pay: give fees from eggs to miller
    ++  pay
      |=  total=@ud
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.miller)  granary
      ?.  ?=(%& -.germ.u.zigs)                  granary
      =/  acc  (hole token-account data.p.germ.u.zigs)
      ?.  =(`@ux`'zigs-metadata' metadata.acc)  granary
      =.  balance.acc  (add balance.acc total)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.miller u.zigs)
    --
  ::
  ::  +farm: execute a call to a contract
  ::
  ++  farm
    |_  =granary
    ::  +work: take egg and return updated granary, remaining budget, and errorcode (0=success)
    ++  work
      |=  =egg
      ^-  [(unit ^granary) rem=@ud =errorcode]
      =/  hatchling
        (incubate egg(budget.p (div budget.p.egg rate.p.egg)))
      ?~  final.hatchling
        [~ rem.hatchling errorcode.hatchling]
      +.hatchling
    ::  +incubate: fertilize and germinate, then grow
    ++  incubate
      |=  =egg
      ^-  [(unit rooster) final=(unit ^granary) rem=@ud =errorcode]
      |^
      =/  args  (fertilize q.egg)
      ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
        ~&  >>>  "mill: failed to germinate"
        [~ ~ budget.p.egg %5]
      (grow u.stalk args egg)
      ::  +fertilize: take yolk (contract arguments) and populate with granary data
      ++  fertilize
        |=  =yolk
        ^-  embryo
        ?.  ?=(account caller.yolk)  !!
        :+  caller.yolk
          args.yolk
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in my-grains.yolk)
        |=  =id
        ?~  res=(~(get by granary) id)      ~
        ?.  ?=(%& -.germ.u.res)             ~
        ?.  =(holder.u.res id.caller.yolk)  ~
        ?.  =(town-id.u.res town-id)        ~
        `[id u.res]
      ::  +germinate: take contract-owned grains in egg and populate with granary data
      ++  germinate
        |=  [find=id grains=(set id)]
        ^-  (unit crop)
        ?~  gra=(~(get by granary) find)  ~
        ?.  ?=(%| -.germ.u.gra)           ~
        ?~  cont.p.germ.u.gra             ~
        :+  ~
          u.cont.p.germ.u.gra
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in grains)
        |=  =id
        ?~  res=(~(get by granary) id)  ~
        ?.  ?=(%& -.germ.u.res)         ~
        ?.  =(lord.u.res find)          ~
        ?.  =(town-id.u.res town-id)    ~
        `[id u.res]
      ::  ++  telescope
      ::    |=  =wheat
      ::    cons together the library nocks against q.q.smart-lib
      --
    ::  +grow: recursively apply any calls stemming from egg, return on rooster or failure
    ++  grow
      |=  [=crop =embryo =egg]
      ^-  [(unit rooster) final=(unit ^granary) rem=@ud =errorcode]
      |^
      =+  [chick rem err]=(weed to.p.egg budget.p.egg)
      ?~  chick  [~ ~ rem err]
      ?:  ?=(%& -.u.chick)
        ::  rooster result, finished growing
        ?~  gan=(harvest p.u.chick to.p.egg from.p.egg)
          [~ ~ rem %7]
        [`p.u.chick gan rem err]
      ::  hen result, continuation
      =*  next  next.p.u.chick
      ::  continuation calls can alter grains
      ?~  gan=(harvest roost.p.u.chick to.p.egg from.p.egg)
        [~ ~ rem %7]
      %-  ~(incubate farm u.gan)
      egg(from.p to.p.egg, to.p to.next, budget.p rem, q args.next)
      ::
      ::  +weed: run contract formula with arguments and memory, bounded by bud
      ::
      ++  weed
        |=  [to=id budget=@ud]
        ^-  [(unit chick) rem=@ud =errorcode]
        ~>  %bout
        =/  =cart  [to blocknum town-id owns.crop]
        =/  payload  .*(q.library pay.cont.crop)
        =/  battery  .*([q.library payload] bat.cont.crop)
        =/  dor      [-:!>(*contract) battery]
        ::  ~&  >>>  cart
        ::  ~&  >>  embryo
        ::  this simply SHUTs
        ::
        =/  res
          (mule |.(;;(chick q:(shut dor %write !>(cart) !>(embryo)))))^(sub budget 7)
        ?:  ?=(%| -.-.res)
          ::  error in contract execution
          [~ budget %6]
        ::
        [`p.-.res budget %0]
        ::  this uses ZINK
        ::  
        ::  ~&  >  %contract-compiled
        ::  =/  cax=(map * phash)  ;;(cache (cue q.q.zink-cax))
        ::  ~&  >  %cax-compiled
        ::  =/  gun
        ::    (ajar dor %write !>(cart) !>(embryo))
        ::  =/  =book
        ::    (zebra budget cax gun)
        ::  ~&  >>  chick+(hole (unit chick) p.p.book)
        ::  ?:  ?=(%| -.p.book)
        ::    ::  error in contract execution
        ::    [~ budget %6]
        ::  ::  chick result
        ::  ?~  p.p.book
        ::    [~ 0 %0]
        ::  [`(hole chick u.p.p.book) bud.q.book %0]
      --
    ::
    ::  +harvest: take a completed execution and validate all changes and additions to granary state
    ::
    ++  harvest
      |=  [res=rooster lord=id from=caller]
      ^-  (unit ^granary)
      =-  ?.  -
            ~&  >>>  "harvest checks failed"
            ~
          `(~(uni by granary) (~(uni by changed.res) issued.res))
      ?&  %-  ~(all in changed.res)
          |=  [=id =grain]
          ::  all changed grains must already exist AND
          ::  new grain must be same type as old grain AND
          ::  id in changed map must be equal to id in grain AND
          ::  if rice, salt must not change AND
          ::  no changed grains may also have been issued at same time AND
          ::  only grains that proclaim us lord may be changed
          =/  old  (~(get by granary) id)
          ?&  ?=(^ old)
              ?:  ?=(%& -.germ.u.old)
                &(?=(%& -.germ.grain) =(salt.p.germ.u.old salt.p.germ.grain))
              =(%| -.germ.grain)
              =(id id.grain)
              !(~(has by issued.res) id)
              =(lord lord.u.old)
          ==
        ::
          %-  ~(all in issued.res)
          |=  [=id =grain]
          ::  id in issued map must be equal to id in grain AND
          ::  all newly issued grains must have properly-hashed id AND
          ::  lord of grain must be contract issuing it AND
          ::  grain must not yet exist at that id AND
          ::  grain IDs must match defined hashing functions
          ?&  =(id id.grain)
              =(lord lord.grain)
              !(~(has by granary) id.grain)
              ?:  ?=(%& -.germ.grain)
                =(id (fry-rice holder.grain lord.grain town-id.grain salt.p.germ.grain))
              =(id (fry-contract lord.grain town-id.grain cont.p.germ.grain))
      ==  ==
    --
  --
--
