-- File: instruction_memory.vhd
-- 
-- Implements an instruction memory for the CPU.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction_memory_program.all;


-- Memory interface.
entity instruction_memory is

    port    (read_address  : in  std_logic_vector((ADDRESS_BITS - 1) downto 0);
             data_out      : out std_logic_vector((WORD_SIZE - 1) downto 0));

end instruction_memory;
             

-- Register implementation. 
architecture behavioral of instruction_memory is
    
    -- Instruction memory as a signal.
    signal instruction_memory_storage : instruction_memory_t := main_program;
    
begin

    data_out <= instruction_memory_storage(to_integer(unsigned(read_address)));

end behavioral;
