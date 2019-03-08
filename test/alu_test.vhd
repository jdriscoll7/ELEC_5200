library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

-- Import custom types.
library work;
use work.types.all;
use work.all;

entity alu_test_bench is 
end alu_test_bench;


architecture test of alu_test_bench is

    -- Signals for UUT instantiation.
    signal alu_op    : alu_op_t := alu_add;
    signal alu_in1   : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_in2   : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_out   : std_logic_vector(15 downto 0);
    signal zero_flag : std_logic;
    
    -- Signal used for comparing correct ALU output.
    signal expected_output : std_logic_vector(15 downto 0);
    
    -- Constant for comparison to output to all zero's.
    constant zeros_compare : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Constant array of size 9 for some test values.
    subtype test_pattern_t is integer range -16384 to 16383;
    type test_pattern_array_t is array(8 downto 0) of test_pattern_t;
    constant input_2_values : test_pattern_array_t := (-1000, 
                                                       -100,
                                                       -15,
                                                       -1,
                                                       0,
                                                       1,
                                                       15,
                                                       100,
                                                       1000);

begin

    -- Instantiate ALU for testing.
    UUT : entity work.alu
    
        port map (alu_op    => alu_op,
                  alu_in1   => alu_in1,
                  alu_in2   => alu_in2,
                  alu_out   => alu_out,
                  zero_flag => zero_flag);

    -- Actual testing
    process
    
    begin
        -- Test all values for input_1, and selected values for input_2.
        for input_1 in (-2**14) to ((2**14) - 1) loop
            for input_2 in (-2**14) to ((2**14) - 1) loop
            
            -- Check correctness of ALU output for each operation.
            expected_output  <= std_logic_vector(to_signed(input_1 + input_2, 16));
            
            -- Set ALU inputs.
            alu_in1 <= std_logic_vector(to_signed(input_1, 16));
            alu_in2 <= std_logic_vector(to_signed(input_2, 16));
            
            
            -- First alu op.
            alu_op <= alu_add;
            wait for 20 ns;
            
            
            -- Addition with zero check.
            assert(alu_out = expected_output)
                report "Addition failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "Addition zero-check failed."
                severity FAILURE;
            
            
            -- Next alu op type.
            alu_op <= alu_sub;
            expected_output  <= std_logic_vector(to_signed(input_1 - input_2, 16));
            wait for 20 ns;
            
            -- Subtraction with zero check.
            assert(alu_out = expected_output)
                report "Subtraction failed."
                severity FAILURE;

            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "Subtraction zero-check failed."
                severity FAILURE;
            
            
            -- Next alu op type.
            alu_op <= alu_and;
            expected_output  <= std_logic_vector(to_signed(input_1, 16)) 
                            and std_logic_vector(to_signed(input_2, 16));
            wait for 20 ns;
            
            -- And with zero check.
            assert(alu_out = expected_output)
                report "Logical AND failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "AND zero-check failed."
                severity FAILURE;
            
            
            -- Next alu op type.
            alu_op <= alu_or;
            expected_output   <= std_logic_vector(to_signed(input_1, 16)) 
                             or  std_logic_vector(to_signed(input_2, 16));
            wait for 20 ns;
            
            -- Or with zero check.
            assert(alu_out = expected_output)
                report "Logical OR failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "Or zero-check failed."
                severity FAILURE;
            
            
            -- Next alu op type.
            alu_op <= alu_not;
            expected_output  <= not std_logic_vector(to_signed(input_1, 16)); 
            wait for 20 ns;
            
            -- Not with zero check.
            assert(alu_out = expected_output)
                report "Logical NOT failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "NOT zero-check failed."
                severity FAILURE;
            
            
            -- Next alu op type.
            alu_op <= alu_shift_right;
            expected_output   <= std_logic_vector(shift_right(to_signed(input_1, 16), to_integer(to_signed(input_2, 16))));
            wait for 20 ns;
            
            -- Shift right with zero check.
            assert(alu_out = expected_output)
                report "Shift right failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "Shift right zero-check failed."
                severity FAILURE;
                
            
            -- Next alu op type.
            alu_op <= alu_shift_left;
            expected_output   <= std_logic_vector(shift_left(to_signed(input_1, 16), to_integer(to_signed(input_2, 16))));
            wait for 20 ns;
            
            -- Shift left with zero check.
            assert(alu_out = expected_output)
                report "Shift left failed."
                severity FAILURE;
            
            assert((zero_flag = '0') xor (zeros_compare = expected_output))
                report "Shift left zero-check failed."
                severity FAILURE;
            
            end loop;
        end loop;
    
    wait;
    
    end process;
                  
end test;