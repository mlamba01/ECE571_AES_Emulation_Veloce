run -all
set SIMLOG [open simstats.log w+]
puts $SIMLOG [simstats]
close $SIMLOG
quit -sim
quit -f