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
+$  granary   (map id:smart grain:smart)
+$  populace  (map id:smart @ud)
+$  land      (pair granary populace)
+$  town      [=land =hall]
::
+$  hall
  $:  =id:smart
      =sequencer
      mode=availability-method
      latest-diff-hash=@ux
      roots=(list @ux)
  ==
::  capitol: tracks sequencer and state roots / diffs for all towns
+$  capitol  (map id:smart hall:sequencer)
::
+$  diff   granary  ::  state transitions for one batch
+$  batch  ::  state transition
  $:  town-id=id:smart
      mode=availability-method
      state-diffs=(list diff)
      diff-hash=@ux
      new-root=@ux
      new-state=land
      peer-roots=(map id:smart @ux)  ::  roots for all other towns (must be up-to-date)
      =sig:smart                     ::  sequencer signs new state root
  ==
::
+$  town-action
  $%  ::  administration
      $:  %init
          rollup-host=ship
          =address:smart
          private-key=@ux
          town-id=id:smart
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
      [%new-capitol capitol]
      [%new-sequencer town=id:smart who=ship]
  ==
::
+$  indexer-update
  $%  [%new-state =town]
  ==
--
