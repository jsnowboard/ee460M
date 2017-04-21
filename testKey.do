force PS2Clk 1
force PS2Data 1
run 100
force PS2Data 0
run 2
force PS2Clk 0 0, 1 10 -repeat 20
run 15
force PS2Data 1
run 100
force PS2Data 0
run 100
force PS2Data 0
run 20
force PS2Data 0
run 80
force PS2Data 1
run 20
force PS2Data 1
run 40
force PS2Data 0
run 60
force PS2Data 1
force PS2Clk 1
run 100