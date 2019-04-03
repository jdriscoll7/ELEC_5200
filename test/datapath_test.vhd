library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;
use work.all;


entity top_level_test_bench is
end top_level_test_bench;


architecture test of top_level_test_bench is

    signal debug_register_addr  : std_logic_vector(3 downto 0);
    signal debug_register_data  : std_logic_vector(15 downto 0);
    signal read_data_bus        : std_logic_vector(15 downto 0);
    signal write_data_bus       : std_logic_vector(15 downto 0);
    signal address_bus          : std_logic_vector(15 downto 0);
    signal instruction          : std_logic_vector(15 downto 0); -- loadil r0, 0xFF
    signal clock                : std_logic := '0';
    

begin

    -- Start the clock.
    clock <= not clock after 50 ns;

    -- Top level instantiation.
    UUT : entity work.top_level
        port map (debug_register_addr   => debug_register_addr,
                  debug_register_data   => debug_register_data,
                  read_data_bus         => read_data_bus,
                  write_data_bus        => write_data_bus,
                  address_bus           => address_bus,
                  instruction           => instruction,
                  clock                 => clock);
                  
    process
        variable reg_num : std_logic_vector(3 downto 0);
    begin
    
        -- Wait for startup to settle.
        wait for 100 ns;
    
        -- Test loadil and loadiu.
        for i in 0 to 15 loop
        
            -- Convert i to std_logic_vector.
            reg_num := std_logic_vector(to_unsigned(i, 4));
            debug_register_addr <= reg_num;
            
            -- Load register number into upper and lower half.
            
            -- loadil reg_num, reg_num
            instruction <=  reg_num & "0000" & reg_num & "1011"; 
            wait for 100 ns;
            
            assert(debug_register_data = ("000000000000" & reg_num))
                report "loadil instruction failed."
                severity FAILURE;
            
            
            -- loadiu reg_num, reg_num
            instruction <=  reg_num & "0000" & reg_num & "1100"; 
            wait for 100 ns;
            
            assert(debug_register_data = ("0000" & reg_num & "00000000"))
                report "loadiu instruction failed."
                severity FAILURE;
        
        end loop;
        
        
        instruction <= "0001111011101011"; wait for 100 ns;   -- loadil r1, 0xEE
        instruction <= "0010110111011011"; wait for 100 ns;   -- loadil r2, 0xDD
        instruction <= "0011110011001011"; wait for 100 ns;   -- loadil r3, 0xCC
        instruction <= "0100101110111011"; wait for 100 ns;   -- loadil r4, 0xBB
        
        wait for 100 ns; wait;
        
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
--        instruction <= ""; wait for 1 ns;
        
    
    end process;
                  
end test;