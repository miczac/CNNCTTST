# CNNCTTST
MikroTik RouterOS script providing a simple connection test via ICMP.

Add to a RouterOS Scheduler, for example:
```
/system/scheduler/add name=ConnTest disabled=yes on-event="/system script run \"connecttest.rsc\"" interval=3
```
(change parameters to your needs)

### Parameters to set up in the script

At the top of the script, find the comment line '*setting up below*'
You'll need to configure three variables:
- `setupDestIP`  IP-address of host/interface to check/monitor
- `setupNextHopIP`  next hop's IP towards $setupDestIP
- `revdMsgStr`  first few characters of log-msg, but reversed (for cleaner filtering in logs)

### Parameters to tweak in RouterOS's script environment during runtime

- `CNNCTTSTnextHopIP` - for monitoring the connection to the next hop
- `CNNCTTSTdestIP` - the host or interface to monitor

### Testing the setup

To see if the script works as intended, change `CNNCTTSTnextHopIP` or `CNNCTTSTdestIP` in the environment to addresses which wouldn't respond to a ping.
This would result in an error condition, either by not performing the actual connection test (*CNNCTTSTnextHopIP*) or by reporting a (simulated) broken connection to the router's log.
