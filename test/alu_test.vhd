library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.all;


entity test_bench is 
end test_bench;



architecture test of test_bench is

    -- Signals for UUT instantiation.
    signal alu_op  : alu_op_t := add;
    signal alu_in1 : std_logic_vector((IO_WIDTH - 1) downto 0) := (others => '0');
    signal alu_in2 : std_logic_vector((IO_WIDTH - 1) downto 0) := (others => '0');
    signal alu_out : std_logic_vector((IO_WIDTH - 1) downto 0);
    signal zero    : std_logic;
    
    -- Constant array of size 9 for some test values.
    type test_pattern_t is integer range -16384 to 16383;
    constant input_2_values : array( downto 0) of test_pattern_t := (-1000, 
                                                                     -100,
                                                                     -15,
                                                                     -1,
                                                                     0,
                                                                     1,
                                                                     15,
                                                                     100,
                                                                     1000)

begin

    -- Instantiate ALU for testing.
    UUT : work.alu
    
        port map (alu_op  => alu_op,
                  alu_in1 => alu_in1,
                  alu_in2 => alu_in2,
                  alu_out => alu_out,
                  zero    => zero);

    -- Actual testing
    process
    
        variable add_compare   : std_logic_vector(15 downto 0);
        variable sub_compare   : std_logic_vector(15 downto 0);
        variable and_compare   : std_logic_vector(15 downto 0);
        variable or_compare    : std_logic_vector(15 downto 0);
        variable not_compare   : std_logic_vector(15 downto 0);
        variable sr_compare    : std_logic_vector(15 downto 0);
        variable sl_compare    : std_logic_vector(15 downto 0);
        variable zero_compare  : std_logic_vector(15 downto 0);
    
    begin
        -- Test all values for input_1, and selected values for input_2.
        for input_1 in (-2**14) to ((2**14) - 1) loop
            for input_2 in input_2_values loop
            
            -- Set ALU inputs.
            alu_in1 <= std_logic_vector(to_signed(input_1, 16));
            alu_in2 <= std_logic_vector(to_signed(input_2, 16));
            
            -- Check correctness of ALU output for each operation.
            add_compare  := std_logic_vector(to_signed(input_1 + input_2, 16));
            sub_compare  := std_logic_vector(to_signed(input_1 - input_2, 16));
            and_compare  := std_logic_vector(to_unsigned(input_1, 16)) 
                        and std_logic_vector(to_unsigned(input_1, 16));
            or_compare   := std_logic_vector(to_unsigned(input_1, 16)) 
                        or  std_logic_vector(to_unsigned(input_1, 16));
            not_compare  := not std_logic_vector(to_unsigned(input_1, 16)); 
            sr_compare   := std_logic_vector(shift_right(unsigned(input_1), to_integer(unsigned(input_2))));
            sl_compare   := std_logic_vector(shift_left(unsigned(input_1), to_integer(unsigned(input_2))));
            
            
            -- Addition.
            assert(alu_out = add_compare)
                report "Addition failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "Addition zero-check failed."
                severity FAILURE;
            
            
            
            -- Subtraction.
            assert(alu_out = sub_compare)
                report "Subtraction failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "Subtraction zero-check failed."
                severity FAILURE;
            
            
            
            -- And.
            assert(alu_out = and_compare)
                report "Logical AND failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "AND zero-check failed."
                severity FAILURE;
            
            
            
            -- Or.
            assert(alu_out = or_compare)
                report "Logical OR failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "Or zero-check failed."
                severity FAILURE;
            
            
            
            -- Not.
            assert(alu_out = not_compare)
                report "Logical NOT failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "NOT zero-check failed."
                severity FAILURE;
            
            
            
            -- Shift right.
            assert(alu_out = sr_compare)
                report "Shift right failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "Shift right zero-check failed."
                severity FAILURE;
                
                
            
            -- Shift left.
            assert(alu_out = sl_compare)
                report "Shift left failed."
                severity FAILURE;
            
            -- Zero check.
            assert(zero_compare = (0 = to_integer(unsigned(add_compare))))
                report "Shift left zero-check failed."
                severity FAILURE;
                
                
            
            end loop;
        end loop;
    
    end process;
                  
end test;