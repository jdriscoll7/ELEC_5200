library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package instruction_memory_program is

    -- Constants related to memory size
    constant WORD_SIZE      : integer := 16;
    constant ADDRESS_BITS   : integer := 10;

    -- Types for internal representation of memory.
    subtype word_t               is std_logic_vector((WORD_SIZE - 1) downto 0);
    type    instruction_memory_t is array(((2**ADDRESS_BITS) - 1) downto 0) of word_t;

    constant main_program : instruction_memory_t :=
    ("0000" & "0000" & "0000" & "1011",
     "0001" & "0000" & "0001" & "1100",
     "0010" & "0000" & "0010" & "1011",
     "0011" & "0000" & "0011" & "1100",
     "0100" & "0000" & "0100" & "1011",
     "0101" & "0000" & "0101" & "1100",
     "0110" & "0000" & "0110" & "1011",
     "0111" & "0000" & "0111" & "1100",
     "1000" & "0000" & "1000" & "1011",
     "1001" & "0000" & "1001" & "1100",
     "1010" & "0000" & "1010" & "1011",
     "1011" & "0000" & "1011" & "1100",
     "1100" & "0000" & "1100" & "1011",
     "1101" & "0000" & "1101" & "1100",
     "1110" & "0000" & "1110" & "1011",
     "1111" & "0000" & "1111" & "1100",
     others => "0000000000000000");

end package instruction_memory_program;