## How to create a compiled "smart library" for smart contract execution:
*used to generate new versions of uHoon*

This saves a `vase` of the uHoon subject in the filesystem. We can then import it as a noun and quickly use it to compile contracts and build the subject required to run a contract stored on-chain.

`=smart-txt .^(@t %cx /=zig=/lib/zig/sys/smart/hoon)`

`=hoon-txt .^(@t %cx /=zig=/lib/zig/sys/hoon/hoon)`

`.smart-lib (slap (slap !>(~) (ream hoon-txt)) (ream smart-txt))`
