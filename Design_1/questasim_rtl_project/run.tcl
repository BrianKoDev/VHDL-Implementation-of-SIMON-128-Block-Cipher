
vcom simon_enc_dec.vhd
vcom simon_subkey_calc.vhd
vcom simon_top.vhd
vcom simon_top_tb.vhd

vsim work.simon_top_tb -voptargs=+acc
add wave -position end  sim:/simon_top_tb/clk
add wave -position end  sim:/simon_top_tb/reset_n
add wave -position end  sim:/simon_top_tb/encryption
add wave -position end  sim:/simon_top_tb/key_length
add wave -position end  sim:/simon_top_tb/key_valid
add wave -position end  sim:/simon_top_tb/key_word_in
add wave -position end  sim:/simon_top_tb/data_valid
add wave -position end  sim:/simon_top_tb/data_word_in
add wave -position end  sim:/simon_top_tb/data_word_out
add wave -position end  sim:/simon_top_tb/data_ready
add wave -position end  sim:/simon_top_tb/data_bkp
add wave -position end  sim:/simon_top_tb/clk_period
add wave -position end  sim:/simon_top_tb/DUT/import_key_0
add wave -position end  sim:/simon_top_tb/DUT/import_key_1
add wave -position end  sim:/simon_top_tb/DUT/import_key_2
add wave -position end  sim:/simon_top_tb/DUT/import_keys_fsm
add wave -position end  sim:/simon_top_tb/DUT/imported_data_0
add wave -position end  sim:/simon_top_tb/DUT/imported_data_1
add wave -position end  sim:/simon_top_tb/DUT/import_data_fsm
add wave -position end  sim:/simon_top_tb/DUT/expanded_keys
add wave -position end  sim:/simon_top_tb/DUT/shifted_z
add wave -position end  sim:/simon_top_tb/DUT/generate_keys_count
add wave -position end  sim:/simon_top_tb/DUT/generate_keys_fsm
add wave -position end  sim:/simon_top_tb/DUT/processing_data_0
add wave -position end  sim:/simon_top_tb/DUT/processing_data_1
add wave -position end  sim:/simon_top_tb/DUT/enc_dec_count
add wave -position end  sim:/simon_top_tb/DUT/enc_dec_fsm
add wave -position end  sim:/simon_top_tb/DUT/export_data_fsm
add wave -position end  sim:/simon_top_tb/DUT/sub_key_in_0
add wave -position end  sim:/simon_top_tb/DUT/sub_key_in_1
add wave -position end  sim:/simon_top_tb/DUT/z_in
add wave -position end  sim:/simon_top_tb/DUT/sub_key_out
add wave -position end  sim:/simon_top_tb/DUT/z_out
add wave -position end  sim:/simon_top_tb/DUT/expanded_keys_in
add wave -position end  sim:/simon_top_tb/DUT/data_in_0
add wave -position end  sim:/simon_top_tb/DUT/data_in_1
add wave -position end  sim:/simon_top_tb/DUT/data_out
run 26 us
