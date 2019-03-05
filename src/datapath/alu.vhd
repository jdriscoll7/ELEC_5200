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
    generic (IO_WIDTH : integer := 15);

    port    (alu_op  : in  alu_op_t;
             alu_in1 : in  std_logic_vector((IO_WIDTH - 1) downto 0);
             alu_in2 : in  std_logic_vector((IO_WIDTH - 1) downto 0);
             alu_out : out std_logic_vector((IO_WIDTH - 1) downto 0);
             zero    : out std_logic);

end alu;


architecture behavioral of alu is

    -- Store results and assign after process for neatness.
    signal alu_result : std_logic_vector((IO_WIDTH - 1) downto 0);
    signal zero_flag  : std_logic;

begin

    process(alu_op, alu_in1, alu_in2)
    
        -- Put inputs in integer variable for easier manipulation/readability.
        -- Only used in add and sub.
        variable alu_input_1 : integer;
        variable alu_input_2 : integer;
    
    begin
    
        case alu_op is
        
            when alu_add =>
                
                -- Cast the ALU inputs.
                alu_input_1 := to_integer(signed(alu_in1));
                alu_input_2 := to_integer(signed(alu_in2));
                alu_result  <= std_logic_vector(to_signed(alu_input_1 + alu_input_2, IO_WIDTH));
                
            when alu_sub =>
            
                -- Cast the ALU inputs.
                alu_input_1 := to_integer(signed(alu_in1));
                alu_input_2 := to_integer(signed(alu_in2));
                alu_result <= std_logic_vector(to_signed(alu_input_1 - alu_input_2, IO_WIDTH));
                
            when alu_and =>
                
                -- And the two inputs.
                alu_result <= alu_in1 and alu_in2;
                
            when alu_or =>
                
                -- Or the two inputs.
                alu_result <= alu_in1 or alu_in2;
                
            when alu_not =>
                
                -- Not just the first input.
                alu_result <= not alu_in1;
                
            when alu_shift_right =>
                
                -- Shift the first input to the right by the amount in the second input.
                alu_result <= std_logic_vector(shift_right(unsigned(alu_in1), to_integer(unsigned(alu_in2))));
                
            when alu_shift_left =>
                
                -- Shift the first input to the left by the amount in the second input.
                alu_result <= std_logic_vector(shift_left(unsigned(alu_in1), to_integer(unsigned(alu_in2))));
        
        end case;
        
        -- Set zero flag if needed.
        if (to_integer(unsigned(alu_result)) = 0) then
            
            zero_flag <= '1';
            
        else
            
            zero_flag <= '0';
            
        end if;
    
    end process;
    
    -- Set the ALU output and the zero flag accordingly.
    alu_out <= alu_result;
    zero    <= zero_flag;

end behavioral;