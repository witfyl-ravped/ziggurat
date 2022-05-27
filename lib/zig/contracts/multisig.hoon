::  multisig.hoon  [uqbar-dao]
::
::  Smart contract to manage a simple multisig wallet.
::  New multisigs can be generated through the %create
::  argument, and are stored in account-controlled rice.
::
::/+  *zig-sys-smart
^-  contract  :: not strictly necessary but works well
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments u.args.inp) (pin caller.inp))
  ::
  ::  XX potentially add [%remove-tx tx-hash=@ux] if it makes sense?
  ::  XX potentially add expired txs?
  ::  XX potentially rename `arguments` to action/command??
  +$  arguments
    $%
      ::  any id can call the following
      ::
      [%create-multisig init-thresh=@ud members=(set id)]
      ::  All of the following expect the grain of the deployed multisig
      ::  to be the first and only argument to `cont-grains`
      :: 
      ::::  the following can be called by anyone in `members`
        ::
      [%vote tx-hash=@ux]
      [%submit-tx =egg]
        ::
        ::  the following must be sent by the contract
        ::  which means that they can only be executed by a passing vote
      [%add-member =id]
      [%remove-member =id]
      [%set-threshold new-thresh=@ud]
    ==
  ::
  +$  event
    $%
      [%vote-passed tx-hash=@ux votes=(set id)]
    ==
  ::
  +$  tx-hash  @ux
  +$  multisig-state
      $:  members=(set id)
          threshold=@ud
          pending=(map tx-hash [=egg votes=(set id)])
          :: submitted=(set tx-hash) could add this if it makes sense
      ==
  ::
  ++  is-member
    |=  [=id state=multisig-state]
    ^-  ?
    (~(has in members.state) id)
  ++  is-me
    |=  =id
    ^-  ?
    =(me.cart id)
  ++  shamspin
    |=  ids=(set id)
    ^-  @uvH
    =<  q
    %^  spin  ~(tap in ids)
      0v0
    |=  [=id hash=@uvH]
    [~ (sham (cat 3 hash (sham id)))]
  ++  event-to-json
    |=  [=event]
    ^-  [@tas json]
    ::  TODO implement
    =/  tag  -.event
    =/  jon
      %-  pairs
      :~  'eventName'  s+[`@t`tag]
      ==
    [tag jon]
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ^-  chick
    ?:  ?=(%create-multisig -.args)
      ::  issue a new multisig rice
      =/  salt=@
        %-  sham
        (cat 3 caller-id (shamspin members.args))
      ::  im pretty sure salt is supposed to go in the germ as well
      =/  new-sig-germ=germ  [%& salt [members.args init-thresh.args ~]]
      =/  new-sig-id=id      (fry-rice caller-id me.cart town-id.cart salt)
      =/  new-sig=grain      [new-sig-id me.cart me.cart town-id.cart new-sig-germ]
      [%& ~ (malt ~[[new-sig-id new-sig]]) ~]
    =/  my-grain=grain  -:~(val by owns.cart)
    ?>  =(lord.my-grain me.cart)
    ?>  ?=(%& -.germ.my-grain)
    =/  state=multisig-state  ;;(multisig-state data.p.germ.my-grain)
    ::  ?>  ?=(multisig-state data.p.germ.my-grain)  :: doesn't work due to fish-loop
    ::  N.B. because no type assert has been made, 
    ::  data.p.germ.my-grain is basically * and thus has no type checking done on its modification
    ::  therefore, we explicitly modify `state` to retain typechecking then modify `data`
    ::
    ::  TODO find a good alias name for data.p.germ.my-grain
    ?-    -.args
        %vote
      ?.  (is-member caller-id state)  !!
      =*  tx-hash        tx-hash.args
      =/  prop           (~(got by pending.state) tx-hash)
      =.  votes.prop     (~(put in votes.prop) caller-id)
      =.  pending.state  (~(put by pending.state) tx-hash prop)
      ::  check if proposal is at threshold, execute if so
      ::  otherwise simply update rice
      ?:  (gth threshold.state ~(wyt in votes.prop))
        ::  TODO emit crow event in rooster
        =.  pending.state         (~(del by pending.state) tx-hash)
        =.  data.p.germ.my-grain  state
        =/  crow=(list [@tas json])
          :~  (event-to-json [%vote-passed tx-hash votes.prop])
          ==
        ::
        =/  roost=rooster         [(malt ~[[id.my-grain my-grain]]) ~ crow]
        [%| [~ next=[to.p.egg town-id.p.egg q.egg]:prop roost]]
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %submit-tx
      ?.  (is-member caller-id state)  !!
      ::  TODO is mug appropriate here since its non-cryptographic?
      :: (i.e. collision potential can overwrite) another valid tx, however rare
      =.  pending.state         (~(put by pending.state) (mug egg.args) [egg.args (silt ~[caller-id])])
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
      ::  The following must be sent by the contract itself
      ::
        %add-member
      ?.  (is-me caller-id)  !!
      =.  members.state         (~(put in members.state) id.args)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %remove-member
      ?.  (is-me caller-id)  !!
      =.  members.state         (~(del in members.state) id)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %set-threshold
      ?.  (is-me caller-id)  !!
      =.  threshold.state       new-thresh.args
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ==
  --
::
++  read
  |_  =path
    ++  json
      ~
    ++  noun
      ~
    --
--
