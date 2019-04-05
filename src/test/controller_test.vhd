-- File: controller_test.vhd
--
-- Testbench for controller component.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


library work;
use work.all;
use work.types.all;
use work.control_unit_package.all;


entity controller_test_bench is 
end controller_test_bench;


architecture test of controller_test_bench is

    -- This table is based on the tables created for the second project report.
    constant ADD_SIGNALS    : std_logic_vector(12 downto 0) := "0000000000100";
    constant SUB_SIGNALS    : std_logic_vector(12 downto 0) := "0010000000100";
    constant STR_SIGNALS    : std_logic_vector(12 downto 0) := "0000000001000";
    constant LDR_SIGNALS    : std_logic_vector(12 downto 0) := "0000000010100";
    constant AND_SIGNALS    : std_logic_vector(12 downto 0) := "0100000000100";
    constant OR_SIGNALS     : std_logic_vector(12 downto 0) := "0110000000100";
    constant NOT_SIGNALS    : std_logic_vector(12 downto 0) := "1000000000100";
    constant CMP_SIGNALS    : std_logic_vector(12 downto 0) := "0011000000000";
    constant BR_SIGNALS     : std_logic_vector(12 downto 0) := "0000010000000";
    constant B_SIGNALS      : std_logic_vector(12 downto 0) := "0000000000000";
    constant BL_SIGNALS     : std_logic_vector(12 downto 0) := "0000000000110";
    constant LOADIL_SIGNALS : std_logic_vector(12 downto 0) := "0000001000100";
    constant LOADIU_SIGNALS : std_logic_vector(12 downto 0) := "0000001100100";
    constant ADDI_SIGNALS   : std_logic_vector(12 downto 0) := "0000100000100";
    constant LSR_SIGNALS    : std_logic_vector(12 downto 0) := "1010100000100";
    constant LSL_SIGNALS    : std_logic_vector(12 downto 0) := "1100100000100";
 
    -- Signals used for testing the control unit under test.
    signal test_op_code             : op_code_t     := add_op;
    signal test_in_condition        : condition_t   := no_condition;
    signal test_pc_condition        : condition_t   := no_condition;
    signal test_clock               : std_logic     := '0';
    signal test_control_signals     : control_signal_bus_t;
    
begin

    -- Instantiate the controller.
    UUT : entity work.control_unit 
        port map(op_code            => test_op_code,
                 in_condition       => test_in_condition,
                 pc_condition       => test_pc_condition,
                 clock              => test_clock,
                 control_signals    => test_control_signals);
            
    -- 200 MHz clock.
    test_clock <= not test_clock after 5 ns;
            
    process
    
        -- Variable used to determine if branch should be taken for a given instruction.
        variable branch_taken : std_logic_vector((ADD_SIGNALS'length - 1) downto 0) := (others => '0');
    
    begin
    
        -- Iterate through all op codes.
        for op_code in op_code_t range add_op to lsl_op loop
        
            -- Set new op code.
            test_op_code <= op_code;
            
            -- If instruction is a branch, then each condition must be done for each possible condition state.
            if ((op_code = br_op) or (op_code = b_op) or (op_code = bl_op)) then
            
                -- Iterate over all possible branch conditions in instruction.
                for i_condition in condition_t range no_condition to greater_than loop
                
                    -- Iterate over all possible compare conditions.
                    for pc_condition in condition_t range no_condition to greater_than loop
                        
                        -- Set the conditions of current loop.
                        test_in_condition <= pc_condition;
                        test_pc_condition <= i_condition;
                        
                        -- See if branch should be taken based on conditions.
                        if (pc_condition = i_condition) then
                            branch_taken(0) := '1';
                        else
                            branch_taken(0) := '0';
                        end if;
                        
                        -- Wait for output of controller to update.
                        wait for 20 ns;
                        
                        -- Assert based on which of the three branch instructions is being executed.
                        case op_code is
                        
                            when br_op =>
                                
                                assert((BR_SIGNALS or branch_taken) = to_std_logic_vector(test_control_signals))
                                    report "br failed."
                                    severity FAILURE;
                                
                            when b_op =>
                            
                                assert((B_SIGNALS or branch_taken) = to_std_logic_vector(test_control_signals))
                                    report "b failed."
                                    severity FAILURE;
                            
                            when bl_op =>
                        
                                assert((BL_SIGNALS or branch_taken) = to_std_logic_vector(test_control_signals))
                                    report "bl failed."
                                    severity FAILURE;
                        
                        end case;
                        
                    end loop;
                
                end loop;

            else    
           
                wait for 20 ns;
                
                -- Big switch for every other op code.
                case op_code is
                
                    when add_op     => 
                        
                        assert (to_std_logic_vector(test_control_signals) = ADD_SIGNALS)
                            report "add failed"
                            severity FAILURE;
                        
                    when sub_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = SUB_SIGNALS)
                            report "sub failed"
                            severity FAILURE;
                    
                    when str_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = STR_SIGNALS)
                            report "str failed"
                            severity FAILURE;
                    
                    when ldr_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = LDR_SIGNALS)
                            report "ldr failed"
                            severity FAILURE;
                    
                    when and_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = AND_SIGNALS)
                            report "and failed"
                            severity FAILURE;
                    
                    when or_op      => 
                    
                        assert (to_std_logic_vector(test_control_signals) = OR_SIGNALS)
                            report "or failed"
                            severity FAILURE;
                    
                    when not_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = NOT_SIGNALS)
                            report "not failed"
                            severity FAILURE;
                    
                    when cmp_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = CMP_SIGNALS)
                            report "cmp failed"
                            severity FAILURE;
                    
                    when loadil_op  => 
                    
                        assert (to_std_logic_vector(test_control_signals) = LOADIL_SIGNALS)
                            report "loadil failed"
                            severity FAILURE;
                    
                    when loadiu_op  => 
                    
                        assert (to_std_logic_vector(test_control_signals) = LOADIU_SIGNALS)
                            report "loadiu failed"
                            severity FAILURE;
                    
                    when addi_op    => 
                    
                        assert (to_std_logic_vector(test_control_signals) = ADDI_SIGNALS)
                            report "addi failed"
                            severity FAILURE;
                    
                    when lsr_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = LSR_SIGNALS)
                            report "lsr failed"
                            severity FAILURE;
                    
                    when lsl_op     => 
                    
                        assert (to_std_logic_vector(test_control_signals) = LSL_SIGNALS)
                            report "lsl failed"
                            severity FAILURE;
                
                end case;
            
            end if;
            
        end loop;
    
        wait;
    
    end process;

end test;