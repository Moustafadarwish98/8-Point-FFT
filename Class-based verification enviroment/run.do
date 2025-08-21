vlib work
vlog *.*v +cover=bcesf -covercells
vsim +define+SVA_ON -vopt -voptargs=+acc work.fft_tb -cover
do wave.do
run -all
coverage save fft_tb.ucdb
quit
