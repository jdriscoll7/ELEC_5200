-- File: register.vhdl
-- 
-- Implements a generic register model.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-- Register interface.
entity generic_register is

    generic (N : integer := 8);
                 
    port    (data_in        : in std_logic_vector((N - 1) downto 0),
             data_out       : in std_logic_vector((N - 1) downto 0),
             write_enable   : in std_logic,
             clock          : in std_logic);

end generic_register;
             

-- Register implementation. 
architecture behavioral of generic_register is

    signal stored_value : std_logic_vector((N - 1) downto 0) := 0;
    
begin

    process(clock)
    begin
    
        if rising_edge(clock) then
            
            if (write_enable = '1') then
            
                stored_value <= input;
                
            end if;
            
        end if;
    
    end process;

end behavioral;