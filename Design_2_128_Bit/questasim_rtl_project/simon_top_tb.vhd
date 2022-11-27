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

  -- Input signals
  signal clk           : std_logic := '1';
  signal reset_n       : std_logic := '0';
  signal encryption    : std_logic := '0';
  signal key_length    : std_logic_vector(1 downto 0)  := (others => '0');
  signal key_valid     : std_logic := '0';
  signal key_word_in   : std_logic_vector(31 downto 0) := (others => '0');
  signal data_valid    : std_logic := '0';
  signal data_word_in  : std_logic_vector (31 downto 0) ;

  -- Output signals
  signal data_word_out : std_logic_vector (31 downto 0);
  signal data_ready    : std_logic;
  
  -- Internal signals
  signal data_bkp : std_logic_vector (127 downto 0) := (others => '0');

begin
  -- Generate Clock
  clk <= not clk after clk_period/2;

  -- Tnstantiate DUT
  DUT: entity work.simon_top
  port map(
    clk           => clk,
    reset_n       => reset_n,
    encryption    => encryption,
    key_length    => key_length,
    key_valid     => key_valid,
    key_word_in   => key_word_in,
    data_valid    => data_valid,
    data_word_in  => data_word_in,
    data_word_out => data_word_out,
    data_ready    => data_ready
  );

  -- Begin Testing Process
  STIM: process
  begin

    -- 128 Bits Key Encryption Test
    reset_n      <= '0';
    wait for 4*clk_period;
    encryption   <= '1'; 
    key_length   <= "00"; 
    reset_n      <= '1';
    wait for clk_period;

    -- Send Key
    key_valid    <= '1';
    key_word_in  <= x"DEADBEEF";
    wait for clk_period;
    key_word_in  <= x"01234567";
    wait for clk_period;
    key_word_in  <= x"89ABCDEF";
    wait for clk_period;
    key_word_in  <= x"DEADBEEF";
    wait for clk_period;

    -- Send Data
    key_valid    <= '0';
    key_word_in  <= x"00000000";
    data_valid   <= '1';
    data_word_in <= x"A5A5A5A5";
    wait for clk_period;
    data_word_in <= x"01234567";
    wait for clk_period;
    data_word_in <= x"FEDCBA98";
    wait for clk_period;
    data_word_in <= x"5A5A5A5A";
    wait for clk_period;

    -- Wait for Encryption to complete
    data_valid   <= '0';
    data_word_in <= x"00000000";
    wait until data_ready = '1';
    wait for clk_period;

    -- Write Cipher Text to Internal Signal
    data_bkp(127 downto 96) <= data_word_out;
    wait for clk_period;
    data_bkp(95 downto 64)  <= data_word_out;
    wait for clk_period;
    data_bkp(63 downto 32)  <= data_word_out;
    wait for clk_period;
    data_bkp(31 downto 0)   <= data_word_out;


    -- 128 Bits Key Decryption Test
    reset_n      <= '0';
    wait for 4*clk_period;
    encryption   <= '0';  
    key_length   <= "00"; 
    reset_n      <= '1';
    wait for clk_period;

    -- Send Key
    key_valid    <= '1';
    key_word_in  <= x"DEADBEEF";
    wait for clk_period;
    key_word_in  <= x"01234567";
    wait for clk_period;
    key_word_in  <= x"89ABCDEF";
    wait for clk_period;
    key_word_in  <= x"DEADBEEF";
    wait for clk_period;

    -- Send Data
    key_valid    <= '0';
    key_word_in  <= x"00000000";
    data_valid   <= '1';
    data_word_in <= data_bkp(127 downto 96);
    wait for clk_period;
    data_word_in <= data_bkp(95 downto 64);
    wait for clk_period;
    data_word_in <= data_bkp(63 downto 32);
    wait for clk_period;
    data_word_in <= data_bkp(31 downto 0);
    wait for clk_period;

    -- Wait for Decryption to complete
    data_valid   <= '0';
    data_word_in <= x"00000000";
    wait until data_ready = '1';
    wait for clk_period;

    -- Write Decrypted Text to Internal Signal
    data_bkp(127 downto 96) <= data_word_out;
    wait for clk_period;
    data_bkp(95 downto 64)  <= data_word_out;
    wait for clk_period;
    data_bkp(63 downto 32)  <= data_word_out;
    wait for clk_period;
    data_bkp(31 downto 0)   <= data_word_out;

    wait;
  end process;

end architecture;