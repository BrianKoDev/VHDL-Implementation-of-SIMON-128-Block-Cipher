----------------------------------------------------------------------------------------------------------
--    File Name:  hps.vhd
--       Author:  Brian Ko
--     Language:  VHDL 1076-2002
--     Compiler:  Questa Intel Starter FPGA Edition-64 vcom 2021.2 Compiler 2021.04 Apr 14 2021
----------------------------------------------------------------------------------------------------------
--
--  Description:  This code allows the c code running on the top of the A9 to communicate with the 
--                simon_top module.
--
--        Input:  HPS bus
--                
--       Output:  simon_top component
--
----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define entity for HPS bus
entity hps is
port(
      clk              : in  std_logic;
      reset            : in  std_logic;
      avs_s0_address   : in  std_logic_vector(3 downto 0);
      avs_s0_read      : in  std_logic;
      avs_s0_write     : in  std_logic;
      avs_s0_writedata : in  std_logic_vector(31 downto 0);
      avs_s0_readdata  : out std_logic_vector(31 downto 0)
      );
end hps;


architecture rtl of hps is

--Declare component for simon cipher module
component simon_top is
  port(
      key_word_in     : in  std_logic_vector(127 downto 0);
      data_word_in    : in  std_logic_vector(127 downto 0);
      data_word_out   : out std_logic_vector(127 downto 0)                        
      );
end component simon_top;   

-- Registers to store data from HPS bus
signal r_key_0            : std_logic_vector (31 downto 0);
signal r_key_1            : std_logic_vector (31 downto 0);
signal r_key_2            : std_logic_vector (31 downto 0);
signal r_key_3            : std_logic_vector (31 downto 0);
signal r_data_0           : std_logic_vector (31 downto 0);
signal r_data_1           : std_logic_vector (31 downto 0);
signal r_data_2           : std_logic_vector (31 downto 0);
signal r_data_3           : std_logic_vector (31 downto 0);
signal r_decrypted_0      : std_logic_vector (31 downto 0);
signal r_decrypted_1      : std_logic_vector (31 downto 0);
signal r_decrypted_2      : std_logic_vector (31 downto 0);
signal r_decrypted_3      : std_logic_vector (31 downto 0);

--Signals to store data from simon cipher module
signal key_word_in        : std_logic_vector(127 downto 0);
signal data_word_in       : std_logic_vector(127 downto 0);
signal data_word_out      : std_logic_vector(127 downto 0);

begin

--Instantiate Simon Module
simon_top_insc : simon_top
port map(
      key_word_in     => key_word_in,
      data_word_in    => data_word_in,
      data_word_out   => data_word_out
);

-- Process to allow process running on A9 to read internal registers
read_proc : process (avs_s0_read, avs_s0_address) is
begin
    if avs_s0_read = '1' then
        case avs_s0_address is
            when b"0000" => -- 0
                avs_s0_readdata <= r_key_0;         -- Send key data for debug purposes
            when b"0001" => -- 1
                avs_s0_readdata <= r_key_1;         -- Send key data for debug purposes
            when b"0010" => -- 2
                avs_s0_readdata <= r_key_2;         -- Send key data for debug purposes
            when b"0011" => -- 3
                avs_s0_readdata <= r_key_3;         -- Send key data for debug purposes
            when b"0100" => -- 4
                avs_s0_readdata <= r_data_0;        -- Send cipher text for debug purposes
            when b"0101" => -- 5
                avs_s0_readdata <= r_data_1;        -- Send cipher text for debug purposes
            when b"0110" => -- 6
                avs_s0_readdata <= r_data_2;        -- Send cipher text for debug purposes
            when b"0111" => -- 7
                avs_s0_readdata <= r_data_3;        -- Send cipher text for debug purposes
            when b"1000" => -- 8
                avs_s0_readdata <= r_decrypted_0;   -- Send decrypted text back to A9
            when b"1001" => -- 9
                avs_s0_readdata <= r_decrypted_1;   -- Send decrypted text back to A9
            when b"1010" => -- 10
                avs_s0_readdata <= r_decrypted_2;   -- Send decrypted text back to A9         
            when b"1011" => -- 11
                avs_s0_readdata <= r_decrypted_3;   -- Send decrypted text back to A9                              
            when others =>
                null;
        end case;
    end if;
end process read_proc;

-- Process to allow process running A9 to write to registers
write_proc : process (clk, reset) is
begin
    if reset = '1' then
        -- Initialize Registers
        r_key_0         <= (others => '0');
        r_key_1         <= (others => '0');
        r_key_2         <= (others => '0');
        r_key_3         <= (others => '0');
        r_data_0        <= (others => '0');
        r_data_1        <= (others => '0');
        r_data_2        <= (others => '0');
        r_data_3        <= (others => '0');

    elsif rising_edge(clk) then
        if avs_s0_write = '1' then
            case avs_s0_address is
                when b"0000" => -- 0
                      r_key_0       <= avs_s0_writedata; -- Store first 32 bits of key 1
                when b"0001" => -- 1
                      r_key_1       <= avs_s0_writedata; -- Store last  32 bits of key 1
                when b"0010" => -- 2
                      r_key_2       <= avs_s0_writedata; -- Store first 32 bits of key 2
                when b"0011" => -- 3
                      r_key_3       <= avs_s0_writedata; -- Store last  32 bits of key 2
                when b"0100" => -- 4
                      r_data_0      <= avs_s0_writedata; -- Store first 32 bits of data 1
                when b"0101" => -- 5
                      r_data_1      <= avs_s0_writedata; -- Store last  32 bits of data 1
                when b"0110" => -- 6
                      r_data_2      <= avs_s0_writedata; -- Store first 32 bits of data 2
                when b"0111" => -- 7
                      r_data_3      <= avs_s0_writedata; -- Store last  32 bits of data 2
                when others =>
                    null;
            end case;
        end if;
    end if;
end process write_proc;

-- Combine keys and data for simon module
key_word_in  <= r_key_0  & r_key_1  & r_key_2  & r_key_3;
data_word_in <= r_data_0 & r_data_1 & r_data_2 & r_data_3;
 
-- Disassemble Decrypted data from simon module
r_decrypted_0 <= data_word_out (127 downto 96);
r_decrypted_1 <= data_word_out (95 downto 64);
r_decrypted_2 <= data_word_out (63 downto 32);
r_decrypted_3 <= data_word_out (31 downto 0);


end architecture rtl;

