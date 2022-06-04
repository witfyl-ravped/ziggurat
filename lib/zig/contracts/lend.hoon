::  lend.hoon [uqbar-dao]
::
::  WIP
::
::  basic overcollateralized lending bank
::  requires all tokens comport to fungible.hoon token standard
::  relies on being able to generate a list of continuation-calls
::
/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(arguments u.args.inp) (pin caller.inp))
  ::
  ::  asset IDs here refer to token IDs, which are the location of the metadata grain for that token.
  ::
  +$  bips           @ud  ::  basis points: 
  +$  asset          [token=id amount=@ud]
  +$  interest-rate  [=bips tick=@ud]
  ::
  ::  this rice given to borrower to hold
  +$  loan  
    $:  borrower=id
        principal=asset
        collateral=asset
        =interest-rate    ::  basis points accrued over 1 tick, tick is X blocks
        length=@ud        ::  number of blocks in which loan can be paid without losing principal
    ==
  ::
  ::  this rice generated to form a 'bank' and held by banker(?)
  +$  bank
    ::  this rice would have to be hardcoded by the account funding this 
    ::  "bank", or updated via transactions, preferably in an automatic
    ::  fashion via some kind of price oracle.
    $:  terms=(map [prin=id col=id] asset-pair)
        token-accounts=(map id id)  ::  token metadata IDs to location of our account for that token
        managers=(set id)  ::  accounts permitted to modify these terms
        loan-salt=@
    ==
  ::
  +$  asset-pair
    ::  example:
    ::  'zigs' market price $10, 'wigs' market price $1
    ::  required collateralization rate for loan: 150%
    ::  borrower seeking 100 wigs and using zigs as collateral
    ::  collateral-value = 100000 = 1000%
    ::  collateralization = 15000 = 150%
    ::  (principal * collateralization) / collateral-value = collateral amount = 15
    ::
    ::  NOTE: collateralization should cover max interest that can be accrued over lifetime of loan...
    ::        bankers should be smart and calculate this well...
    $:  collateral-value=bips   ::  represents % ratio between collateral value and principal value
        collateralization=bips  ::  represents required percentage of collateral value vs principal
        =interest-rate
        loan-length=@ud         ::  number of blocks
    ==
  ::
  +$  arguments
    $%  ::  take out a new loan
        ::  desired rice: the bank issuing the loan in owns.cart
        $:  %borrow
            principal=asset
            principal-account=(unit id)  ::  token account rice ID
            principal-contract=id         ::  address of token contract
            collateral=asset
            collateral-account=id   ::  token account rice ID
            collateral-contract=id  ::  address of token contract
        ==
    ::
        ::  pay off an existing loan
        ::  desired rice: the bank issuing the loan in owns.cart
        $:  %repay
            loan-id=id
            sum=asset
            repayment-account=id   ::  token account rice ID
            repayment-contract=id  ::  address of token contract
            collateral-account=(unit id)  ::  token account rice ID
            collateral-contract=id         ::  address of token contract
        ==
    ::
        ::  for bank
        ::  desired rice: the bank in question in owns.cart
        $:  %update-terms
            =asset-pair
        ==
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %borrow
      ::  acquire bank information through owned grain
      =/  [bank-id=id bank-grain=grain]  -.owns.cart
      ?>  &(=(lord.bank-grain me.cart) ?=(%& -.germ.bank-grain))
      =/  =bank  ;;(bank data.p.germ.bank-grain)
      ::  get desired asset pair, fail if not offered by this bank
      =/  =asset-pair
        (~(got by terms.bank) [token.principal.args token.collateral.args])
      =/  bank-account=id
        (~(got by token-accounts.bank) token.principal.args)
      ::  assert that amounts comport to bank's terms for this asset pair
      =/  required-collateral=@ud
        %+  div
          (mul amount.principal.args collateralization.asset-pair)
        collateral-value.asset-pair
      ?>  (gte amount.collateral.args required-collateral)
      ::  issue a new loan rice (borrower is holder, we are lord)
      =/  =loan
        :*  borrower=caller-id
            principal=principal.args
            collateral=[token.collateral.args required-collateral]
            interest-rate=interest-rate.asset-pair
            length=loan-length.asset-pair
        ==
      =+  (fry-rice caller-id me.cart town-id.cart loan-salt.bank)
      =/  loan-grain=grain
        [- me.cart caller-id town-id.cart [%& loan-salt.bank loan]]
      ::  generate %give and %take calls for principal and collateral
      ::  if either of these fail the loan will not be created
      ^-  chick
      :+  %|  ::  hen
        :~  :+  collateral-contract.args
              town-id.cart
            :^    me.cart
                `[%take me.cart `bank-account collateral-account.args required-collateral]
              (silt ~[bank-account])
            (silt ~[collateral-account.args])
        ::
            :+  principal-contract.args
              town-id.cart
            :^    me.cart
                `[%give caller-id principal-account.args amount.principal.args]
              (silt ~[bank-account])
            ?~  principal-account.args  ~
            (silt ~[u.principal-account.args])
        ==
      [~ (malt ~[[id.loan-grain loan-grain]]) ~]
    ::
        %repay
      ::  pass in bank rice through owns.cart
      ::  pass in loan rice through grains.inp
      ::  if loan is expired, reject >:)
      ::  calculate interest based on blocknum, add to principal
      ::  assert that sum is equal to or greater than this
      ::  trigger TWO continuation calls: %take this many tokens from repayment-account,
      ::  (borrower MUST have previously created an allowance in this token account
      ::  >= amount owed, otherwise, %take will fail and entire %borrow will fail)
      ::  and %give tokens from initial collateral to collateral-receiver
      ::  then invalidate loan rice, or delete..?
      ::  TODO: create way to DELETE a grain?!
      !!
    ::
        %update-terms
      ::  pass in bank rice through owns.cart
      ::  sender must be a manager
      ::  put new asset-pair in set
      ::  update max-loan-length
      ::  will only impact future loans, existing ones are set
      !!
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
