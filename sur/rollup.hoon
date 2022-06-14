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
      [%receive-move from=address:smart move:sequencer]
  ==
--