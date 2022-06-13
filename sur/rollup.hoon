::  testnet rollup, Uqbar
::
/+  smart=zig-sys-smart
|%
+$  id       @ux
+$  root     @ux  ::  hash of granary state map
+$  address  @ux  ::  42-char hex address, ETH compatible
+$  sig      [v=@ r=@ s=@]  ::  ETH compatible
+$  land  (map id town)
+$  availability-method
  $%  [%full-publish diffs=(list diff)]
      [%committee members=(map address [ship (unit sig)])]
  ==
::
::  TODO: granary MUST be map-type with deterministic sorting
::
+$  town
  $:  sequencer=address
      =granary:smart    ::  current state map
      =populace:smart   ::  map of address to user
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list root)
  ==
::
+$  diff   granary:smart     ::  state transitions for one batch
+$  batch  (list egg:smart)  ::  txns processed in one state transiton
::
+$  move ::  state transition
  $:  mode=availability-method
      next-root=root
      peer-roots=(map id root)  ::  roots for other towns we interact with
      =sig  ::  sequencer signs hash of next-root/diff data
  ==
--