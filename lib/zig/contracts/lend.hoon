::  lend.hoon [uqbar-dao]
::
::  WIP
::
::  basic overcollateralized lending bank
::  requires all tokens comport to fungible.hoon token standard
::  relies on being able to generate a list of continuation-calls
::
::  NOTE: you will have to deploy a bank rice at publish-time for this contract
::  because the contract address will hold tokens that bank uses.
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
  +$  bips           @ud  ::  basis points 
  +$  asset          [token=id amount=@ud]
  +$  interest-rate  [=bips tick=@ud]
  ::
  ::  this rice given to borrower to hold
  ::
  +$  loan  
    $:  borrower=id
        principal=asset
        collateral=asset
        =interest-rate  ::  basis points accrued over 1 tick, tick is X blocks
        created-at=@ud  ::  blocknum
        length=@ud      ::  # of blocks in which loan can be paid off w/o losing collateral
        complete=?
    ==
  ::
  ::  this rice generated to form a 'bank' and held by banker(?)
  ::
  +$  bank
    ::  this rice would have to be hardcoded by the account funding this 
    ::  "bank", or updated via transactions, preferably in an automatic
    ::  fashion via some kind of price oracle.
    $:  terms=(map [prin=id col=id] asset-terms)
        accounts=(map id id)  ::  token metadata IDs to location of our account for that token
        managers=(set id)     ::  accounts permitted to modify these terms
        loan-salt=@
    ==
  ::
  +$  asset-terms
    ::  example:
    ::  'zigs' market price $10, 'wigs' market price $1
    ::  required collateralization rate for loan: 150%
    ::  borrower seeking 100 wigs and using zigs as collateral
    ::  collateral-value = 1000% = 100000
    ::  collateralization = 150% = 15000
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
            principal-contract=id        ::  address of token contract
            collateral=asset
            collateral-account=id   ::  token account rice ID
            collateral-contract=id  ::  address of token contract
        ==
    ::
        ::  pay off an existing loan
        ::  desired rice: loan in grains.inp, bank issuing the loan in owns.cart
        $:  %repay
            loan-id=id
            payment=asset
            repay-account=id   ::  token account rice ID
            repay-contract=id  ::  address of token contract
            collateral-account=(unit id)  ::  token account rice ID
            collateral-contract=id        ::  address of token contract
        ==
    ::
        ::  for bank: update loan parameters
        ::  desired rice: the bank in question in owns.cart
        $:  %update-terms
            principal-token=id
            collateral-token=id
            =asset-terms
        ==
    ::
        ::  for bank: make bank aware of ID for a token account it holds
        $:  %add-token-account
            token=id    ::  metadata ID
            account=id  ::  account ID
        ==
    ::
        ::  for bank managers: take tokens out of a contract-held token account
        ::  NOTE: deposits can just be done by sending tokens to contract-held accounts
        $:  %banker-withdraw
            token=id
            token-contract=id
            amount=@ud
            to=id
            to-account=(unit id)
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
      =/  =asset-terms
        (~(got by terms.bank) [token.principal.args token.collateral.args])
      =/  bank-account-principal=id
        (~(got by accounts.bank) token.principal.args)
      =/  bank-account-collateral=id
        (~(got by accounts.bank) token.collateral.args)
      ::  assert that amounts comport to bank's terms for this asset pair
      =/  required-collateral=@ud
        %+  div
          (mul amount.principal.args collateralization.asset-terms)
        collateral-value.asset-terms
      ?>  (gte amount.collateral.args required-collateral)
      ::  issue a new loan rice (borrower is holder, we are lord)
      =/  =loan
        :*  borrower=caller-id
            principal.args
            [token.collateral.args required-collateral]
            interest-rate.asset-terms
            created-at=block.cart
            loan-length.asset-terms
            complete=%.n
        ==
      =+  (fry-rice caller-id me.cart town-id.cart loan-salt.bank)
      =/  loan-grain=grain
        [- me.cart caller-id town-id.cart [%& loan-salt.bank loan]]
      ::  generate %give and %take calls for principal and collateral
      ::  if either of these fail the loan will not be created
      :+  %|  ::  hen
        :~  :+  collateral-contract.args
              town-id.cart
            :^    me.cart
                `[%take me.cart `bank-account-collateral collateral-account.args required-collateral]
              (silt ~[bank-account-collateral])
            (silt ~[collateral-account.args])
        ::
            :+  principal-contract.args
              town-id.cart
            :^    me.cart
                `[%give caller-id principal-account.args amount.principal.args]
              (silt ~[bank-account-principal])
            ?~  principal-account.args  ~
            (silt ~[u.principal-account.args])
        ==
      [~ (malt ~[[id.loan-grain loan-grain]]) ~]
    ::
        %repay
      ::  acquire bank information through owned grain
      =/  [bank-id=id bank-grain=grain]  -.owns.cart
      ?>  &(=(lord.bank-grain me.cart) ?=(%& -.germ.bank-grain))
      =/  =bank  ;;(bank data.p.germ.bank-grain)
      ::  acquire loan information through caller grain
      =/  [loan-id=id loan-grain=grain]  -.grains.inp
      ?>  &(=(lord.loan-grain me.cart) ?=(%& -.germ.loan-grain))
      =/  =loan  ;;(loan data.p.germ.loan-grain)
      ::  get account locations for bank
      =/  bank-account-principal=id
        (~(got by accounts.bank) token.principal.loan)
      =/  bank-account-collateral=id
        (~(got by accounts.bank) token.collateral.loan)
      ::  assert loan has not expired and is paid in correct token
      ?>  ?&  =(complete.loan %.n)
              (lte block.cart (add created-at.loan length.loan))
              =(token.principal.loan token.payment.args)
          ==
      ::  calculate interest and add to principal
      =/  total-owed
        %+  add  amount.principal.loan
        %+  div
          %+  mul  amount.principal.loan
          %+  mul  bips.interest-rate.loan
          (div (sub block.cart created-at.loan) tick.interest-rate.loan)
        10.000
      ::  assert that repayment is enough
      ?>  (gte amount.payment.args total-owed)
      ::  modify loan to mark as complete
      =.  complete.loan  %.y
      ::  generate %give and %take calls for collateral and repayment
      ::  if either of these fail the loan will not be completed
      :+  %|  ::  hen
        :~  :+  repay-contract.args
              town-id.cart
            :^    me.cart
                `[%take me.cart `bank-account-principal repay-account.args total-owed]
              (silt ~[bank-account-principal])
            (silt ~[repay-account.args])
        ::
            :+  collateral-contract.args
              town-id.cart
            :^    me.cart
                `[%give caller-id collateral-account.args amount.collateral.loan]
              (silt ~[bank-account-collateral])
            ?~  collateral-account.args  ~
            (silt ~[u.collateral-account.args])
        ==
      [(malt ~[[id.loan-grain loan-grain(data.p.germ loan)]]) ~ ~]
    ::
        %update-terms
      ::  acquire bank information through owned grain
      =/  [bank-id=id bank-grain=grain]  -.owns.cart
      ?>  &(=(lord.bank-grain me.cart) ?=(%& -.germ.bank-grain))
      =/  =bank  ;;(bank data.p.germ.bank-grain)
      ::  check that caller is a manager
      ?>  (~(has in managers.bank) caller-id)
      ::  insert updated asset pair
      =+  (~(put by terms.bank) [principal-token.args collateral-token.args] asset-terms.args)
      [%& (malt ~[[bank-id bank-grain(data.p.germ bank(terms -))]]) ~ ~]
    ::
        %add-token-account
      ::  acquire bank information through owned grain
      =/  [bank-id=id bank-grain=grain]  -.owns.cart
      ?>  &(=(lord.bank-grain me.cart) ?=(%& -.germ.bank-grain))
      =/  =bank  ;;(bank data.p.germ.bank-grain)
      ::  check that caller is a manager
      ?>  (~(has in managers.bank) caller-id)
      ::  insert token account ID
      =+  (~(put by accounts.bank) token.args account.args)
      [%& (malt ~[[bank-id bank-grain(data.p.germ bank(accounts -))]]) ~ ~]
    ::
        %banker-withdraw
      ::  acquire bank information through owned grain
      =/  [bank-id=id bank-grain=grain]  -.owns.cart
      ?>  &(=(lord.bank-grain me.cart) ?=(%& -.germ.bank-grain))
      =/  =bank  ;;(bank data.p.germ.bank-grain)
      =/  bank-account=id
        (~(got by accounts.bank) token.args)
      ::  check that caller is a manager
      ?>  (~(has in managers.bank) caller-id)
      ::  create call to execute token send
      :+  %|  ::  hen
        :_  ~
        :+  token-contract.args
          town-id.cart
        :^    me.cart
            `[%give to.args to-account.args amount.args]
          (silt ~[bank-account])
        ?~  to-account.args  ~
        (silt ~[u.to-account.args]) 
      ~^~^~
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
