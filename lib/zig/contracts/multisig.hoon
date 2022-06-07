::  multisig.hoon  [uqbar-dao]
::
::  Smart contract to manage a simple multisig wallet.
::  New multisigs can be generated through the %create
::  argument, and are stored in account-controlled rice.
::
::  Uncomment the following line to run tests
::/+  *zig-sys-smart
!:
^-  contract  :: not strictly necessary but works well
::
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) (pin caller.inp))
  ::
  ::  XX potentially add [%remove-tx tx-hash=@ux] if it makes sense?
  ::  XX potentially add expired txs?
  +$  tx-hash   @ux
  +$  proposal  [=egg votes=(set id)]
  +$  multisig-state
    $:  members=(set id)
        threshold=@ud
        pending=(map tx-hash proposal)
    ::  submitted=(set tx-hash) could add this if it makes sense. could let off chain index this and save on chain space
    ==
  ::
  ::::  XX could use the following in proposal instead of egg
  ::+$  partial-egg  (pair partial-shell partial-yolk)
  ::+$  partial-shell
  ::  $:  to=id
  ::      town-id=@ud
  ::  ==    
  ::+$  partial-yolk 
  ::  $:  args=(unit *)
  ::      my-grains=(set id)
  ::      cont-grains=(set id)
  ::  ==
  ::::
  +$  action
    $%
      ::  any id can call the following, and requires no grains
      ::
      [%create-multisig init-thresh=@ud members=(set id)]
      ::  All of the following expect the grain of the deployed multisig
      ::  to be the first and only argument to `cont-grains`
      :: 
      ::::  the following can be called by anyone in `members`
        ::
      [%vote =tx-hash]
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
      ::  we need multisig=id for each event to disambiguate between each multisig that exists
      [%new-vote =tx-hash voter=id multisig=id]
      [%new-tx =tx-hash multisig=id]
      [%vote-passed =tx-hash votes=(set id) multisig=id]
      [%threshold-changed threshold=@ud multisig=id]
      [%member-added new-member=id multisig=id]
      [%member-removed removed=id multisig=id]
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
    =/  jon  *json
      ::%-  pairs:enjs:format
      :::~  s+'eventName'  s+[`@t`tag]
      ::==
    [tag jon]
  ::
  ++  process
    |=  [args=action caller-id=id]
    ^-  chick
    ?:  ?=(%create-multisig -.args)
      ::  issue a new multisig rice
      =/  member-count  ~(wyt in members.args)
      ?>  (gth member-count 0)
      ::  invariant: threshold must be <= member-count
      ?>  (lte init-thresh.args member-count)
      ?>  (gth init-thresh.args 0)  :: threshold of 0 is disallowed
      =/  salt=@             (sham (cat 3 caller-id (shamspin members.args)))
      =/  lord               me.cart  
      =/  holder             me.cart  ::  TODO should holder be me.cart or caller-id
      =/  new-sig-germ=germ  [%& salt [members.args init-thresh.args ~]]
      =/  new-sig-id=id      (fry-rice holder lord town-id.cart salt)
      =/  new-sig=grain      [new-sig-id lord holder town-id.cart new-sig-germ]
      [%& changed=~ issued=(malt ~[[new-sig-id new-sig]]) crow=~]
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
      ?>  (is-member caller-id state)
      =*  tx-hash  tx-hash.args
      =/  prop     (~(got by pending.state) tx-hash)
      ?>  !(~(has in votes.prop) caller-id)            :: cannot vote for prop you already voted for
      =.  votes.prop     (~(put in votes.prop) caller-id)
      =.  pending.state  (~(put by pending.state) tx-hash prop)
      ::  if proposal is not at threshold, just update state
      ::  otherwise update state and issue tx
      ?:  (lth threshold.state ~(wyt in votes.prop))
        =.  data.p.germ.my-grain  state
        [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
      =.  pending.state         (~(del by pending.state) tx-hash)
      =.  data.p.germ.my-grain  state
      =/  crow=(list [@tas json])
        :~  (event-to-json [%vote-passed tx-hash votes.prop id.my-grain])
        ==
      =/  roost=rooster  [changed=(malt ~[[id.my-grain my-grain]]) issued=~ crow]
      [%| [next=[to.p.egg town-id.p.egg q.egg]:prop roost]]

    ::
        %submit-tx
      ?>  (is-member caller-id state)
      ::  XX mug is non-cryptographic, so if a new tx hashes to the same as an
      ::  old one, it will be erroneously overwritten and have a vote added
      ::  but sham etc. calls jam which is expensive. what do?
      ::
      ::  N.B: Due to separation of concerns, we do not automatically record
      ::       a vote on caller-id's part. they must send a vote tx as well.
      =.  pending.state         (~(put by pending.state) (mug egg.args) [egg.args *(set id)])
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
      ::  The following must be sent by the contract itself
      ::
        %add-member
      ?>  (is-me caller-id)
      ?>  (~(has in members.state) id.args)  :: adding an existing member is disallowed
      =.  members.state         (~(put in members.state) id.args)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %remove-member
      =/  member-count  ~(wyt in members.state)
      ?>  (is-me caller-id)
      ?>  (~(has in members.state) id.args)
      ?>  (gth member-count 1)              :: multisig cannot have 0 members
      ::  5:5, lose 1, 5:4 -> 4:4
      ::  invariant: threshold must be <= member-count
      =/  new-member-count  (dec member-count)
      =?  threshold.state   (gth new-member-count threshold.state)
        new-member-count
      =.  members.state         (~(del in members.state) id)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %set-threshold
      ?>  (is-me caller-id)
      ?>  (gth threshold.state ~(wyt in members.state))  :: cannot set threshold higher than member count
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
