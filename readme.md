# Development Instructions

1. Start by cloning the urbit/urbit repository from github.
`git clone git@github.com:urbit/urbit.git`

2. Then, change directory to urbit/pkg.
`cd urbit/pkg`

3. Then, add this repository as a submodule. This is necessary to resolve symbolic
links to other desks, such as base-dev and garden-dev.
`git submodule add git@github.com:uqbar-dao/ziggurat.git ziggurat`

4. To boot your development Urbit, run the following command:
`urbit -F zod`

5. To create a `%zig` desk, run
`|merge %zig our %base`

6. To mount the `%zig` desk to the filesystem, run
`|mount %zig`.

7. Next, remove all the files from the zig directory.
`rm -rf zod/zig/*`

8. Now, copy all the files from our ziggurat repository into the `%zig` desk.
`cp -RL urbit/pkg/ziggurat/* zod/zig/`

9. Commit those files into your Urbit.
`|commit %zig`

10. Now, install the desk in your Urbit, which will run the agents.
`|install our %zig`

### To initialize a blockchain:

*Note: make sure the ship you're is in the [whitelist](https://github.com/uqbar-dao/ziggurat/blob/e07ac60c29d94188f7594992b0fac347071a5c85/lib/zig/util.hoon#L14)*

1. Start by populating the wallet with the correct data (need to do this first, but with block explorer we can make wallet find this itself):
```
:wallet &zig-wallet-poke [%populate 0xbeef]
```
*for testing: use `0xbeef` for ~zod, `0xdead` for next ship, `0xcafe` for 3rd*

2. Give your validator agent a pubkey to match the data in the wallet:
```
:ziggurat &zig-chain-poke [%set-addr 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423]

0xbeef  0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423
0xdead  0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d
0xcafe  0x2.4a1c.4643.b429.dc12.6f3b.03f3.f519.aebb.5439.08d3.e0bf.8fc3.cb52.b92c.9802.636e
```
*This is one of 3 addresses with zigs already added, and corresponds to the seed `0xbeef`. to test with more, find matching pubkey in wallet*

3. To start the indexer/block explorer backend, use:
```
:indexer &set-chain-source [our %ziggurat]
```
where the argument `[our %ziggurat]` is a dock pointing to the ship running the `%ziggurat` agent to receive block updates from.

4. Start up a new main chain:
```
:ziggurat|start-testnet now
```
(to add other ships, follow above instructions with 2nd and 3rd seed/pubkey combos, but use poke `:ziggurat &zig-chain-poke [%start %validator ~ validators=(silt ~[~zod]) [~ ~]]`) here, where `~[~zod]` is some set of ships validating (you only need one that's not you)

6. Start up a town that has the token contract deployed. Wait until the wallet sees an update from the indexer to do this.
```
:sequencer|init 1
```
(1 here is the town-id)

# To use the wallet

1. Scry for a JSON dict of accounts, keyed by address, containing private key, nickname, and nonces:
`.^(json %gx /=wallet=/accounts/noun)`

2. Scry for a JSON dict of known assets (rice), keyed by address, then by rice address:
`.^(json %gx /=wallet=/book/json)`

3. Scry for JSON dict of token metadata we're aware of:
`.^(json %gx /=wallet=/token-metadata/json)`

4. Scry for seed phrase and password (todo separate these):
`.^(json %gx /=wallet=/seed/json)`


### Wallet pokes available:
(only those with JSON support shown)

```
{import-seed: {mnemonic: "12-24 word phrase", password: "password", nick: "nickname for the first address in this wallet"}}
{generate-hot-wallet: {password: "password", nick: "nickname"}}
# leave hdpath empty ("") to let wallet auto-increment from 0 on main path
{derive-new-address: {hdpath: "m/44'/60'/0'/0/0", nick: "nickname"}}
# use this to save a hardware wallet account
{add-tracked-address: {address: "0x1234.5678" nick: "nickname"}}
{delete-address: {address: "0x1234.5678"}}
{edit-nickname: {address: "0x1234.5678", nick: "nickname"}}
{set-node: {town: 1, ship: "~zod"}}  # set the sequencer to send txs to, per town
{set-indexer: {ship: "~zod"}}
{submit-custom: {from: "0x1234", to: "0x5678", town: 1, gas: {rate: 1, bud: 10000}, args: "[%give ... .. (this is HOON)]", my-grains: {"0x1111", "0x2222"}, cont-grains: {"0x3333", "0x4444"}}}
# for TOKEN and NFT transactions
# 'from' is our address
# 'to' is the address of the smart contract
# 'town' is the number ID of the town on which the contract&rice are deployed
# 'gas' rate and bud are amounts of zigs to spend on tx
# 'args' will eventually cover many types of transactions,
# currently only concerned with token sends following this format,
# where 'token' is address of token metadata rice, 'to' is address receiving tokens.
{submit:
  {from: "0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423",
   to: "0x74.6361.7274.6e6f.632d.7367.697a",
   town: 1,
   gas: {rate: 1, bud: 10000},
   args: {give: {salt: "1.936.157.050", to: "0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d", amount: 777}}
   }
}
```
(example pokes that will work upon chain initialization in dojo):
```
#  ZIGS
:wallet &zig-wallet-poke [%submit 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423 0x74.6361.7274.6e6f.632d.7367.697a 1 [1 10.000] [%give 1.936.157.050 0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d 777]]

#  NFT
:wallet &zig-wallet-poke [%submit 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423 0xcafe.babe 1 [1 10.000] [%give 32.770.263.103.071.854 0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d 1]]
```


### Build DAO contracts

If run on a fakezod located at `~/urbit/zod`, the following will create the compiled DAO contract at `~/urbit/zod/.urb/put/dao.noun`:`
```
=hoon .^(@t %cx /(scot %p our)/zig/(scot %da now)/lib/zig/sys/hoon/hoon)
=smart .^(@t %cx /(scot %p our)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
=contract .^(@t %cx /(scot %p our)/zig/(scot %da now)/lib/zig/contracts/dao/hoon)
=step0 (slap !>(~) (ream hoon))
=step1 (slap step0 (ream smart))
=step2 (slap step1 (ream contract))
.dao/noun q:(slap step2 (ream '-'))
```

### DAO set up

1. Start the chain and the indexer (i.e. see "To initialize a blockchain" section above).

2. Tell the DAO agent to watch our indexer:
```
:dao &set-indexer [our %indexer]
```

3. Set up subscription of off-chain DAO agent to on-chain DAO (which is created in `gen/sequencer/init-dao.hoon`):
```
::  arguments are rid, which is analogous to a landscape group, salt, which is unique to each DAO, and DAO name
-zig!create-dao-comms [[~zod %uqbar-dao] `@`'uqbar-dao' 'Uqbar DAO']
```

### Changing DAO state

To change the DAO state, a transaction must be sent to the chain.
The helper thread `ted/send-dao-action.hoon` builds transactions.
For example, from a ship that is a DAO owner (and additionally currently limited to `~zod` as of 220502), the following will submit transactions to create two proposals and then add a vote to each.
If the threshold is surpassed by the vote, the proposals will pass.
```
::  account ids
=pubkey 0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b
=zigs-id 0x10b.4ca5.fb93.480b.a0d7.c168.0f3e.6d43
=dao-id 0xef44.5e1e.2113.c21d.7560.c831.6056.d984

::  prepare on-chain-update objects for proposals
=add-perm-host-update [%add-permissions dao-id %host [our %uqbar-dao] (~(put in *(set @tas)) %comms-host)]
=add-role-host-update [%add-roles dao-id (~(put in *(set @tas)) %comms-host) pubkey]

::  proposals and votes
-zig!send-dao-action [our [pubkey 1 zigs-id] [%propose dao-id add-perm-host-update]]
-zig!send-dao-action [our [pubkey 2 zigs-id] [%propose dao-id add-role-host-update]]
-zig!send-dao-action [our [pubkey 3 zigs-id] [%vote dao-id 0x54c2.59a7]]
-zig!send-dao-action [our [pubkey 4 zigs-id] [%vote dao-id 0x44f5.977d]]
```

## Indexer

The indexer exposes a variety of scry and subscription paths.
A few are discussed below with examples.
Please see the docstring at the top of `app/indexer.hoon` for a fuller set of available paths.

### Indexer scries

Four example scries will be shown below for a user scrying from the Dojo; externally using the Curl commandline tool; and using the Urbit HTTP API.

For simplicity, the following is assumed:

I. The `%indexer` app is running on the `%zig` desk on a fakezod.
II. The fakezod is running at `localhost:8080`.

Examples:

1. The most recent 5 block headers.

```
::  inside Urbit
=z -build-file /=zig=/sur/ziggurat/hoon
.^((list [epoch-num=@ud =block-header:z]) %gx /=indexer=/headers/5/noun)

# using Curl
curl -i -X POST localhost:8080/~/login -d 'password=lidlut-tabwed-pillex-ridrup'
# record cookie from above and use below
curl --cookie "urbauth-~zod=$ZOD_COOKIE" localhost:8080/~/scry/indexer/headers/5.json

# using HTTP API
await api.scry({app: "indexer", path: "/headers/5"});
```

2. All data in a chunk with epoch number, block number, and chunk/town number as `1`, `2`, and `3`, respectively (these should, of course, be substituted for variables appropriate).

```
::  inside Urbit
::  TODO

# using Curl
# TODO

# using HTTP API
await api.scry({app: "indexer", path: "/chunk-num/1/2/3"});
```

3. A given transaction with hash `0xdead.beef` (this should, of course, be substituted for a variable as appropriate).

```
::  inside Urbit
::  TODO

# using Curl
# TODO

# using HTTP API
await api.scry({app: "indexer", path: "/egg/0xdead.beef"});
```

4. All transactions for a given address with hash `0xcafe.babe` (this should, of course, be substituted for a variable as appropriate) (TODO: add start/end times to retrieve subset of transactions).

```
::  inside Urbit
::  TODO

# using Curl
# TODO

# using HTTP API
await api.scry({app: "indexer", path: "/from/0xcafe.babe"});
```

### Indexer subscriptions

One example subscription will be discussed: subscribing to receive each new block (or "slot") that is processed by the indexer. (TODO)
Please see the docstring at the top of `app/indexer.hoon` for a fuller set of available paths.

For the HTTP API, the app to subscribe to is `"indexer"`, and the path is `"/slot"`.

# Testing Zink

```
=z -build-file /=zig=/lib/zink/zink/hoon
=r (~(eval-hoon zink:z ~) /=zig=/lib/zink/stdlib/hoon /=zig=/lib/zink/test/hoon %test '3')
-.r     # product
+<.r    # json hints
+>.r    # pedersen hash cache
# once you've run this once so you have a cache you should pass it in every time
# You can pass ~ for library if you don't have one
> =r (~(eval-hoon zink:z +>.r) ~ /=zig=/lib/zink/fib/hoon %fib '5')
# +<.r is the hint json. You need to write it out to disk so you can pass it to cairo.
@fib-5/json +<.r
# Now fib-5.json is in PIER/.urb/put and you can pass it to cairo.
# hash-noun will give you just a hash
> =r (~(hash-noun zink:z +>.r) [1 2 3])
```
