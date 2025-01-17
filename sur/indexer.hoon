/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  query-type
  $?  %block-hash
      %chunk
      %egg
      %from
      %grain
      %holder
      %lord
      %slot
      %to
      %hash
  ==
::
+$  query-payload
  ?(@ux location)
::
+$  location
  $?  second-order-location
      block-location
      town-location
      egg-location
  ==
+$  second-order-location  id:smart
+$  block-location
  [epoch-num=@ud block-num=@ud]
+$  town-location
  [epoch-num=@ud block-num=@ud town-id=@ud]
+$  egg-location
  [epoch-num=@ud block-num=@ud town-id=@ud egg-num=@ud]
::
+$  update
  $@  ~
  $%  [%chunk timestamp=@da location=town-location =chunk:zig]
      [%egg eggs=(map egg-id=id:smart [timestamp=@da location=egg-location =egg:smart])]
      [%grain grains=(map grain-id=id:smart [timestamp=@da location=town-location =grain:smart])]
      $:  %hash
          eggs=(map egg-id=id:smart [timestamp=@da location=egg-location =egg:smart])
          grains=(map grain-id=id:smart [timestamp=@da location=town-location =grain:smart])
          slots=(map slot-id=id:smart [timestamp=@da location=block-location =slot:zig])
      ==
      [%slot slots=(map slot-id=id:smart [timestamp=@da location=block-location =slot:zig])]
  ==
--
