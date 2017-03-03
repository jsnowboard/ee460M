add wave sim:/Lab4parkingMeterTop/*
force CLK 0 0, 1 10 -repeat 20
run 1000
force DWN 1
run 10000
force DWN 0
run 100000
