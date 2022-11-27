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
--                Both 128 and 192 bit key lengths are supported.
--
--        Input:  128/192 bit keys supplied in 32 bit segments
--                128 bit data supplied in 32 bit segments
--                Encryption/Decryption flag
--                Key length flag
--
--       Output:  128 bit encrypted/decrypted data supplied in 32 bit segments
--                Flag to indicate data ready
--
--    Algorithm:  This code optimized for low area usuage, which results in 
--                slower processing time. This is achieved by only generating
--                one component and re-using it iteratively.
--
----------------------------------------------------------------------------------------------------------

--Import libaries
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

  -- Declare z value for 128/192 key length
  constant const_z_128       : std_logic_vector(67 downto 0) := x"17369f885192c0ef5";
  constant const_z_192       : std_logic_vector(67 downto 0) := x"2fc2ce51207a635db";

  -- Declare array structure to store keys
  type array_keys is array (68 downto 0) of std_logic_vector(63 downto 0);

  -- Signals for importing keys process
  signal import_key_0        : std_logic_vector(63 downto 0);
  signal import_key_1        : std_logic_vector(63 downto 0);
  signal import_key_2        : std_logic_vector(63 downto 0);
  signal import_keys_fsm     : integer;

  -- Signals for importing data process
  signal imported_data_0     : std_logic_vector(63 downto 0);
  signal imported_data_1     : std_logic_vector(63 downto 0);
  signal import_data_fsm     : integer;

  -- Signals for generating keys process
  signal expanded_keys       : array_keys;
  signal shifted_z           : std_logic_vector(67 downto 0);  
  signal generate_keys_count : integer;
  signal generate_keys_fsm   : integer;

  -- Signals for encryption/decryption process
  signal processing_data_0   : std_logic_vector(63 downto 0);
  signal processing_data_1   : std_logic_vector(63 downto 0);
  signal enc_dec_count       : integer;
  signal enc_dec_fsm         : integer;

  -- Signals for exporting data process
  signal export_data_fsm     : integer;

  -- Declare subkey generation component
  component simon_subkey_calc is
    port(
        sub_key_in_0         : in  std_logic_vector(63 downto 0);
        sub_key_in_1         : in  std_logic_vector(63 downto 0);
        z_in                 : in  std_logic_vector(67 downto 0);
        sub_key_out          : out std_logic_vector(63 downto 0);
        z_out                : out std_logic_vector(67 downto 0)
        );
  end component simon_subkey_calc;

  -- Signals for subkey generation component
  signal sub_key_in_0        : std_logic_vector(63 downto 0);
  signal sub_key_in_1        : std_logic_vector(63 downto 0);
  signal z_in                : std_logic_vector(67 downto 0);
  signal sub_key_out         : std_logic_vector(63 downto 0);
  signal z_out               : std_logic_vector(67 downto 0);

  -- Declare encryption/decryption component
  component simon_enc_dec is
    port(
        expanded_keys_in     : in  std_logic_vector(63 downto 0);
        data_in_0            : in  std_logic_vector(63 downto 0);
        data_in_1            : in  std_logic_vector(63 downto 0);
        data_out             : out std_logic_vector(63 downto 0)
        );
  end component simon_enc_dec;

  -- Signals for encryption/decryption component
  signal expanded_keys_in    : std_logic_vector(63 downto 0);
  signal data_in_0           : std_logic_vector(63 downto 0);
  signal data_in_1           : std_logic_vector(63 downto 0);
  signal data_out            : std_logic_vector(63 downto 0);

begin

  -- Map components to signals
  simon_subkey_calc_insc : simon_subkey_calc
  port map(
          sub_key_in_0  => sub_key_in_0,
          sub_key_in_1  => sub_key_in_1,
          z_in          => z_in,
          sub_key_out   => sub_key_out,
          z_out         => z_out
          );

  simon_enc_dec_insc : simon_enc_dec
  port map(
          expanded_keys_in  => expanded_keys_in,
          data_in_0         => data_in_0,
          data_in_1         => data_in_1,
          data_out          => data_out
          );

  -- Process to load keys to hardware
  load_keys_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            import_keys_fsm <= 0;               -- Reset State machine   
            import_key_0    <= (others => '0'); -- Reset Keys signals 
            import_key_1    <= (others => '0'); 
            import_key_2    <= (others => '0'); 
        else
          -- Wait until key is ready
          if key_valid = '1' then
            case import_keys_fsm is
              when 0 =>
                    -- Load MSB 32 bits of first key
                    import_key_2 (63 downto 32)  <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;
  
              when 1 =>
                    -- Load LSB 32 bits of first key
                    import_key_2 (31 downto 0)   <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;
                    
              when 2 =>
                    -- Load MSB 32 bits of second key
                    import_key_1 (63 downto 32)  <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;
  
              when 3 =>
                    -- Load LSB 32 bit of second key
                    import_key_1 (31 downto 0)   <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;
              when 4 =>
                    -- Load MSB 32 bit of third key (Only 192 bits Key)
                    import_key_0 (63 downto 32)  <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;

              when 5 =>
                    -- Load LSB 32 bit of third key (Only 192 bits Key)
                    import_key_0 (31 downto 0)   <= key_word_in;
                    import_keys_fsm              <= import_keys_fsm + 1;
  
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
            imported_data_0  <= (others => '0');  -- Reset Data Signals
            imported_data_1  <= (others => '0'); 
            import_data_fsm <= 0;                 -- Reset State Machine
        else
          -- Wait until data is ready
          if data_valid = '1' then
            case import_data_fsm is

              when 0 =>
                    -- Load MSB 32 bit first block of data
                    imported_data_0  (63 downto 32)  <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when 1 =>
                    -- Load LSB 32 bit first block of data
                    imported_data_0  (31 downto 0)   <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when 2 =>
                    -- Load MSB 32 bit second block of data
                    imported_data_1  (63 downto 32)  <= data_word_in;
                    import_data_fsm                  <= import_data_fsm + 1;

              when 3 =>
                    -- Load LSB 32 bit second block of data
                    imported_data_1  (31 downto 0)   <= data_word_in; 
                    import_data_fsm                  <= import_data_fsm + 1;

              when others =>
                  null;
            end case;
          end if;
        end if;
    end if;
  end process load_data_proc;

  -- Process to generate subkeys
  generate_keys_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
          expanded_keys       <=  (others => (others=>'0')); -- Reset key array
          shifted_z           <=  (others => '0'); 
          generate_keys_count <= 0;
          generate_keys_fsm   <= 0;                          -- Reset state machine
        else
          -- Check if keys are imported (128 or 192 bits)
          if (key_length = "00" and import_keys_fsm = 4) or (key_length = "01" and import_keys_fsm = 6) then
            case generate_keys_fsm is

              when 0 => 
                -- Import keys to array
                if key_length = "00" then
                  -- 128 bits key (Import 2 32-bit keys)
                  expanded_keys(0)     <= import_key_1;
                  expanded_keys(1)     <= import_key_2;
                  shifted_z            <= const_z_128;
                else
                  -- 192 bits key (Import 3 32-bit keys)
                  expanded_keys(0)     <= import_key_0;
                  expanded_keys(1)     <= import_key_1;
                  expanded_keys(2)     <= import_key_2;
                  shifted_z            <= const_z_192;
                end if;          
                generate_keys_fsm      <= generate_keys_fsm + 1;      

              when 1 => 
                if key_length = "00" then
                  -- 128 bits key (Generate new key from first and second key)
                  sub_key_in_0         <= expanded_keys(generate_keys_count + 1);
                  sub_key_in_1         <= expanded_keys(generate_keys_count);
                else
                  -- 192 bits key (Generate new key from first and third key)
                  sub_key_in_0         <= expanded_keys(generate_keys_count + 2);
                  sub_key_in_1         <= expanded_keys(generate_keys_count);
                end if;
                z_in                   <= shifted_z; -- Load z value
                generate_keys_fsm      <= generate_keys_fsm + 1;

              when 2 =>
                -- Write new key to array
                if key_length = "00" then
                  expanded_keys(generate_keys_count + 2)  <= sub_key_out;
                else
                  expanded_keys(generate_keys_count + 3)  <= sub_key_out;
                end if;
                -- Write shifted z value to signal
                shifted_z              <= z_out;
                -- Increment generated keys count
                generate_keys_count    <= generate_keys_count + 1;
                -- Check if all keys are generated
                if generate_keys_count < 65 then
                  generate_keys_fsm    <= 1; -- Generate more keys
                else
                  generate_keys_fsm    <= 3; -- Stop generating
                end if;

              when others =>
                null;
            end case;
          end if;
        end if;
    end if;
  end process generate_keys_proc;

  -- Process to perform encryption/decryption
  enc_dec_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            enc_dec_fsm       <= 0; -- Reset state machine
            enc_dec_count     <= 0; -- Reset rounds count
            processing_data_0 <= (others => '0');
            processing_data_1 <= (others => '0');
        else
          -- Check if keys generation is completed
          if generate_keys_fsm = 3 then
            case enc_dec_fsm is

              when 0 => 
                  if encryption = '0' then
                    -- Load data to be decrypted (Flip blocks)
                    processing_data_0    <= imported_data_1;
                    processing_data_1    <= imported_data_0;
                  else
                    -- Load data to be encrypted
                    processing_data_0    <= imported_data_0;
                    processing_data_1    <= imported_data_1;
                  end if;
                  enc_dec_fsm            <= enc_dec_fsm + 1; 

              when 1 =>
                  -- Connect signals to component
                  data_in_0              <= processing_data_1;
                  data_in_1              <= processing_data_0;
                  if encryption = '0' then
                    -- For decryption, keys are used backwards
                    if (key_length = "00") then
                      -- Select last key based on key length
                      expanded_keys_in   <= expanded_keys(67-enc_dec_count);
                    else 
                      expanded_keys_in   <= expanded_keys(68-enc_dec_count);
                    end if;
                  else
                    -- For encryption, keys are used forwards
                    expanded_keys_in     <= expanded_keys(enc_dec_count);
                  end if;
                  enc_dec_fsm            <= enc_dec_fsm + 1;     

              when 2 => 
                -- Write resulting data to signals
                processing_data_0        <= data_out;
                processing_data_1        <= processing_data_0;
                -- Increment rounds counter
                enc_dec_count            <= enc_dec_count + 1;
                -- Check if rounds are completed
                if (enc_dec_count < 67 and key_length = "00") or (enc_dec_count < 68 and key_length = "01") then
                  enc_dec_fsm            <= 1; -- More rounds
                else
                  enc_dec_fsm            <= enc_dec_fsm + 1; -- Stop rounds
                end if;

              when 3 =>
                if encryption = '0' then
                  -- Flip blocks for decryption
                  processing_data_0      <= processing_data_1;
                  processing_data_1      <= processing_data_0;
                end if;
                enc_dec_fsm              <= enc_dec_fsm + 1;

              when others =>
                null;
            end case;
          end if;
        end if;
    end if;
  end process enc_dec_proc;

 -- Process to export data
  export_data_proc : process (clk)
  begin
    if rising_edge(clk) then
        if reset_n = '0' then
            export_data_fsm <= 0; -- Reset State Machine
            data_word_out   <= (others => '0');
            data_ready      <= '0';
        else
          if enc_dec_fsm = 4 then -- Check if data is fully encrypted/decrypted
            case export_data_fsm is

              when 0 =>
                  data_ready          <= '1'; -- Indicate data is ready to be exported
                  -- Load MSB 32 bit first block of data
                  data_word_out       <= processing_data_0(63 downto 32);
                  export_data_fsm     <= export_data_fsm + 1;

              when 1 =>
                  -- Load LSB 32 bit first block of data
                  data_word_out       <= processing_data_0(31 downto 0);
                  export_data_fsm     <= export_data_fsm + 1;

              when 2 =>
                  -- Load MSB 32 bit second block of data
                  data_word_out       <= processing_data_1(63 downto 32);
                  export_data_fsm     <= export_data_fsm + 1;

              when 3 =>
                  -- Load LSB 32 bit second block of data
                  data_word_out       <= processing_data_1(31 downto 0);
                  export_data_fsm     <= export_data_fsm + 1;

              when others =>
                  null;
            end case;
          end if;
        end if;
    end if;
  end process export_data_proc;

end architecture struct;


