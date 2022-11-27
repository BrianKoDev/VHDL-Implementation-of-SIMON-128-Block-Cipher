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
--                It uses 2 components - encryption/decryption and subkey generation.
--                Only 128 bit key lengths are supported.
--
--        Input:  128 keys supplied in 32 bit segments
--                128 bit data supplied in 32 bit segments
--                Encryption/Decryption flag
--                Key length flag
--
--       Output:  128 bit encrypted/decrypted data supplied in 32 bit segments
--                Flag to indicate data ready
--
--    Algorithm:  This code optimized for high performance, which results in 
--                large area usuage. This is achieved by only generating
--                all required components and a combinational logic approach.
--                Sub-key generation / encryption / decryption are all computed in one clock cycle.
--
----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--Declare entity
entity simon_top is
  port(
      clk             : in  std_logic;
      reset_n         : in  std_logic;
      encryption      : in  std_logic;                    
      key_length      : in  std_logic_vector(1 downto 0); 
      key_valid       : in  std_logic;                    
      key_word_in     : in  std_logic_vector(31 downto 0);
      data_valid      : in  std_logic;                    
      data_word_in    : in  std_logic_vector(31 downto 0);
      data_word_out   : out std_logic_vector(31 downto 0);
      data_ready      : out std_logic                     
      );
end entity simon_top;

architecture struct of simon_top is

  -- z value for 128 bit key length
  constant const_z           : std_logic_vector(67 downto 0) := x"17369f885192c0ef5";

  -- Signal to store generated subkeys
  type array_keys is array (67 downto 0) of std_logic_vector(63 downto 0);
  signal expanded_keys       : array_keys;

  -- Signal to store z value for generating subkeys
  type array_z is array    (67 downto 0) of std_logic_vector(67 downto 0);
  signal shifted_z           : array_z;  

  -- Signals to store processed data
  type array_data is array (69 downto 0) of std_logic_vector(63 downto 0);
  signal encrypted_data      : array_data;
  signal decrypted_data      : array_data;

  -- Signal to operate state machines
  signal import_keys_fsm     : integer;
  signal import_data_fsm     : integer;
  signal export_data_fsm     : integer;

  -- Declare subkey generation component
  component simon_subkey_calc is
    port(
        sub_key_in_0         : in   std_logic_vector(63 downto 0);
        sub_key_in_1         : in   std_logic_vector(63 downto 0);
        z_in                 : in   std_logic_vector(67 downto 0);
        sub_key_out          : out  std_logic_vector(63 downto 0);
        z_out                : out  std_logic_vector(67 downto 0)
        );
  end component simon_subkey_calc;

  -- Declare encryption/decryption component
  component simon_enc_dec is
    port(
        expanded_keys_in     : in   std_logic_vector(63 downto 0);
        data_in_0            : in   std_logic_vector(63 downto 0);
        data_in_1            : in   std_logic_vector(63 downto 0);
        data_out             : out  std_logic_vector(63 downto 0)
        );
  end component simon_enc_dec;

begin

  -- Generate and connect component for subkeys
  sub_key_generate : for i in 0 to 65 generate
    simon_subkey_calc_insc : simon_subkey_calc
    port map(
            sub_key_in_0  => expanded_keys(i+1),    -- Two subkeys is required to generate next key
            sub_key_in_1  => expanded_keys(i),      -- Two subkeys is required to generate next key
            z_in          => shifted_z(i),          -- Previous z value required to generated next key
            sub_key_out   => expanded_keys(i+2),    -- Next key generated output
            z_out         => shifted_z(i+1)         -- Shifted z value output
            );
  end generate; 

  -- Generate and connect components for encryption
  simon_enc_generate : for i in 0 to 67 generate
    simon_enc_insc : simon_enc_dec
    port map(
            expanded_keys_in  => expanded_keys  (i),   -- Load sub-key
            data_in_0         => encrypted_data (i),   -- Load first block of data
            data_in_1         => encrypted_data (i+1), -- Load second block of data
            data_out          => encrypted_data (i+2)  -- Write new block to array
            );
  end generate; 

  -- Generate and connect components for decryption
  simon_dec_generate : for i in 0 to 67 generate
    simon_dec_insc : simon_enc_dec
    port map(
            expanded_keys_in  => expanded_keys  (67-i), -- Load sub-key from last
            data_in_0         => decrypted_data (i),    -- Load first block of data
            data_in_1         => decrypted_data (i+1),  -- Load second block of data
            data_out          => decrypted_data (i+2)   -- Write new block to array
            );
  end generate; 

  -- Process to load keys to hardware
  load_keys_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            import_keys_fsm <= 0;       -- Reset State machine
            shifted_z(0)    <= const_z; -- Load first value of z from constant declaration
        else
          -- Wait until key is ready
          if key_valid = '1' then
            case import_keys_fsm is
              when 0 =>
                    -- Load last 32 bits of second key
                    expanded_keys(1) (63 downto 32) <= key_word_in;
                    import_keys_fsm                 <= import_keys_fsm + 1;
  
              when 1 =>
                    -- Load first 32 bits of second key
                    expanded_keys(1) (31 downto 0)  <= key_word_in;
                    import_keys_fsm                 <= import_keys_fsm + 1;
                    
              when 2 =>
                    -- Load last 32 bit of first key
                    expanded_keys(0) (63 downto 32) <= key_word_in;
                    import_keys_fsm                 <= import_keys_fsm + 1;
  
              when 3 =>
                    -- Load first 32 bit of first key
                    expanded_keys(0) (31 downto 0)  <= key_word_in;
                    import_keys_fsm                 <= import_keys_fsm + 1;
  
              when others =>
                  null;
            end case;
          end if;
        end if;
    end if;
  end process load_keys_proc;


  -- Process to load data to hardware
  load_data_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            import_data_fsm <= 0; -- Reset State Machine
        else
          -- Wait until data is ready
          if data_valid = '1' then
            case import_data_fsm is

              when 0 =>
                    -- Load MSB 32 bit of first block
                    encrypted_data(1) (63 downto 32) <= data_word_in;
                    decrypted_data(0) (63 downto 32) <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when 1 =>
                    -- Load LSB 32 bit of first block
                    encrypted_data(1) (31 downto 0)  <= data_word_in;
                    decrypted_data(0) (31 downto 0)  <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when 2 =>
                    -- Load MSB 32 bit of second block
                    encrypted_data(0) (63 downto 32) <= data_word_in;
                    decrypted_data(1) (63 downto 32) <= data_word_in;          
                    import_data_fsm                  <= import_data_fsm + 1;

              when 3 =>
                    -- Load LSB 32 bit of second block
                    encrypted_data(0) (31 downto 0)  <= data_word_in;
                    decrypted_data(1) (31 downto 0)  <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when others =>
                  null;
            end case;
          end if;
        end if;
    end if;
  end process load_data_proc;

  -- Process to export data to bus
  export_data_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            export_data_fsm <= 0; -- Reset State Machine
            data_word_out   <= (others => '0');
            data_ready      <= '0';
        else
          if import_data_fsm = 4 then -- Check if data is fully imported
            case export_data_fsm is
              when 0 =>
                  data_ready          <= '1'; -- Indicate data is ready to be exported
                  if encryption = '1' then
                    -- Export Cipher Text
                    data_word_out     <= encrypted_data(69) (63 downto 32);
                  else
                    -- Export Decrypted Text
                    data_word_out     <= decrypted_data(68) (63 downto 32);
                  end if;  
                  export_data_fsm     <= export_data_fsm + 1;

              when 1 =>
                  if encryption = '1' then
                    -- Export Cipher Text
                    data_word_out     <= encrypted_data(69) (31 downto 0);
                  else
                    -- Export Decrypted Text
                    data_word_out     <= decrypted_data(68) (31 downto 0);
                  end if;  
                  export_data_fsm     <= export_data_fsm + 1;

              when 2 =>
                  if encryption = '1' then
                    -- Export Cipher Text
                    data_word_out     <= encrypted_data(68) (63 downto 32);
                  else
                    -- Export Decrypted Text
                    data_word_out     <= decrypted_data(69) (63 downto 32);
                  end if;  
                  export_data_fsm     <= export_data_fsm + 1;

              when 3 =>
                  if encryption = '1' then
                    -- Export Cipher Text
                    data_word_out     <= encrypted_data(68) (31 downto 0);
                  else
                    -- Export Decrypted Text
                    data_word_out     <= decrypted_data(69) (31 downto 0);
                  end if;  
                  export_data_fsm     <= export_data_fsm + 1;

              when others =>
                  null;
            end case;
          end if;
        end if;
    end if;
  end process export_data_proc;


end architecture struct;


