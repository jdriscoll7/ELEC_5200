-- File: register_file.vhd
--
-- Implements a 2-port reading and 1-port writing 
-- register file for use in the CPU.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-- Register file contains:
--     - 2 read input/output ports
--     - 1 write address port
--     - 1 data input port
--     - 1 write enable port
--
entity register_file is

    generic (REGISTER_SIZE  : integer := 16;
             ADDRESS_BITS   : integer := 4);
             
    port    (read_address_1 : in  std_logic_vector((ADDRESS_BITS - 1)  downto 0);
             read_address_2 : in  std_logic_vector((ADDRESS_BITS - 1)  downto 0);
             write_address  : in  std_logic_vector((ADDRESS_BITS - 1)  downto 0);
             data_in        : in  std_logic_vector((REGISTER_SIZE - 1) downto 0);
             write_enable   : in  std_logic;
             data_out_1     : out std_logic_vector((REGISTER_SIZE - 1) downto 0);
             data_out_2     : out std_logic_vector((REGISTER_SIZE - 1) downto 0);
             clock          : in  std_logic);
             
end register_file;


architecture behavioral of register_file is

    -- Types for internal representation of register data.
    subtype register_t      is std_logic_vector((REGISTER_SIZE - 1) downto 0);
    type    register_file_t is array(((2**ADDRESS_BITS) - 1) downto 0) of register_t;
    
    -- Register file storage as a signal.
    signal register_file_storage : register_file_t := (others => (others => '0'));
    
begin

    -- Handle register writes.
    process(clock)
    begin
        
        if (write_enable = '1' and falling_edge(clock)) then
        
            register_file_storage(to_integer(unsigned(write_address))) <= data_in;
            
        end if;
        
    end process;
    
    -- Constantly output read registers on the two output ports.
    data_out_1 <= register_file_storage(to_integer(unsigned(read_address_1)));
    data_out_2 <= register_file_storage(to_integer(unsigned(read_address_2)));

end behavioral;
