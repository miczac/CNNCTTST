# this doesn't work since traceroute wouldn't hand over a useable text output!
:global ExtTestIP
:local troutput [/tool traceroute address=9.9.9.9 max-hops=5 count=1]
:local hopCount 0
:log info "Init Hop $hopCount"
:foreach i in=$troutput do={
    :set hopCount ($hopCount + 1)
    :log info "Hop $hopCount: $i"
    :if ($hopCount = 2) do={
        :set ExtTestIP [:pick $i 20 35]  ; # Adjust indices to extract the IP address
        :log info "Second hop IP: $ExtTestIP"
        :break
    }
}
:log info "Exiting after Hop $hopCount"
