# CNNCTTST
MikroTik RouterOS script providing a simple connection test via ICMP.

add to a RouterOS Scheduler using
/system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3

