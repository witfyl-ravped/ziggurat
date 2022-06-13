/+  *zig-sys-smart
|%
+$  basket     (set egg)  ::  transaction "mempool"
+$  sequencer  (pair address ship)
::
+$  availability-method
  $%  [%full-publish diffs=(list diff)]
      [%committee members=(map address [ship (unit sig)])]
  ==
::
::  TODO: granary MUST be map-type with deterministic sorting
::
+$  root   @ux  ::  hash of granary state map
+$  state  (pair granary populace)
+$  town
  $:  =id
      =sequencer
      =state  ::  current state map + map of address to user
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list root)
  ==
::
+$  diff   granary                 ::  state transitions for one batch
+$  batch  (pair (list egg) diff)  ::  txns processed in one state transiton
::
+$  move  ::  state transition
  $:  mode=availability-method  ::  diffs included here
      new-root=root
      new-state=state
      peer-roots=(map id root)  ::  roots for all other towns (must be up-to-date)
      =sig                      ::  sequencer signs hash of next-root/diff data
  ==
::
+$  town-action
  $%  ::  administration
      $:  %init
          town-id=id
          =address
          starting-state=(unit state)
          mode=availability-method
      ==
      [%clear-state ~]
      ::  transactions
      [%receive eggs=(set egg)]
      ::  batching
      [%trigger-batch ~]
  ==
--