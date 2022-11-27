--   _____ _____ __  __  ____  _   _ 
--  / ____|_   _|  \/  |/ __ \| \ | |
-- | (___   | | | \  / | |  | |  \| |
--  \___ \  | | | |\/| | |  | | . ` |
--  ____) |_| |_| |  | | |__| | |\  |
-- |_____/|_____|_|  |_|\____/|_| \_|     
--                                                           
----------------------------------------------------------------------------------------------------------
--    File Name:  simon_top.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code is a wrapper to execute the simon cipher encryption algorithm.
--                It uses 2 components - decryption and subkey generation.
--                Only 128 bit key lengths are supported. This is then wrapped with an HPS components to allow
--                the A9 on the De1-SoC board to communicate with the FPGA.
--
--        Input:  128 keys supplied 
--                128 bit data supplied
--
--       Output:  128 bit decrypted data 
--
--    Algorithm:  This code optimized for high performance, which results in 
--                large area usuage. This is achieved by generating
--                all required components and a combinational logic approach.
--                Sub-key generation / decryption are all computed in one clock cycle.
--
----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity simon_top is
  port(              
      key_word_in     : in  std_logic_vector(127 downto 0);
      data_word_in    : in  std_logic_vector(127 downto 0);
      data_word_out   : out std_logic_vector(127 downto 0)                
      );  
end entity simon_top;

architecture struct of simon_top is

  -- z constant for 128 bit key length
  constant const_z : std_logic_vector(67 downto 0) := x"17369f885192c0ef5";

  -- Signal to store generated subkeys
  type array_keys is array (33 downto 0) of std_logic_vector(127 downto 0);
  signal expanded_keys   : array_keys;

  -- Signal to store z value for generating subkeys
  type array_z is array (33 downto 0) of std_logic_vector(67 downto 0);
  signal shifted_z       : array_z;  

  -- Signals to store processed data
  type array_data is array (34 downto 0) of std_logic_vector(127 downto 0);
  signal decrypted_data  : array_data;

  -- Declare subkey generation component
  component simon_subkey_calc is
    port(
        sub_key_in       : in   std_logic_vector  (127 downto 0);
        z_in             : in   std_logic_vector  (67 downto 0);
        sub_key_out      : out  std_logic_vector  (127 downto 0);
        z_out            : out  std_logic_vector  (67 downto 0)
        );
  end component simon_subkey_calc;

  -- Declare encryption/decryption component
  component simon_dec is
    port(
        expanded_keys_in : in   std_logic_vector  (127 downto 0);
        data_in          : in   std_logic_vector  (127 downto 0);
        data_out         : out  std_logic_vector  (127 downto 0)
        );
  end component simon_dec;

begin

  -- Generate and connect component for subkeys
  sub_key_generate : for i in 0 to 32 generate
    simon_subkey_calc_insc : simon_subkey_calc
    port map(
            sub_key_in       => expanded_keys(i),
            z_in             => shifted_z(i),
            sub_key_out      => expanded_keys(i+1),
            z_out            => shifted_z(i+1)
            );
    end generate; 

  -- Generate and connect components for decryption
  simon_dec_generate : for i in 0 to 33 generate
    simon_dec_insc : simon_dec
    port map(
            expanded_keys_in => expanded_keys(33-i),
            data_in          => decrypted_data(i),
            data_out         => decrypted_data(i+1)
            );
    end generate; 

  shifted_z(0)        <= const_z;            -- Load first value of z from constant declaration
  expanded_keys(0)    <= key_word_in;        -- Load first value of key
  decrypted_data(0)   <= data_word_in;       -- Load first value of cipher Text
  data_word_out       <= decrypted_data(34); -- Export decrypted data

end architecture struct;
