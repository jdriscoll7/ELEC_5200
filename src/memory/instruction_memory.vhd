-- File: instruction_memory.vhd
-- 
-- Implements an instruction memory for the CPU.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Memory interface.
entity instruction_memory is

    port    (read_address  : in  std_logic_vector(9 downto 0);
             data_out      : out std_logic_vector(15 downto 0));

end instruction_memory;
             

-- Register implementation. 
architecture behavioral of instruction_memory is
    
    -- Types for internal representation of memory.
    subtype word_t               is std_logic_vector(15 downto 0);
    type    instruction_memory_t is array(0 to 2**10 - 1) of word_t;

    constant main_program : instruction_memory_t := ("0000000000011011",
                                                     "0000000010101111",
                                                     "0001000011001011",
                                                     "0000000000010001",
                                                     "0010000001101011",
                                                     "0011000010001011",
                                                     "0010001000110101",
                                                     "0010001000100110",
                                                     "0011010101011100",
                                                     "0011001110001110",
                                                     "0010001000110100",
                                                     "0000000000100000",
                                                     "0000001100001001",
                                                     others => (others => '0'));

    -- Instruction memory as a signal.
    signal internal_storage : instruction_memory_t := main_program;

begin

    data_out <= internal_storage(to_integer(unsigned(read_address)));

end behavioral;
