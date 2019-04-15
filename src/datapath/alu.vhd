-- File: alu.vhd
--
-- Implements an ALU for the CPU project.


-- Basic library includes.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Import custom types.
use work.types.all;


entity alu is

    -- This generic should not really be changed.
    generic (IO_WIDTH : integer := 16);

    port    (alu_op    : in  alu_op_t;
             alu_in_1  : in  std_logic_vector((IO_WIDTH - 1) downto 0);
             alu_in_2  : in  std_logic_vector((IO_WIDTH - 1) downto 0);
             alu_out   : out std_logic_vector((IO_WIDTH - 1) downto 0) := (others => '0');
             zero_flag : out std_logic := '0');

end alu;


architecture behavioral of alu is

    -- Store results and assign after process for neatness.
    signal alu_result : std_logic_vector((IO_WIDTH - 1) downto 0);
    
    -- 0 comparison value for ALU output.
    constant zero_compare : std_logic_vector((IO_WIDTH - 1) downto 0) := (others => '0');

begin

    process(alu_op, alu_in_1, alu_in_2)
    
        -- Put inputs in integer variable for easier manipulation/readability.
        -- Only used in add and sub.
        variable alu_input_1 : integer;
        variable alu_input_2 : integer;
    
    begin
    
        case alu_op is
        
            when alu_add =>
                
                -- Cast the ALU inputs.
                alu_input_1 := to_integer(signed(alu_in_1));
                alu_input_2 := to_integer(signed(alu_in_2));
                alu_result  <= std_logic_vector(to_signed(alu_input_1 + alu_input_2, IO_WIDTH));
                
            when alu_sub =>
            
                -- Cast the ALU inputs.
                alu_input_1 := to_integer(signed(alu_in_1));
                alu_input_2 := to_integer(signed(alu_in_2));
                alu_result  <= std_logic_vector(to_signed(alu_input_1 - alu_input_2, IO_WIDTH));
                
            when alu_and =>
                
                -- And the two inputs.
                alu_result <= alu_in_1 and alu_in_2;
                
            when alu_or =>
                
                -- Or the two inputs.
                alu_result <= alu_in_1 or alu_in_2;
                
            when alu_not =>
                
                -- Not just the first input.
                alu_result <= not alu_in_1;
                
            when alu_shift_right =>
                
                -- Shift the first input to the right by the amount in the second input.
                alu_result <= std_logic_vector(shift_right(unsigned(alu_in_1), to_integer(signed(alu_in_2))));
                
            when alu_shift_left =>
                
                -- Shift the first input to the left by the amount in the second input.
                alu_result <= std_logic_vector(shift_left(unsigned(alu_in_1), to_integer(signed(alu_in_2))));
        
        end case;
    
    end process;
    
    -- Set the ALU output.
    alu_out   <= alu_result;
    
    -- Set the zero flag.
    zero_flag <= '1' when (alu_result = zero_compare) else '0';

end behavioral;
