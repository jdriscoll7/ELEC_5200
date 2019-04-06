library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;
use work.all;


entity program_test_bench is
end program_test_bench;


architecture program_test of program_test_bench is

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
    begin
    
        return (arg0 & arg1 & arg2 & std_logic_vector(to_unsigned(op_code_t'pos(op), 4)));
        
    end function form_machine_code;
    
    -- Functions for translating instructions to binary code - basically a bad assembler.
    function form_machine_code(op   : in op_code_t;
                               arg0 : in std_logic_vector;
                               arg1 : in std_logic_vector) 
    return std_logic_vector is
    begin
    
        return (arg0 & arg1 & std_logic_vector(to_unsigned(op_code_t'pos(op), 4)));
        
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
  
        wait for 25 ns;
  
        -- Result is stored in register 0.
        debug_register_addr <= "0000";
        
        instruction <= "0000000000011011"; wait for 100 ns;
        instruction <= "0000000010101111"; wait for 100 ns;
        instruction <= "0001000011001011"; wait for 100 ns;
        instruction <= "0000000000010001"; wait for 100 ns;
        instruction <= "0010000001101011"; wait for 100 ns;
        instruction <= "0011000010001011"; wait for 100 ns;
        instruction <= "0010001000110101"; wait for 100 ns;
        instruction <= "0010001000100110"; wait for 100 ns;
        instruction <= "0011010101011100"; wait for 100 ns;
        instruction <= "0011001110001110"; wait for 100 ns;
        instruction <= "0010001000110100"; wait for 100 ns;
        instruction <= "0000000000100000"; wait for 100 ns;
        
        -- Answer to computation is 0x445.
        assert(debug_register_data = "0000010001000101")
            report "Wrong answer."
            severity FAILURE;
        
        wait;
    
    end process;

end program_test;