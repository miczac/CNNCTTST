# support script for connecttest.rsc: tests if CNNCTTSTdestIP has changed.
# version 0.1-20250527.1/mz
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
:global CNNCTTSTprevDestIP
:if ([:typeof $CNNCTTSTprevDestIP] != "ip") do={:set CNNCTTSTprevDestIP $CNNCTTSTdestIP}
:if ($CNNCTTSTdestIP != $CNNCTTSTprevDestIP) do={
  :log info "$revdMsgStr IP to test changed from $CNNCTTSTprevDestIP to $CNNCTTSTdestIP"
  :set CNNCTTSTprevDestIP $CNNCTTSTdestIP
}
