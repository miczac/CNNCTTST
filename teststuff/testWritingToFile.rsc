:global ENABLEwriteTest 1 ;  # run immediately, remove from environment to stop
:log warning  ("ENABLEwriteTest:  " . $ENABLEwriteTest) ; # 'warning', just for the blue log entry

:local logfilename "foo.txt"
:local testdata fooData ; # set accordingly to your needs in the loop, if.

:local FncChkIfFileExistsAndCreateItIfNot do={ 
  :local filename $1
  :if ([:len [/file find name=$filename]] = 0) do={   
    /file/add name=$filename
    :log warning ("file " . $filename . " doesn't exist, may have been deleted prematurely -> created")
    :delay 1 ; # crude way to avoid a race condition because file may (err, will) not be created in time!
  }
}

:while ($ENABLEwriteTest = 1) do={
# :set testdata <placewhateveryoulikehere>
  $FncChkIfFileExistsAndCreateItIfNot $logfilename
  /file/set [find name="$logfilename"] contents=([/file get $logfilename contents] . $testdata . "\n")
                                       # there's no 'append' functionality in ROS scripting
  :delay 3 ;  # dont' bother utilising the scheduler for this test
}
:log warning "script testWritingToFile ended!"
