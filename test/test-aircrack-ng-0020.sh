#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not expect \
exec ${EXPECT:=expect} "$0" ${1+"$@"}

exit -onexit {
    exp_internal 1
    exec rm -f pipe.cap
}

puts -nonewline "Aircrack-ng will tail PCAP files: "
flush stdout
exec mkfifo pipe.cap

log_user 0
spawn ../src/aircrack-ng -X pipe.cap
set tool_spawn_id $spawn_id

set timeout 5

# wait for startup
expect "Opening pipe.cap"

# send first cap
sleep 1
exec dd if=wep_64_ptw_01.cap of=pipe.cap conv=notrunc status=none
sleep 1
exec dd if=wep_64_ptw_01.cap of=pipe.cap conv=notrunc status=none

expect "got 2551 IVs"
expect {
    "Failed. Next try with 5000 IVs." {}
    eof { exit 1 }
    timeout { exit 2 }
}

exec dd if=wep_64_ptw_02.cap of=pipe.cap conv=notrunc status=none

expect "got 5100 IVs"
expect {
    "Failed. Next try with 10000 IVs." { sleep 2 }
    eof { exit 1 }
    timeout { exit 2 }
}

exec dd if=wep_64_ptw_03.cap of=pipe.cap conv=notrunc status=none
exec dd if=wep_64_ptw_04.cap of=pipe.cap conv=notrunc status=none

expect "got 10180 IVs"
expect {
    "Failed. Next try with 15000 IVs." { puts "OK\n"; exit 0 }
    eof { puts "FAILED"; exit 1 }
    timeout { puts "FAILED(timeout)"; exit 2 }
}

puts "FAILED(exceptional)"
exit 99
