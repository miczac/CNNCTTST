:global ENABLEwriteTest 1 ;  # run immediately 
':log info  ("ENABLEwriteTest " . $ENABLEwriteTest)
:global CNNCTTSTrouterUptime ; # some rather arbitrary data, so using this variable
#:log info  ("CNNCTTSTrouterUptime" . $CNNCTTSTrouterUptime)

:local logfilename "foo.txt"

:while ($ENABLEwriteTest = 1) do={
  :if ([:len [/file find name=$logfilename]] = 0) do={
    /file/add name=$logfilename
    :log warning ("file " . $logfilename . " doesn't exist -> create")
  }
  /file/set [find name="bla.txt"] contents=([/file get bla.txt contents] . $CNNCTTSTrouterUptime . "\n")
  :delay 7
}

