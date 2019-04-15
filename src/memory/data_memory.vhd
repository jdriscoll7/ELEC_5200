-- File: data_memory.vhd
-- 
-- Implements a data memory for the CPU.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Memory interface.
entity data_memory is

    port    (read_address   : in  std_logic_vector(9 downto 0);
             data_out       : out std_logic_vector(15 downto 0);
             write_enable   : in  std_logic;
             write_data     : in  std_logic_vector(15 downto 0));

end data_memory;
             

-- Register implementation. 
architecture behavioral of data_memory is
    
    -- Types for internal representation of memory.
    subtype word_t        is std_logic_vector(15 downto 0);
    type    data_memory_t is array(((2**10) - 1) downto 0) of word_t;
    
    -- Data memory as a signal.
    signal data_memory_storage : data_memory_t := (others => (others => '0'));
    
begin



    data_out <= data_memory_storage(to_integer(unsigned(read_address)));

end behavioral;
