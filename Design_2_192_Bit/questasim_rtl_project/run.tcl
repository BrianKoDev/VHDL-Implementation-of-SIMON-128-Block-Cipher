
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
add wave -position end  sim:/simon_top_tb/DUT/expanded_keys
add wave -position end  sim:/simon_top_tb/DUT/shifted_z
add wave -position end  sim:/simon_top_tb/DUT/encrypted_data
add wave -position end  sim:/simon_top_tb/DUT/decrypted_data
add wave -position end  sim:/simon_top_tb/DUT/import_keys_fsm
add wave -position end  sim:/simon_top_tb/DUT/import_data_fsm
add wave -position end  sim:/simon_top_tb/DUT/export_data_fsm
run 1 us
