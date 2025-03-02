# tests a layer 3 network connection via ping to a designated IP address
# version 1.0-20250302.1/mz
# add to Scheduler with something like: /system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3

# to-dos:
# issue: Booting RouterOS still causes outage msgs despite checking 'next hop'!
# add: fallback destination IP adress(es) if host/destination IP is offline
# add: include destination IP in log msgs
# change: make DestIP global to be able to change it on the fly w/o altering the script!
# change: "WAN" to "Connection" or so .. make it rather universally descriptive 
# change: write only one line to log if only one packet was dropped
# consider: minimum packet loss before writing to log at all - aka "threshold"
# consider: changing all debug msgs to log to global variables. Would probably need some management.
# consider: writing log msgs to separate log (file?)
# consider: a mode switch which let the script itself run in a loop and won't need a scheduler. Which wouldn't be as accurate.
# consider: better names for local and global variables, esp. for debugging!
# consider: un-setting (removing) nextHopERROR, when next hop is back online
# note: something like this surely exists somewhere already, doesn't it? (if so, consider this an exercise!)
# note: it seems my hAP ac³ has no battery for its clock. So upon boot the time remains largely at the one from shutdown.

# setting up:
:local DestIP 83.216.32.162   ; # change IP address you want to check to your needs! 
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
} else={    # end main / would need indenting of above main section
        :global NextHopERROR ([/system clock get time] . ": next hop $NextHopIP not reachable!");
              # msg as global variable saves flooding the router's log
}
#:log info "End of Script - isOutage value: $isOutage"
