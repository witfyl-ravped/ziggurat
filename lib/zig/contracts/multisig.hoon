::  multisig.hoon  [uqbar-dao]
::
::  Smart contract to manage a simple multisig wallet.
::  New multisigs can be generated through the %create
::  argument, and are stored in account-controlled rice.
::
::  Uncomment the following line to run tests
::/+  *zig-sys-smart
/=  sur  /lib/zig/contracts/sur/multisig
/=  lib  /lib/zig/contracts/lib/multisig
=,  sur
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) caller.inp)
  ::
  ++  process
    |=  [args=action =caller]
    ^-  chick
    =/  caller-id=id  (pin caller.inp)
    ?:  ?=(%create-multisig -.args)
      ::  issue a new multisig rice
      =/  member-count  ~(wyt in members.args)
      ?>  (gth member-count 0)
      ::  invariant: threshold must be <= member-count
      ?>  (lte init-thresh.args member-count)
      ?>  (gth init-thresh.args 0)  :: threshold of 0 is disallowed
      ::  XX currently salt of a multisig is caller-id concat w initial members run thru sham-ids
      ::     should salt be updated every time a new member is added? can salts even change?
      ::  potential solution: include the current block as well, so that salts are unique even when
      ::  the same caller-id creates a multisig w same initial members
      ::  this makes it harder to calculate later potentially? and also brings up
      ::  the question about how determinisitic does a salt really have to be
      ::  and also, in a non-parallel situation, you could just make the salt always just be the block number right?.
      =/  salt=@
        (sham (cat 3 block.cart (cat 3 caller-id (sham-ids:lib members.args))))
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
      ?>  (~(has in members.state) caller-id)
      =*  tx-hash  tx-hash.args
      =/  prop     (~(got by pending.state) tx-hash)
      ?>  !(~(has in votes.prop) caller-id)            :: cannot vote for prop you already voted for
      =.  votes.prop     (~(put in votes.prop) caller-id)
      =.  pending.state  (~(put by pending.state) tx-hash prop)
      ::  if votes are not at threshold, just update state
      ::  otherwise update state and issue tx
      ?:  (lth ~(wyt in votes.prop) threshold.state)
        =.  data.p.germ.my-grain  state
        [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
      =.  pending.state         (~(del by pending.state) tx-hash)
      =.  data.p.germ.my-grain  state
      =/  crow=(list [@tas json])
        :~  (event-to-json:lib [%vote-passed tx-hash votes.prop id.my-grain])
        ==
      =/  roost=rooster  [changed=(malt ~[[id.my-grain my-grain]]) issued=~ crow]
      [%| [next=[to.p.egg town-id.p.egg q.egg]:prop roost]]

    ::
        %submit-tx
      ?>  (~(has in members.state) caller-id)
      ::  N.B: Due to separation of concerns, we do not automatically record
      ::       a vote on caller-id's part. they must send a vote tx as well.
      ::
      ::  TODO we should overwrite [sig eth-hash]:p.egg and caller-id.q.egg
      ::  to always be from this contract (signing it ourselves etc.)
      =.  from.p.egg.args       me.cart
      =/  egg-hash              (sham-egg:lib egg.args caller block.cart)
      =.  pending.state         (~(put by pending.state) egg-hash [egg.args *(set id)])
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
      ::  The following must be sent by the contract itself
      ::
        %add-member
      ?>  =(me.cart caller-id)
      ?>  !(~(has in members.state) id.args)  :: adding an existing member is disallowed
      =.  members.state         (~(put in members.state) id.args)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %remove-member
      =/  member-count  ~(wyt in members.state)
      ?>  =(me.cart caller-id)
      ?>  (~(has in members.state) id.args)
      ?>  (gth member-count 1)              :: multisig cannot have 0 members
      ::  5:5, lose 1, 5:4 -> 4:4
      ::  invariant: threshold must be <= member-count
      =/  new-member-count  (dec member-count)
      =?  threshold.state   (gth new-member-count threshold.state)
        new-member-count
      =.  members.state         (~(del in members.state) id.args)
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %set-threshold
      ?>  =(me.cart caller-id)
      ?>  (lte threshold.state ~(wyt in members.state))  :: cannot set threshold higher than member count
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
