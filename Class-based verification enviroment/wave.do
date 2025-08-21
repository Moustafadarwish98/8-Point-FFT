onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Clock & Reset} /fft_tb/fft_if0/clk
add wave -noupdate -expand -group {Clock & Reset} /fft_tb/fft_if0/rst_n
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in0_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in1_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in2_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in3_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in4_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in5_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in6_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in7_r
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in1_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in2_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in3_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in4_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in5_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in6_imag
add wave -noupdate -expand -group Inputs /fft_tb/fft_if0/in7_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out0_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out1_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out2_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out3_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out4_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out5_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out6_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out7_r
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out0_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out1_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out2_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out3_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out4_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out5_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out6_imag
add wave -noupdate -expand -group Outputs /fft_tb/fft_if0/out7_imag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {199998498 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {265472 ps}
