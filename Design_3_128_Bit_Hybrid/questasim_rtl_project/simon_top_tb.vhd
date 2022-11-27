--   _____ _____ __  __  ____  _   _ 
--  / ____|_   _|  \/  |/ __ \| \ | |
-- | (___   | | | \  / | |  | |  \| |
--  \___ \  | | | |\/| | |  | | . ` |
--  ____) |_| |_| |  | | |__| | |\  |
-- |_____/|_____|_|  |_|\____/|_| \_|     
--                                                           
----------------------------------------------------------------------------------------------------------
--    File Name:  simon_top_tb.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code is test bench to validate the simon encryption algorithm. 
--                Encryption / Decryption using 128 bit key is validated.                    
--
----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity simon_top_tb is
end entity;

architecture tb of simon_top_tb is

  -- Clock definition
  constant clk_period : time := 20 ns;
  signal key_word_in  : std_logic_vector(127 downto 0) := (others => '0');
  signal data_word_in : std_logic_vector(127 downto 0) ;

begin

  -- Tnstantiate DUT
  DUT: entity work.simon_top
  port map(
    key_word_in   => key_word_in,
    data_word_in  => data_word_in
  );

  -- Test Process
  STIM: process
  begin
    -- Send Key
    key_word_in  <= x"DEADBEEF0123456789ABCDEFDEADBEEF";
    -- Send Data
    data_word_in <= x"31235293e4a4fe37a3d42b43db1cbb58";
    wait;

  end process;

end architecture;