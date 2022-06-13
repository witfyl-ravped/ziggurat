::  testnet rollup, Uqbar
::
::  rollup app: run on ONE ship, receive moves from sequencer apps.
::
/+  smart=zig-sys-smart
|%
+$  id         @ux
+$  root       @ux  ::  hash of granary state map
+$  address    @ux  ::  42-char hex address, ETH compatible
+$  sig        [v=@ r=@ s=@]  ::  ETH compatible
+$  sequencer  (pair address ship)
+$  land       (map id town)
::
+$  availability-method
  $%  [%full-publish diffs=(list diff)]
      [%committee members=(map address [ship (unit sig)])]
  ==
::
::  TODO: granary MUST be map-type with deterministic sorting
::
+$  state  (pair granary:smart =populace:smart)
+$  town
  $:  =id
      =sequencer
      =state  ::  current state map, map of address to user
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list root)
  ==
::
+$  diff   granary:smart                 ::  state transitions for one batch
+$  batch  (pair (list egg:smart) diff)  ::  txns processed in one state transiton
::
+$  move ::  state transition
  $:  mode=availability-method  ::  diffs included here
      new-root=root
      new-state=state
      peer-roots=(map id root)  ::  roots for other towns we interact with
      =sig  ::  sequencer signs hash of next-root/diff data
  ==
--