--   _____ _____ __  __  ____  _   _ 
--  / ____|_   _|  \/  |/ __ \| \ | |
-- | (___   | | | \  / | |  | |  \| |
--  \___ \  | | | |\/| | |  | | . ` |
--  ____) |_| |_| |  | | |__| | |\  |
-- |_____/|_____|_|  |_|\____/|_| \_|     
--                                                           
----------------------------------------------------------------------------------------------------------
--    File Name:  simon_dec.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code is used to decrypt two blocks of 64 bit data.
--
--        Input:  2x 64 bit key concatenated to 128 bit
--                2x 64 bit data concatenated to 128 bit
--                
--       Output:  2x Decrypted 64 bit data concatenated to 128 bit
--                
--
--    Algorithm:  This code purely combinational logic with no clock/reset required.
--
----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simon_dec is
    port(
        expanded_keys_in : in   std_logic_vector  (127 downto 0);
        data_in          : in   std_logic_vector  (127 downto 0);
        data_out         : out  std_logic_vector  (127 downto 0)
        );
end entity simon_dec;

architecture rtl of simon_dec is

begin
    dec_proc : process(expanded_keys_in,data_in)
        -- Internal variables to store calculations
        variable data_out_0 : std_logic_vector (63 downto 0);
        variable data_out_1 : std_logic_vector (63 downto 0);

    begin
    
        -- Perform bitwise operations to generate first 64 bits of data
        data_out_1 := data_in(63 downto 0) 
        xor ((std_logic_vector(unsigned (data_in(127 downto 64)) rol 1)) 
        and  (std_logic_vector(unsigned (data_in(127 downto 64)) rol 8)))
        xor  (std_logic_vector(unsigned (data_in(127 downto 64)) rol 2));

        -- Perform bitwise operations of data with subkey
        data_out_1 := data_out_1 xor expanded_keys_in(127 downto 64);

        -- Perform bitwise operations to generate last 64 bits of data
        data_out_0:= data_in(127 downto 64) 
        xor ((std_logic_vector(unsigned (data_out_1) rol 1)) 
        and  (std_logic_vector(unsigned (data_out_1) rol 8)))
        xor  (std_logic_vector(unsigned (data_out_1) rol 2));

        -- Perform bitwise operations of data with subkey
        data_out_0 := data_out_0 xor expanded_keys_in(63 downto 0);

        -- Combine and send internal variables to output
        data_out <= data_out_0 & data_out_1;

    end process dec_proc;


end architecture rtl;
