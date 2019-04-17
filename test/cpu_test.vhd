library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;
use work.all;


entity cpu_test_bench is
end cpu_test_bench;


architecture cpu_test of cpu_test_bench is

    -- Signals for CPU top level interface.
    signal debug_register_addr      : std_logic_vector(3 downto 0);
    signal debug_register_data      : std_logic_vector(15 downto 0);
    signal clock                    : std_logic := '0';
    
begin

    -- Start the clock.
    clock <= not clock after 50 ns;

    -- Top level instantiation.
    UUT : entity work.cpu
    
        port map (debug_register_address    => debug_register_addr,
                  debug_register_data       => debug_register_data,
                  clock                     => clock);
                
    process
        
    begin
  
        wait for 2 us;
  
        -- Result is stored in register 0.
        debug_register_addr <= "0000";
                
        wait for 100 ns;
                
        -- Answer to computation is 0x445.
        assert(debug_register_data = "0000010001000101")
            report "Wrong answer."
            severity FAILURE;
        
        wait;
    
    end process;

end cpu_test;
