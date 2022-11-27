--   _____ _____ __  __  ____  _   _ 
--  / ____|_   _|  \/  |/ __ \| \ | |
-- | (___   | | | \  / | |  | |  \| |
--  \___ \  | | | |\/| | |  | | . ` |
--  ____) |_| |_| |  | | |__| | |\  |
-- |_____/|_____|_|  |_|\____/|_| \_|     
--                                                           
----------------------------------------------------------------------------------------------------------
--    File Name:  simon_subkey_calc.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code is used to generate new sub-keys.
--
--        Input:  First 64 bit sub-key
--                Second 64 bit sub-key
--                Shifted z value
--                
--
--       Output:  Generated sub-key
--                
--
--    Algorithm:  This code is purely combinational logic with no clock/reset required.
--
----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simon_subkey_calc is
    port(
        sub_key_in_0 : in   std_logic_vector  (63 downto 0);
        sub_key_in_1 : in   std_logic_vector  (63 downto 0);
        z_in         : in   std_logic_vector  (67 downto 0);
        sub_key_out  : out  std_logic_vector  (63 downto 0);
        z_out        : out  std_logic_vector  (67 downto 0)
        );
end entity simon_subkey_calc;


architecture rtl of simon_subkey_calc is

    constant c    : std_logic_vector := x"fffffffffffffffc";

begin
    -- Process to generate subkey
    sub_key_gen_proc : process (sub_key_in_0, sub_key_in_1, z_in)

        -- Internal variables to store calculations
        variable var_sub_key_out : std_logic_vector (63 downto 0);
        variable var_z_out       : std_logic_vector (67 downto 0);

    begin
        -- Perform bitwise operations to generate subkey
        var_sub_key_out := c 
        xor (x"000000000000000" & b"000" & z_in(0 downto 0)) 
        xor sub_key_in_1 
        xor (std_logic_vector(unsigned (sub_key_in_0) ror 4)) 
        xor (std_logic_vector(unsigned (sub_key_in_0) ror 3));

        -- Shift z value for use in next key generation stage
        var_z_out := b"0" & z_in(67 downto 1);

        -- Send internal variables to output
        sub_key_out <= var_sub_key_out;
        z_out       <= var_z_out;

    end process sub_key_gen_proc;

end architecture rtl;


