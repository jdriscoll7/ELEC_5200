-- File: register_test.vhd
--
-- Testbench for register component.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.all;


entity test_bench is 
end test_bench;


architecture test of test_bench is

    -- Size of register to test.
    constant N : integer := 8;

    -- Signals to connect UUT.
    signal data_in  : std_logic_vector((N - 1) downto 0) := (others => '0');
    signal data_out : std_logic_vector((N - 1) downto 0);
    signal clock    : std_logic := '0';
    signal write_en : std_logic := '0';

begin
    
    -- Instantiate register.
    UUT : entity work.generic_register
        port map (data_in       => data_in,
                  data_out      => data_out,
                  write_enable  => write_en,
                  clock         => clock);
                  
    -- Create 200 MHz clock.
    clock <= not clock after 5 ns;
    
    -- Testing patterns.
    process
        
        variable input_value : std_logic_vector((N - 1) downto 0):= (others => '0');
    
    begin
    
        for test_val in 0 to ((2**N) - 1) loop
        
            -- Set input of register to current loop value.
            input_value := std_logic_vector(to_unsigned(test_val, N));
            data_in <= input_value;
            
            -- Drive write enable.
            write_en <= '1';
            
            -- Wait for everything to settle and assert.
            wait for 100 ns;
            
            assert(input_value = data_out)
                report "Output data was not set correctly."
                severity FAILURE;
            
            write_en <= '0';
            wait for 100 ns;
        
        
        end loop;
    
        wait;
    
    end process;
    
end test;
