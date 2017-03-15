proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {Common 17-41} -limit 10000000
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {Synth 8-295}  -string {{WARNING: [Synth 8-295] found timing loop. [C:/Users/Jeremiah/Programming/ee460M/Lab4decrementer.v:17]}}  -suppress 

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_param xicom.use_bs_reader 1
  open_checkpoint Lab4parkingMeterTop_routed.dcp
  set_property webtalk.parent_dir C:/Users/Jeremiah/Programming/ee460M/lab4/lab4.cache/wt [current_project]
  catch { write_mem_info -force Lab4parkingMeterTop.mmi }
  write_bitstream -force Lab4parkingMeterTop.bit 
  catch { write_sysdef -hwdef Lab4parkingMeterTop.hwdef -bitfile Lab4parkingMeterTop.bit -meminfo Lab4parkingMeterTop.mmi -file Lab4parkingMeterTop.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

