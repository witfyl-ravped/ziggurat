/+  *zig-sys-smart
/=  sur  /lib/zig/contracts/sur/multisig
=,  sur
|%
++  sham-ids
  |=  ids=(set id)
  ^-  @uvH
  =<  q
  %^  spin  ~(tap in ids)
    0v0
  |=  [=id hash=@uvH]
  [~ (sham (cat 3 hash (sham id)))]
++  sham-egg
  |=  [=egg submitter=caller block=@ud]
  ^-  @uvH
  ::  blocknum + town-id + caller-id + nonce (if avail)
  =/  part-a  (cat 3 (sham block) (sham town-id.p.egg))
  =/  part-b
    ?^  submitter
      (cat 3 (sham id.submitter) (sham nonce.submitter))
    (sham submitter)
  (cat 3 part-a part-b)
++  event-to-json
  |=  [=event]
  ^-  [@tas json]
  ::  TODO implement
  =/  tag  -.event
  =/  jon  *json
    ::%-  pairs:enjs:format
    :::~  s+'eventName'  s+[`@t`tag]
    ::==
  [tag jon]
--