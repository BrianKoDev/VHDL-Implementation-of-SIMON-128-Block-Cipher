----------------------------------------------------------------------------------------------------------
--    File Name:  hps_tb.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code sends data via the HPS bus to simulate c code running on the top of the A9.
--                This is used to validate the HPS component to ensure it can communicate correctly with 
--                the simon_top component. 
----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hps_tb is
end entity hps_tb;

architecture tb of hps_tb is

  -- Declare HPS component
  component hps is
    port (
      clk              : in  std_logic;
      reset            : in  std_logic;
      avs_s0_address   : in  std_logic_vector(3 downto 0);
      avs_s0_read      : in  std_logic;
      avs_s0_write     : in  std_logic;
      avs_s0_writedata : in  std_logic_vector(31 downto 0);
      avs_s0_readdata  : out std_logic_vector(31 downto 0));
  end component hps;

  -- Internal signals
  signal clk              : std_logic;
  signal reset            : std_logic;
  signal avs_s0_address   : std_logic_vector(3 downto 0);
  signal avs_s0_read      : std_logic;
  signal avs_s0_write     : std_logic;
  signal avs_s0_writedata : std_logic_vector(31 downto 0);
  signal avs_s0_readdata  : std_logic_vector(31 downto 0);

begin 

  -- Instantiate component 
  hps_insc : entity work.hps
    port map (
      clk              => clk,
      reset            => reset,
      avs_s0_address   => avs_s0_address,
      avs_s0_read      => avs_s0_read,
      avs_s0_write     => avs_s0_write,
      avs_s0_writedata => avs_s0_writedata,
      avs_s0_readdata  => avs_s0_readdata);


  -- Generate clock
  clock_proc : process is
  begin  
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process clock_proc;

  -- Reset signal
  reset <= '1', '0' after 10 ns;

  -- Test Process
  test_proc : process is
  begin

    wait for 10 ns;

    -- Send Key
    avs_s0_address   <= "0000"; -- 0
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"DEADBEEF";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";

    wait for 10 ns;
    avs_s0_address   <= "0001"; -- 1
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"01234567";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";

    wait for 10 ns;
    avs_s0_address   <= "0010"; -- 2
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"89ABCDEF";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";

    wait for 10 ns;
    avs_s0_address   <= "0011"; -- 3
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"DEADBEEF";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";



    -- Send Cipher Text
    wait for 10 ns;
    avs_s0_address   <= "0100"; -- 4
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"31235293";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";

    wait for 10 ns;
    avs_s0_address   <= "0101"; -- 5
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"e4a4fe37";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";
    
    wait for 10 ns;
    avs_s0_address   <= "0110"; -- 6
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"a3d42b43";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";
    
    wait for 10 ns;
    avs_s0_address   <= "0111"; -- 7
    avs_s0_read      <= '0';
    avs_s0_write     <= '1';
    avs_s0_writedata <= x"db1cbb58";
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';
    avs_s0_write     <= '0';
    avs_s0_writedata <= x"00000000";
    

    -- Read decrypted text
    avs_s0_address   <= "1000";
    avs_s0_read      <= '1';
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';

    wait for 10 ns;
    avs_s0_address   <= "1001";
    avs_s0_read      <= '1';
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';

    wait for 10 ns;
    avs_s0_address   <= "1010";
    avs_s0_read      <= '1';
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';

    wait for 10 ns;
    avs_s0_address   <= "1011";
    avs_s0_read      <= '1';
    wait for 10 ns;
    avs_s0_address   <= "0000";
    avs_s0_read      <= '0';

    wait;

  end process test_proc;
  
end architecture tb;

