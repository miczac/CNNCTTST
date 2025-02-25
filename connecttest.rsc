# tests a layer 3 network connection via ping to a designated IP address
# version 1.0	20250225.2/mz
# add to Scheduler with something like: /system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3

# future changes:
# add: check if next hop (router or modem) is online, e.g. via pinging its LAN interface
# add: fallback destination IP adress(es) if next hop is offline
# add: encode part of the log msg to provide more clean find/filter results in log  ( :put [:convert from=hex "574c414e2d4f7574616765" to=raw] )
easier:  :put "\32"   *facepalm @ Copilot!*
# add: include destination IP in log msgs
# change: "WAN" to "Connection" or so .. make it rather universally usable 
# change: write only one line to log if only one packet dropped
# consider: minimum packet loss before writing to log at all
# consider: writing log msgs to separate log (file?)
# note: something like this surely exists somewhere already, doesn't it? (if so, consider this an exercise!)

:global isOutage
:global outageStart
:global lostPackets
:local DestIP 83.216.32.162 ; # change to your needs! 

:local pingResult [/ping $DestIP count=1];
#:log info "Ping result: $pingResult"
#:log info "Current isOutage value before checking: $isOutage"

:if ($pingResult = 0) do={  
    #:log info "Ping failed"
    #:log info "isOutage value before inner check: $isOutage"
    :if (!$isOutage) do={         # an unset boolean returns 'false'!
        #:log info "Connection outage detected!"
        :set isOutage true
        :set outageStart [/system clock get time]
        :set lostPackets 1; # first package already sent! 
        :log info "-- WAN outage detected! $outageStart !"
    } else={
        #:log info "before incrementing lostPackets"
        :set lostPackets ($lostPackets + 1)
    }
} else={
    #:log info "Ping successful"
    #:log info "isOutage value before setting to false: $isOutage"
    :if ($isOutage) do={
        #:log info "no more outage!"
        :set isOutage false
        :local outageEnd [/system clock get time]
        :log info "-- WAN reconnected at $outageEnd. Duration: $lostPackets seconds. Lost packets: $lostPackets"
    }
}
#:log info "End of Script - isOutage value: $isOutage"
