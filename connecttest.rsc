# tests a layer 3 network connection via ping to a designated IP address
# version 1.0	20250225/mz

# add: Check if next hop (router or modem) is online, e.g. via pinging its LAN interface
# add: Fallback IP adress(es) if next hop is offline

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
    :if (!$isOutage) do={         # an unset boolean returns 'false'
        #:log info "Network outage detected!"
        :set isOutage true
        :set outageStart [/system clock get time]
        :set lostPackets 1; # first package already sent! 
        :log info "-- WAN outage detected! $outageStart !"
    } else={
        #:log info "Incrementing lostPackets"
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
