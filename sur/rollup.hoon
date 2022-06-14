::  testnet rollup, Uqbar
::
::  rollup app: run on ONE ship, receive moves from sequencer apps.
::
/-  sequencer
/+  smart=zig-sys-smart
|%
::  capitol: tracks sequencer and state roots / diffs for all towns
+$  capitol  (map id:smart hall:sequencer)
::
+$  action
  $%  [%activate ~]
      [%launch-town town:sequencer]
      [%bridge-assets town=id:smart assets=(map id:smart grain:smart)]
      [%receive-move from=address:smart move:sequencer]
  ==
--