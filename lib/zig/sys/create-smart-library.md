## How to create a compiled "smart library" for smart contract execution:
*used to generate new versions of uHoon*

`=smart-txt .^(@t %cx /=zig=/lib/zig/sys/smart/hoon)`

`=hoon-txt .^(@t %cx /=zig=/lib/zig/sys/hoon/hoon)`

`=hoe (slap !>(~) (ream hoon-txt))`

`=hoed (slap hoe (ream smart-txt))`

`.smart-lib q:hoed`
