vlib work
vlog *.*v
vsim +define+SVA_ON -vopt -voptargs=+acc work.tb_fft
add wave *
run -all
