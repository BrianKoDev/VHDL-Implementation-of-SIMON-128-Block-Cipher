--   _____ _____ __  __  ____  _   _ 
--  / ____|_   _|  \/  |/ __ \| \ | |
-- | (___   | | | \  / | |  | |  \| |
--  \___ \  | | | |\/| | |  | | . ` |
--  ____) |_| |_| |  | | |__| | |\  |
-- |_____/|_____|_|  |_|\____/|_| \_|     
--                                                           
----------------------------------------------------------------------------------------------------------
--    File Name:  simon_enc_dec.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code is used to encrypt/decrypt one block of 64 bit data.
--
--        Input:  64 bit key
--                First 64 bit data
--                Second 64 bit data
--                
--
--       Output:  Encrypted/Decrypted 64 bit data
--                
--
--    Algorithm:  This code is purely combinational logic with no clock/reset required.
--
----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simon_enc_dec is
    port(
        expanded_keys_in : in   std_logic_vector  (63 downto  0);
        data_in_0        : in   std_logic_vector  (63 downto  0);
        data_in_1        : in   std_logic_vector  (63 downto  0);
        data_out         : out  std_logic_vector  (63 downto  0)
        );
end entity simon_enc_dec;

architecture rtl of simon_enc_dec is
begin

    -- Process to Encrypt / Decrypt
    enc_dec_proc : process(expanded_keys_in, data_in_0, data_in_1)
        -- Internal variables to store calculations
        variable var_data_out : std_logic_vector (63 downto 0);

    begin

        -- Perform bitwise operations to generate 64 bits of data
        var_data_out := data_in_0 
        xor ((std_logic_vector(unsigned (data_in_1) rol 1)) 
        and  (std_logic_vector(unsigned (data_in_1) rol 8)))
        xor  (std_logic_vector(unsigned (data_in_1) rol 2));

        -- Perform bitwise operations of data with subkey
        var_data_out := var_data_out xor expanded_keys_in;

        -- Combine and send internal variables to output
        data_out <= var_data_out;

    end process enc_dec_proc;
end architecture rtl;
