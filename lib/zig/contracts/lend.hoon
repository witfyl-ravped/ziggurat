::  lend.hoon [uqbar-dao]
::
::  WIP
::
::  basic overcollateralized lending bank
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
  +$  asset          [token=id amount=@ud]
  +$  interest-rate  [bp=@ud tick=@ud]
  ::
  +$  loan
    $:  borrower=id
        principal=asset
        collateral=asset
        =interest-rate    ::  basis points accrued over 1 tick, tick is X blocks
        length=@ud        ::  number of blocks in which loan can be paid without losing principal
    ==
  ::
  +$  terms-of-service
    ::  this rice would have to be hardcoded by the account funding this 
    ::  "bank", or updated via transactions, preferably in an automatic
    ::  fashion via some kind of price oracle.
    $:  asset-pairs=(set asset-pair)
        managers=(set id)  ::  accounts permitted to modify these terms
        loan-length=@ud
    ==
  ::
  +$  asset-pair
    ::  example:
    ::  'zigs' market price $10, 'wigs' market price $1
    ::  required collateralization rate for loan: 150%
    ::  borrower seeking 100 wigs and using zigs as collateral
    ::  collateral-value = 1000%
    ::  collateralization = 150%
    ::  (principal amount / (collateral-value / 100)) * (collateralization / 100) = collateral amount = 15
    ::
    ::  NOTE: collateralization should cover max interest that can be accrued over lifetime of loan...
    ::        bankers should be smart and calculate this well...
    $:  principal=id
        collateral=id
        collateral-value=@ud   ::  represents % ratio between collateral value and principal value
        collateralization=@ud  ::  represents required percentage of collateral value vs principal
        =interest-rate
    ==
  ::
  +$  arguments
    $%  ::  take out a new loan
        $:  %borrow
            desired-principal=asset
            collateral=asset
            collateral-account=id  ::  token account rice ID
            principal-receiver=id  ::  token account rice ID
        ==
    ::
        ::  pay off an existing loan
        $:  %repay
            loan-id=id
            sum=asset
            repayment-account=id    ::  token account rice ID
            collateral-receiver=id  ::  token account rice ID
        ==
    ::
        ::  for bank 
        $:  %update-terms
            =asset-pair
            maximum-loan-length=(unit @ud)
        ==
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %borrow
      ::  pass in terms-of-service rice through owns.cart
      ::  assert that principal and collateral comport to an asset-pair
      ::  assert that value ratio and collateralization is valid
      ::  trigger TWO continuation calls: one to %take tokens from collateral-account,
      ::  (borrower MUST have previously created an allowance in their collateral token account
      ::  >= amount in loan, otherwise, %take will fail and entire %borrow will fail)
      ::  other to %give tokens from our account for principal token to borrower
      ::  TODO: update hen to allow for this!!
      ::  finally, issue a new loan rice (borrower is holder, we are lord)
      !!
    ::
        %repay
      ::  pass in terms-of-service rice through owns.cart
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
      ::  pass in terms-of-service rice through owns.cart
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
