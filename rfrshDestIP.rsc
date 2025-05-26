# preliminary script for updating IP address of hop to test.
# probably will be incorporated into connecttest.rsc
# version 0.1-20250526.1/mz
##
:local FncReverseString do={
    :local inpStr $1
    :local revdStr ""
    :for i from=([:len $inpStr] - 1) to=0 do={
        :set revdStr ($revdStr . [:pick $inpStr $i])
    }
    :return $revdStr
}
:local logMsgStr [$FncReverseString $revdMsgStr]

:local revdMsgStr "NAW --"
:local HOP 2 
:global CNNCTTSTdestIP
:local traceDestIP 9.9.9.9
:local newDIP
:local PIP [ping ttl=$HOP count=1 $traceDestIP  as-value]
:if (($PIP->"status") = "TTL exceeded") do={
    :set newDIP [:toip ($PIP->"host")]
    :if ($newDIP != $traceDestIP) do={
    :set CNNCTTSTdestIP $newDIP
  } else={
    :log info "$revdMsgStr  newDIP  reset to $traceDestIP -> ignored"
  } 
}

#:local HOP 2; :local PIP [ping ttl=$HOP count=1 9.9.9.9 as-value]; :local CNT 0; foreach V in $PIP do={:put $V; if ($CNT = 1) do={:global  CNNCTTSTdestIP [:toip $V]; :global typeConversion ([:typeof $V]."###".[:typeof $CNNCTTSTdestIP])}; :set CNT ($CNT+1)}; # seems to have troubel with asynchronous processing
