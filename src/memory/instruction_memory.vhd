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

    constant main_program : instruction_memory_t := ("0000000000001011",
    "0001000110101100",
    "0001000110001110",
    "0010010000011011",
    "0100000000011011",
    "0100010000000110",
    "0100010000011101",
    "0001000101000000",
    "0011001000010000",
    "0011000000010010",
    "0000000100000111",
    "0000000100111001",
    "0011001000001011",
    "0100000110101011",
    "0011010000000010",
    "1110000000001011",
    "0000000100101011",
    "0000110001001010",
    "0000000011101011",
    "0000110001001010",
    "0000000110101011",
    "0000110001001010",
    "0000000100111011",
    "0000110001001010",
    "0000000001111011",
    "0000110001001010",
    "0000000000001011",
    "0000110001001010",
    "0000000100111011",
    "0000110001001010",
    "0000000100101011",
    "0000110001001010",
    "0000000110101011",
    "0000110001001010",
    "0000000000001011",
    "0000110001001010",
    "0000000110101011",
    "0000110001001010",
    "0000000100111011",
    "0000110001001010",
    "0000000001111011",
    "0000110001001010",
    "0000000010001011",
    "0000110001001010",
    "0000000011011011",
    "0000110001001010",
    "0000000001101011",
    "0000110001001010",
    "0000001111001001",
    "0001111000000011",
    "0000111100001000",
                                                     others => (others => '0'));

    -- Instruction memory as a signal.
    signal internal_storage : instruction_memory_t := main_program;

begin

    data_out <= internal_storage(to_integer(unsigned(read_address)));

end behavioral;
