library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


library work;
use work.all;
use work.instruction_memory;


entity cpu is

    port (clock : in  std_logic);

end cpu;


architecture behavioral of cpu is

    -- Debugging signals to read register file of CPU.
    signal debug_register_address   : std_logic_vector(3 downto 0); 
    signal debug_register_data      : std_logic_vector(15 downto 0);

    -- Memory buses.
    signal memory_input_bus         : memory_input_bus_t;
    signal memory_output_bus        : memory_output_bus_t;

begin

    -- Datapath instantiation.
    datapath : entity work.datapath

        port map (debug_register_address    => debug_register_address,  
                  debug_register_data       => debug_register_data,
                  memory_input_bus          => memory_input_bus,
                  memory_output_bus         => memory_output_bus,
                  clock                     => clock);


    -- Instruction memory instantiation.
    instruction_memory : entity work.instruction_memory

        port map (read_address => memory_output_bus.instruction_address_bus,
                  data_out     => memory_input_bus.instruction_read_bus);


    -- Data memory instantiation.
    data_memory : entity work.data_memory

        port map (read_address  => memory_output_bus.data_address_bus,
                  data_out      => memory_input_bus.data_read_bus,
                  write_enable  => memory_output_bus.data_write_enable,
                  write_data    => memory_output_bus.data_write_bus);
    
end behavioral;
