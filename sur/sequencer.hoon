/+  smart=zig-sys-smart
|%
+$  basket     (set egg:smart)  ::  transaction "mempool"
+$  sequencer  (pair address:smart ship)
::
+$  availability-method
  $%  [%full-publish ~]
      [%committee members=(map address:smart [ship (unit sig:smart)])]
  ==
::
::  TODO: granary MUST be map-type with deterministic sorting
::
::  need new name for this:
::  +$  root   @ux  ::  hash of land

+$  town   [=land =hall]
+$  land   (pair granary:smart populace:smart)
+$  hall
  $:  =id:smart
      =sequencer
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list @ux)
  ==
::
+$  diff   granary:smart                 ::  state transitions for one batch
+$  batch  (pair (list egg:smart) diff)  ::  txns processed in one state transiton
::
+$  move  ::  state transition
  $:  town-id=id:smart
      mode=availability-method
      state-diffs=(list diff)
      diff-hash=@ux
      new-root=@ux
      new-state=land
      peer-roots=(map id:smart @ux)  ::  roots for all other towns (must be up-to-date)
      =sig:smart                      ::  sequencer signs new state root
  ==
::
+$  town-action
  $%  ::  administration
      $:  %init
          rollup-host=ship
          private-key=@ux
          town-id=id:smart
          =address:smart
          starting-state=(unit land)
          mode=availability-method
      ==
      [%clear-state ~]
      ::  transactions
      [%receive-assets assets=(map id:smart grain:smart)]
      [%receive eggs=(set egg:smart)]
      ::  batching
      [%trigger-batch ~]
  ==
::
+$  rollup-update
  $%  [%new-peer-root town=id:smart root=@ux]
      [%new-sequencer town=id:smart who=ship]
  ==
--