# tests a layer 3 network connection via ping to a designated IP address
# version 1.0-20250227.2/mz
# add to Scheduler with something like: /system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3

# future changes:
# add: check if next hop (router or modem) is online, e.g. via pinging its LAN interface
# add: fallback destination IP adress(es) if next hop is offline
# add: include destination IP in log msgs
# change: "WAN" to "Connection" or so .. make it rather universally usable 
# change: write only one line to log if only one packet dropped
# consider: minimum packet loss before writing to log at all - aka "threshold"
# consider: writing log msgs to separate log (file?)
# consider: a mode switch which let the script itself run in a loop and won't need a scheduler
# note: something like this surely exists somewhere already, doesn't it? (if so, consider this an exercise!)

# setting up:
:local DestIP 83.216.32.162   ; # change IP address to check to your needs! 
:local NextHopIP 192.168.0.1  ; # insert the next hop's IP towards $DestIP here!

:local revdMsgStr "noitcennoc NAW --"; # start of log-msg reversed for cleaner find in logs

:global isOutage
:global outageStart
:global lostPackets

:local nextHopOn [/ping $NextHopIP count=1]
:if ($nextHopOn = 1) do={ # continue testing $DestIP in main section

:local FrevString do={      # reverses given string
    :local inpStr $1
    :local revdStr ""
    :for i from=([:len $inpStr] - 1) to=0 do={
        :set revdStr ($revdStr . [:pick $inpStr $i])
 }
    :return $revdStr
}
:local logMsgStr [$FrevString $revdMsgStr]

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
        :log info "$logMsgStr lost at $outageStart !"
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
        :log info "$logMsgStr restored at $outageEnd. $lostPackets packets dropped."
    }
}
} else={    # end main
        :global NextHopERROR ([/system clock get time] . ": next hop $NextHopIP not reachable!"); # msg as global variable saves flooding the router's log
}
#:log info "End of Script - isOutage value: $isOutage"
