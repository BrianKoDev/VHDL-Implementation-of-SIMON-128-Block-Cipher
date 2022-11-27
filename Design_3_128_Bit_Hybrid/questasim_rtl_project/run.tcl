
vcom simon_dec.vhd
vcom simon_subkey_calc.vhd
vcom simon_top.vhd
vcom hps.vhd
vcom hps_tb.vhd

vsim -voptargs=+acc work.hps_tb

add wave -position end  sim:/hps_tb/clk
add wave -position end  sim:/hps_tb/reset
add wave -position end  sim:/hps_tb/avs_s0_address
add wave -position end  sim:/hps_tb/avs_s0_read
add wave -position end  sim:/hps_tb/avs_s0_write
add wave -position end  sim:/hps_tb/avs_s0_writedata
add wave -position end  sim:/hps_tb/avs_s0_readdata
add wave -position end  sim:/hps_tb/hps_insc/r_key_0
add wave -position end  sim:/hps_tb/hps_insc/r_key_1
add wave -position end  sim:/hps_tb/hps_insc/r_key_2
add wave -position end  sim:/hps_tb/hps_insc/r_key_3
add wave -position end  sim:/hps_tb/hps_insc/r_data_0
add wave -position end  sim:/hps_tb/hps_insc/r_data_1
add wave -position end  sim:/hps_tb/hps_insc/r_data_2
add wave -position end  sim:/hps_tb/hps_insc/r_data_3
add wave -position end  sim:/hps_tb/hps_insc/r_decrypted_0
add wave -position end  sim:/hps_tb/hps_insc/r_decrypted_1
add wave -position end  sim:/hps_tb/hps_insc/r_decrypted_2
add wave -position end  sim:/hps_tb/hps_insc/r_decrypted_3
add wave -position end  sim:/hps_tb/hps_insc/key_word_in
add wave -position end  sim:/hps_tb/hps_insc/data_word_in
add wave -position end  sim:/hps_tb/hps_insc/data_word_out
add wave -position end  sim:/hps_tb/hps_insc/simon_top_insc/expanded_keys
add wave -position end  sim:/hps_tb/hps_insc/simon_top_insc/decrypted_data
run 300 ns

