library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;
use work.all;


entity datapath_test_bench is
end datapath_test_bench;


architecture datapath_test of datapath_test_bench is

    signal debug_register_addr      : std_logic_vector(3 downto 0);
    signal debug_register_data      : std_logic_vector(15 downto 0);
    signal read_data_bus            : std_logic_vector(15 downto 0);
    signal write_data_bus           : std_logic_vector(15 downto 0);
    signal address_bus              : std_logic_vector(15 downto 0);
    signal clock                    : std_logic := '0';
    signal instruction              : std_logic_vector(15 downto 0) := "0000000000000000";
    signal pc_pointer               : std_logic_vector(9 downto 0);
    signal data_memory_write_enable : std_logic;

    
    -- Functions for translating instructions to binary code - basically a bad assembler.
    function form_machine_code(op   : in op_code_t;
                               arg0 : in std_logic_vector;
                               arg1 : in std_logic_vector;
                               arg2 : in std_logic_vector) 
    return std_logic_vector is
    
        return (arg0 & arg1 & arg2 & std_logic_vector(to_unsigned(op_code_t'pos(op), 2)));
        
    end function form_machine_code;
    
    -- Functions for translating instructions to binary code - basically a bad assembler.
    function form_machine_code(op   : in op_code_t;
                               arg0 : in std_logic_vector;
                               arg1 : in std_logic_vector) 
    return std_logic_vector is
    
        return (arg0 & arg1 & std_logic_vector(to_unsigned(op_code_t'pos(op), 2)));
        
    end function form_machine_code;
                               
    
    
begin

    -- Start the clock.
    clock <= not clock after 50 ns;

    -- Top level instantiation.
    UUT : entity work.datapath
        port map (debug_register_address                        => debug_register_addr,
                  debug_register_data                           => debug_register_data,
                  memory_input_bus.data_read_bus                => read_data_bus,
                  memory_input_bus.instruction_read_bus         => instruction,
                  memory_output_bus.data_write_bus              => write_data_bus,
                  memory_output_bus.data_address_bus            => address_bus,
                  memory_output_bus.data_write_enable           => data_memory_write_enable,
                  memory_output_bus.instruction_address_bus     => pc_pointer,
                  clock                                         => clock);
                
    process
        
        -- Intermediate variables.
        variable reg_num            : std_logic_vector(3 downto 0);
        variable cond_num           : std_logic_vector(1 downto 0);
        
        -- Comparison variables.
        variable condition_compare  : std_logic_vector(1 downto 0);
        variable compare_value      : std_logic_vector(15 downto 0);
        variable pre_instruction_pc : std_logic_vector(9 downto 0);
        
    begin
  
        ---------------------------------------
        -- Test immediate load instructions. --
        ---------------------------------------
  
      
        -- Test loadiu.
        -- Load the register number into the upper 8 bits of each register.
        for i in 0 to 15 loop
      
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
            debug_register_addr <= reg_num;
          
            -- loadiu reg_num, reg_num
            -- instruction <=  reg_num & "0000" & reg_num & "1100"; 
            instruction <=  form_machine_code(loadiu_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
            
            assert(debug_register_data = ("0000" & reg_num & "00000000"))
                report "loadiu instruction failed."
                severity FAILURE;
          
        end loop;
    
        
        -- Test loadil.
        -- Load the register number into the lower 8 bits of each register.
        for i in 0 to 15 loop
      
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
            debug_register_addr <= reg_num;
          
            -- loadil reg_num, reg_num
            -- instruction <=  reg_num & "0000" & reg_num & "1011"; 
            instruction <=  form_machine_code(loadil_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
          
            assert(debug_register_data = ("000000000000" & reg_num))
                report "loadil instruction failed."
                severity FAILURE;
          
        end loop;
  
  
        ---------------------------------------
        -- Test all arithmetic instructions. --
        ---------------------------------------
        
        
        -- Test add.  (rd(4) rs1(4) rs2(4))
        -- Add r0 to every other register.
        for i in 1 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(to_signed(i + 1, 16));
            debug_register_addr <= reg_num;

            -- add reg_num, reg_num, r0
            instruction <= form_machine_code(add_op, reg_num, reg_num, "0000");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "add instruction failed."
                severity FAILURE;
          
        end loop;
        
        
        -- Test sub.  (rd(4) rs1(4) rs2(4))
        -- Subtract r0 to every other register.
        for i in 1 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(to_signed(i - 1, 16));
            debug_register_addr <= reg_num;

            -- sub reg_num, reg_num, r0
            instruction <= form_machine_code(sub_op, reg_num, reg_num, "0000");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "sub instruction failed."
                severity FAILURE;
          
        end loop;
        
        
        -- Test and.  (rd(4) rs1(4) rs2(4))
        -- And r10 with every other register.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(to_unsigned(i, 16)) and "0000000000001010";
            debug_register_addr <= reg_num;

            -- and reg_num, reg_num, r10
            instruction <= form_machine_code(and_op, reg_num, reg_num, "1010");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "and instruction failed."
                severity FAILURE;
          
        end loop;
        
  
        -- Reload register numbers to each register for subsequent tests.
        for i in 0 to 15 loop
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
          
            -- loadil reg_num, reg_num
            instruction <=  form_machine_code(loadil_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
          
        end loop;
        
        
        -- Test or.   (rd(4) rs1(4) rs2(4))
        -- Or r9 with every other register.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(to_unsigned(i, 16)) or "0000000000001001";
            debug_register_addr <= reg_num;

            -- or reg_num, reg_num, r9
            instruction <= form_machine_code(or_op, reg_num, reg_num, "1001");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "or instruction failed."
                severity FAILURE;
          
        end loop;
        
  
        -- Reload register numbers to each register for subsequent tests.
        for i in 0 to 15 loop
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
          
            -- loadil reg_num, reg_num
            instruction <=  form_machine_code(loadil_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
          
        end loop;
        
        
        -- Test not.  (rd(4) rs1(4) unused(4))
        -- Not each register twice, testing value after each not.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := not(std_logic_vector(to_unsigned(i, 16)));
            debug_register_addr <= reg_num;

            -- not reg_num, reg_num
            instruction <= form_machine_code(not_op, reg_num, reg_num, "0000");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "first not instruction failed."
                severity FAILURE;
          
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
          
            -- not reg_num, reg_num
            instruction <= form_machine_code(not_op, reg_num, reg_num, "0000");
            wait for 100 ns;
            
            assert(debug_register_data = not(compare_value))
                report "second not instruction failed."
                severity FAILURE;
          
        end loop;
        
        
        -- Test lsr.  (rd(4) rs1(4) constant(4))
        -- Shift every register by reg_num times to the right.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(shift_right(to_unsigned(i, 16), i));
            debug_register_addr <= reg_num;

            -- lsr reg_num, reg_num, reg_num
            instruction <= form_machine_code(lsr_op, reg_num, reg_num, reg_num);
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "lsr instruction failed."
                severity FAILURE;
          
        end loop;
        
  
        -- Reload register numbers to each register for subsequent tests.
        for i in 0 to 15 loop
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
          
            -- loadil reg_num, reg_num
            instruction <=  form_machine_code(loadil_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
          
        end loop;
        
        
        -- Test lsl.  (rd(4) rs1(4) constant(4))
        -- Shift every register by reg_num times to the left.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(shift_left(to_unsigned(i, 16), i));
            debug_register_addr <= reg_num;

            -- lsr reg_num, reg_num, reg_num
            instruction <= form_machine_code(lsl_op, reg_num, reg_num, reg_num);
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "lsl instruction failed."
                severity FAILURE;
          
        end loop;
        
  
        -- Reload register numbers to each register for subsequent tests.
        for i in 0 to 15 loop
      
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
          
            -- loadil reg_num, reg_num
            instruction <=  form_machine_code(loadil_op, reg_num, "0000" & reg_num);
            wait for 100 ns;
          
        end loop;
        
        
        -- Test addi. (rd(4) rs1(4) constant(4))
        -- Add 1 to each register, and then add -1 to each register, checking each time.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := std_logic_vector(to_unsigned(i + 1, 16));
            debug_register_addr <= reg_num;

            -- add reg_num, reg_num, 1
            instruction <= form_machine_code(addi_op, reg_num, reg_num, "0001");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "first addi instruction failed."
                severity FAILURE;
          
            -- Setup second compare value.
            compare_value := std_logic_vector(to_unsigned(i, 16));
          
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
          
            -- add reg_num, reg_num, -1
            instruction <= form_machine_code(addi_op, reg_num, reg_num, "1111");
            wait for 100 ns;
            
            assert(debug_register_data = compare_value)
                report "second addi instruction failed."
                severity FAILURE;
        
        
        --------------------------------------------------
        -- Test all branch (and comparison) instructions. --
        --------------------------------------------------
    
        -- Test br.  (rd(4) unused(6) cond(2))
        -- For each of the four compare results, branch to r5 and check PC.
        for i in 0 to 15 loop
        
            for instruction_condition in 0 to 3 loop
            
                -- Store current condition being tested.
                cond_num := std_logic_vector(to_unsigned(instruction_condition, 2));
                
                -- Store PC to test that instruction correctly affects PC change.
                pre_instruction_pc := pc_pointer;
                
                -- Go ahead and branch without comparison to test for branch immediate.
                instruction <= form_machine_code(br_op, "0101", "000000", cond_num);
                wait for 100 ns;
                
                -- Test for branch immediate correctness.
                if (cond_num = "00") then
                
                    -- See if branch took place.
                    assert(pc_pointer = "0000000000000101")
                        report "br instruction failed."
                        severity FAILURE;
                
                else 
                
                    -- If branch didn't take place, PC should be incremented by one.
                    assert(pc_pointer = std_logic_vector(to_unsigned(to_integer(unsigned(pre_instruction_pc)) + 1, 10)))
                        report "br instruction failed."
                        severity FAILURE;
                
                end if;
            
            
                -- Store PC to test that instruction correctly affects PC change.
                pre_instruction_pc := pc_pointer;
                
                -- Compare two registers that are equal (compare r1 to r1).
                instruction <= form_machine_code(cmp_op, "0000", "0001", "0001");       wait for 100 ns;
                instruction <= form_machine_code(br_op, "0101", "000000", cond_num);    wait for 100 ns;
                
                -- Test for branch equal to correctness.
                if (cond_num = "01") then
                
                    -- See if branch took place.
                    assert(pc_pointer = "0000000000000101")
                        report "breq instruction failed."
                        severity FAILURE;
                
                else 
                
                    -- If branch didn't take place, PC should be incremented by one.
                    assert(pc_pointer = std_logic_vector(to_unsigned(to_integer(unsigned(pre_instruction_pc)) + 2, 10)))
                        report "breq instruction failed."
                        severity FAILURE;
                
                end if;
                
                
                -- Store PC to test that instruction correctly affects PC change.
                pre_instruction_pc := pc_pointer;
                
                -- Compare two registers, where the first is greater than the second (compare r1 to r0).
                instruction <= form_machine_code(cmp_op, "0000", "0001", "0000");       wait for 100 ns;
                instruction <= form_machine_code(br_op, "0101", "000000", cond_num);    wait for 100 ns;
                
                -- Test for less than correctness.
                if (cond_num = "10") then
                
                    -- See if branch took place.
                    assert(pc_pointer = "0000000000000101")
                        report "brlt instruction failed."
                        severity FAILURE;
                
                else 
                
                    -- If branch didn't take place, PC should be incremented by one.
                    assert(pc_pointer = std_logic_vector(to_unsigned(to_integer(unsigned(pre_instruction_pc)) + 2, 10)))
                        report "brlt instruction failed."
                        severity FAILURE;
                
                end if;
                
                
                -- Store PC to test that instruction correctly affects PC change.
                pre_instruction_pc := pc_pointer;
                
                -- Compare two registers, where the second is greater than the first (compare r1 to r2).
                instruction <= form_machine_code(cmp_op, "0000", "0001", "0010");       wait for 100 ns;
                instruction <= form_machine_code(br_op, "0101", "000000", cond_num);    wait for 100 ns;
                
                -- Test for less than correctness.
                if (cond_num = "11") then
                
                    -- See if branch took place.
                    assert(pc_pointer = "0000000000000101")
                        report "brgt instruction failed."
                        severity FAILURE;
                
                else 
                
                    -- If branch didn't take place, PC should be incremented by one.
                    assert(pc_pointer = std_logic_vector(to_unsigned(to_integer(unsigned(pre_instruction_pc)) + 2, 10)))
                        report "brgt instruction failed."
                        severity FAILURE;
                
                end if;

            end loop;
                    
        end loop;
        
        
        -- Test b.   (address(10) cond(2))
        
        
        -- Test bl.  (address(10) cond(2))
        
        
        
        
        ---------------------------------------------
        -- Test data memory instructions (partly). --
        ---------------------------------------------
        
        -- Test ldr. (rd(4) rs1(4) rs2(4))
        -- Load in the simulated value 0xBEEF from memory locations matching the register number.
        --
        -- Since there is no memory, the read data bus is driven and the data address bus is checked
        -- for correctness.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := "1011111011101111";
            debug_register_addr <= reg_num;

            -- ldr reg_num, reg_num, r0
            instruction     <= form_machine_code(ldr_op, reg_num, reg_num, "0000");
            read_data_bus   <= compare_value;
            wait for 100 ns;
            
            -- Check that the datapath is requesting data from correct memory location.
            assert(address_bus = reg_num)
                report "ldr instruction failed (incorrect data memory address)."
                severity FAILURE;
            
            -- Check that the datapath is stored the data from memory correctly.
            assert(debug_register_data = compare_value)
                report "ldr instruction failed (incorrect data memory obtained)."
                severity FAILURE;
          
        end loop;
        
        
        -- Test str. (rd(4) rs1(4) rs2(4))
        -- Store the value of each register into memory locations matching the register number.
        --
        -- Since there is no memory, the data address bus, data write bus, and data write enable  
        -- are checked for correctness.
        for i in 0 to 15 loop
        
            -- Store PC to test that instruction correctly affects PC change.
            pre_instruction_pc := pc_pointer;
        
            -- Convert i to std_logic_vector and setup comparison value.
            reg_num             := std_logic_vector(to_unsigned(i, 4));
            compare_value       := "1011111011101111";
            debug_register_addr <= reg_num;

            -- str reg_num, reg_num, r0
            instruction     <= form_machine_code(str_op, reg_num, reg_num, "0000");
            wait for 100 ns;
            
            -- Check that the datapath is enabling write enable.
            assert(data_memory_write_enable = '1')
                report "str instruction failed (write enable not turned on)."
                severity FAILURE;
            
            -- Check that the datapath is putting correct data on write bus.
            assert(data_write_bus = reg_num)
                report "str instruction failed (incorrect data put on write bus)."
                severity FAILURE;
            
            -- Check that the datapath is writing to the correct address.
            assert(address_bus = reg_num)
                report "str instruction failed (incorrect data memory address)."
                severity FAILURE;
          
        end loop;
    
        wait for 100 ns; wait;
    
    end process;

end datapath_test;