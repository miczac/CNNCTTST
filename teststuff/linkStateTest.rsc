:global lastState true
:global RUNLST 1
:log info "launching linkstate script - $RUNLST"
:while ($RUNLST=1) do={
  :local currentState [/interface ethernet get [find name="ether1 [WAN]"] running]
  :if ($currentState != $lastState) do={
    :if ($currentState) do={
      /log info "-- ether1 is UP"
    } else={
      /log warning "-- ether1 is DOWN"
    }
    :set lastState $currentState
  }
  :delay 1
}
:log info "exiting linkstate script - $RUNLST"
