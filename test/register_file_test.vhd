-- File: register_file_test.vhd
--
-- Testbench for register file component.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.all;


entity register_file_test_bench is 
end register_file_test_bench;


architecture test of register_file_test_bench is

    -- Register file parameters.
    constant N : integer := 8;   -- Number of register bits.
    constant M : integer := 10; -- Number of registers in file.

    -- Signals to connect UUT.
    
    -- Inputs.
    signal r_addr_1   : std_logic_vector((M - 1) downto 0) := (others => '0');
    signal r_addr_2   : std_logic_vector((M - 1) downto 0) := (others => '0');
    signal w_addr     : std_logic_vector((M - 1) downto 0) := (others => '0');
    signal data_in    : std_logic_vector((N - 1) downto 0) := (others => '0');
    signal write_en   : std_logic := '0';
    
    -- Outputs.
    signal data_out_1 : std_logic_vector((N - 1) downto 0);
    signal data_out_2 : std_logic_vector((N - 1) downto 0);
    

begin
    
    -- Instantiate register file.
    UUT : entity work.register_file
        
        generic map (REGISTER_SIZE => N,
                     ADDRESS_BITS  => M)
    
        port map (read_address_1 => r_addr_1,
                  read_address_2 => r_addr_2,
                  write_address  => w_addr,
                  data_in        => data_in,
                  write_enable   => write_en,
                  data_out_1     => data_out_1,
                  data_out_2     => data_out_2);
    
    -- Testing patterns.
    process
        
        -- Input value to DUT and comparison variables for readability in read loop.
        variable input_value     : std_logic_vector((N - 1) downto 0):= (others => '0');
        variable compare_value_1 : std_logic_vector((N - 1) downto 0):= (others => '0');
        variable compare_value_2 : std_logic_vector((N - 1) downto 0):= (others => '0');
    
    begin
    
        -- For each register, write to it (total number of registers - register number).        
        for reg_num in 0 to ((2**M) - 1) loop
        
            -- Set data_in current loop value.
            input_value := std_logic_vector(to_unsigned(((2**M) - 1) - reg_num, N));
            data_in <= input_value;
            
            -- Set write address to reg_num.
            w_addr <= std_logic_vector(to_unsigned(reg_num, M));
            
            -- Drive write enable.
            write_en <= '1';
            
            -- Wait for everything to settle and turn off write enable.
            wait for 25 ns;
            write_en <= '0';
            wait for 25 ns;
            
        end loop;
        
        -- Now read back values for each port, reading in opposite directions for each port.
        for reg_num in 0 to ((2**M) - 1) loop
        
            -- Get comparison values.
            compare_value_1 := std_logic_vector(to_unsigned(((2**M) - 1) - reg_num, N));
            compare_value_2 := std_logic_vector(to_unsigned(reg_num, N));
            
            -- Read from the ports (port 1 goes from low address to high address).
            r_addr_1 <= std_logic_vector(to_unsigned(reg_num, M));
            r_addr_2 <= std_logic_vector(to_unsigned(((2**M) - 1) - reg_num, M));
            
            -- Set write address to reg_num.
            w_addr <= std_logic_vector(to_unsigned(reg_num, M));
            
            -- Wait for everything to settle and turn off write enable.
            wait for 25 ns;
        
            -- Check correctness of both output port 1.
            assert(data_out_1 = compare_value_1)
                report "Output data on port 1 not set correctly."
                severity FAILURE;
            
            -- Check correctness of both output port 2.
            assert(data_out_2 = compare_value_2)
                report "Output data on port 2 not set correctly."
                severity FAILURE;
        
        end loop; 
        
        -- End testbench.
        wait;
    
    end process;
    
end test;
