:local HOP 2
:local traceDestIP 9.9.9.9
:local newDIP
:local PIP [ping ttl=$HOP count=1 $traceDestIP  as-value]
:local CNT 0
foreach V in $PIP do={
  #:put $V
  :if ($CNT = 1) do={ ; # this seems to be dodgy because other values won't work!
    :set newDIP [:toip $V]
    :global typeConversionTST ([:typeof $V]."###".[:typeof $CNNCTTSTdestIP])
    :if ($newDIP != $traceDestIP) do={
      :set CNNCTTSTdestIP $newDIP
    } ;#    else {
#     :log info "-- WAN  newDIP  reset to $traceDestIP"
#   }
  }
  :set CNT ($CNT+1)
}

#:local HOP 2; :local PIP [ping ttl=$HOP count=1 9.9.9.9 as-value]; :local CNT 0; foreach V in $PIP do={:put $V; if ($CNT = 1) do={:global  CNNCTTSTdestIP [:toip $V]; :global typeConversion ([:typeof $V]."###".[:typeof $CNNCTTSTdestIP])}; :set CNT ($CNT+1)}; # seems to have troubel with asynchronous processing
