# tests a layer 3 network connection via ping to a designated IP address
# version 1.1-20250310.1/mz
# add to Scheduler with something like: /system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3
# source it from https://github.com/miczac/CNNCTTST

# to-dos:
# issue: Booting RouterOS still causes outage msgs despite checking 'next hop'!
# add: fallback destination IP adress(es) if host/destination IP is offline
# add: include destination IP in log msgs
# add: # of dropped packets to nextHop in CNNCTTSTnextHopERROR
# change: "WAN" to "Connection" or so .. make it rather universally descriptive 
# change: write only one line to log if only one packet was dropped
# change: singular/plural differentiation: "1 packet" vs. "23 packets"
# consider: In addition to pinging the next hop check if local interface is up. 
# consider: minimum packet loss before writing to log at all - aka "threshold"
# consider: changing all debug msgs to log to global variables. Would probably need some management.
# consider: writing log msgs to separate log (file?)
# consider: a mode switch which let the script itself run in a loop and won't need a scheduler. Which wouldn't be as accurate.
# consider: still need better names for local and global variables, esp. for debugging!
# consider: avoiding using an extra global for CNNCTTSTnextHopERROR packets. Pick from error-msg!
# note: something like this surely exists somewhere already, doesn't it? (if so, consider this an exercise, but it's more than just a ping! ;)
# note: it seems my hAP ac³ has no battery for its clock. So upon boot the time remains largely at the one from shutdown.

# setting up below:  v - - - - - - - - - - v 
:local setupDestIP    9.9.9.9;         # IP-address of host/interface to check
:local setupNextHopIP 192.168.0.1;     # insert the next hop's IP towards $setupDestIP here!
:local revdMsgStr "noitcennoc NAW --"; # start of log-msg reversed for cleaner find in logs
# setting up above:  ^ - - - - - - - - - - ^

:global CNNCTTSTdestIP ; # change IP-addresses you want to check to your needs in WinBox's environment! 
:global CNNCTTSTnextHopIP
:global CNNCTTSTisOutage
:global CNNCTTSToutageStart
:global CNNCTTSTnumLostPackets

# init global variables just in case they are not set properly
:if ([:typeof $CNNCTTSTdestIP] != "ip") do={:set CNNCTTSTdestIP $setupDestIP}
:if ([:typeof $CNNCTTSTnextHopIP] != "ip") do={:set CNNCTTSTnextHopIP $setupNextHopIP}
:if ([:typeof $CNNCTTSTisOutage] != "bool") do={:set CNNCTTSTisOutage false} 

:local nextHopOK [/ping $CNNCTTSTnextHopIP count=1]
:if ($nextHopOK = 0) do={
            # msg in a global variable prevents flooding the router's log
    :global CNNCTTSTnextHopERROR ([/system clock get time] . ": next hop $CNNCTTSTnextHopIP not reachable!")
    :quit ; # any further action would be in vain 
}

# else continue testing $CNNCTTSTdestIP in main section

:local FrevString do={      # function, reverses given string
    :local inpStr $1
    :local revdStr ""
    :for i from=([:len $inpStr] - 1) to=0 do={
        :set revdStr ($revdStr . [:pick $inpStr $i])
    }
    :return $revdStr
}
:local logMsgStr [$FrevString $revdMsgStr]

:local pingResult [/ping $CNNCTTSTdestIP count=1];
#:log info "Ping result: $pingResult"
#:log info "Current CNNCTTSTisOutage value before checking: $CNNCTTSTisOutage"

:if ($pingResult = 0) do={  
    #:log info "Ping failed"
    #:log info "CNNCTTSTisOutage value before inner check: $CNNCTTSTisOutage"
    :if (!$CNNCTTSTisOutage) do={         # an unset boolean returns 'false'!
        #:log info "Connection outage detected!"
        :set CNNCTTSTisOutage true
        :set CNNCTTSToutageStart [/system clock get time]
        :set CNNCTTSTnumLostPackets 1; # first package already sent! 
        :log info "$logMsgStr lost at $CNNCTTSToutageStart !"
    } else={
        #:log info "before incrementing CNNCTTSTnumLostPackets"
        :set CNNCTTSTnumLostPackets ($CNNCTTSTnumLostPackets + 1)
    }
} else={
    #:log info "Ping successful"
    #:log info "CNNCTTSTisOutage value before setting to false: $CNNCTTSTisOutage"
    :if ($CNNCTTSTisOutage) do={
        #:log info "no more outage!"
        :set CNNCTTSTisOutage false
        :local outageEnd [/system clock get time]
        :log info "$logMsgStr restored at $outageEnd. $CNNCTTSTnumLostPackets packet/s dropped."
    }
}
#:log info "End of Script - CNNCTTSTisOutage value: $CNNCTTSTisOutage"
