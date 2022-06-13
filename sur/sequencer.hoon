/+  smart=zig-sys-smart
|%
+$  basket     (set egg:smart)  ::  transaction "mempool"
+$  sequencer  (pair address:smart ship)
::
+$  availability-method
  $%  [%full-publish diffs=(list diff) hash=@ux]
      [%committee members=(map address:smart [ship (unit sig:smart)])]
  ==
::
::  TODO: granary MUST be map-type with deterministic sorting
::
+$  root   @ux  ::  hash of granary state map

+$  town   [=land =hall]
+$  land   (pair granary:smart populace:smart)
+$  hall
  $:  =id:smart
      =sequencer
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list root)
  ==
::
+$  diff   granary:smart                 ::  state transitions for one batch
+$  batch  (pair (list egg:smart) diff)  ::  txns processed in one state transiton
::
+$  move  ::  state transition
  $:  town-id=id:smart
      mode=availability-method  ::  diffs included here
      new-root=root
      new-state=land
      peer-roots=(map id:smart root)  ::  roots for all other towns (must be up-to-date)
      =sig:smart                      ::  sequencer signs new state root
  ==
::
+$  town-action
  $%  ::  administration
      $:  %init
          rollup-host=ship
          town-id=id:smart
          =address:smart
          starting-state=(unit land)
          mode=availability-method
      ==
      [%clear-state ~]
      ::  transactions
      [%receive eggs=(set egg:smart)]
      ::  batching
      [%trigger-batch ~]
  ==
--