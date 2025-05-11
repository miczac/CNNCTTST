# support script for connecttest.rsc: tests if CNNCTTSTdestIP has changed.
# version 0.2-20250511.1/mz
##
:global CNNCTTSTprevDestIP
:if ([:typeof $CNNCTTSTprevDestIP] != "ip") do={:set CNNCTTSTprevDestIP $CNNCTTSTdestIP}
:if ($CNNCTTSTdestIP != $CNNCTTSTprevDestIP) do={
    :log info "-- WAN IP to test changed from $CNNCTTSTprevDestIP to $CNNCTTSTdestIP"
    :set CNNCTTSTprevDestIP $CNNCTTSTdestIP
}

