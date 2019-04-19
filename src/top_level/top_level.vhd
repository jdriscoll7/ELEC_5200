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


entity datapath is
    
    port (debug_register_address    : in  std_logic_vector(3 downto 0);  
          debug_register_data       : out std_logic_vector(15 downto 0);
          memory_input_bus          : in  memory_input_bus_t;
          memory_output_bus         : out memory_output_bus_t;
          clock                     : in  std_logic);
    
end datapath;


architecture behavioral of datapath is

    ------------------------------------
    -- Signals used for interconnect. --
    ------------------------------------
    
    -- Internal state of control signals.
    signal control_signals  : control_signal_bus_t;
    signal c_alu_op         : alu_op_t;
    
    -- PC-related signals.
    signal pc_condition_in     : std_logic_vector(1 downto 0);
    signal pc_condition_out    : std_logic_vector(1 downto 0);
    signal pc_pointer_in       : std_logic_vector(9 downto 0);
    signal pc_pointer_out      : std_logic_vector(9 downto 0);
    signal pc_input            : std_logic_vector(15 downto 0);
    signal pc_output           : std_logic_vector(15 downto 0);
    
    -- Register file related signals.
    signal file_data_in     : std_logic_vector(15 downto 0);
    signal file_addr_in     : std_logic_vector(3 downto 0);
    signal file_read_1      : std_logic_vector(3 downto 0);
    signal file_read_2      : std_logic_vector(3 downto 0);
    signal file_out_1       : std_logic_vector(15 downto 0);
    signal file_out_2       : std_logic_vector(15 downto 0);
    
    -- ALU related signals.
    signal alu_in_1         : std_logic_vector(15 downto 0);
    signal alu_in_2         : std_logic_vector(15 downto 0);
    signal alu_out          : std_logic_vector(15 downto 0);
    signal alu_zero_flag    : std_logic;
    
    --------------------------------------------
    -- Signals used for instruction decoding. --
    --------------------------------------------
    signal instr_raw                : std_logic_vector(15 downto 0);
    signal instr_op_code            : op_code_t;
    signal instr_condition          : condition_t;
    signal rd, rs1, rs2             : std_logic_vector(3 downto 0);
    signal small_constant_operand   : std_logic_vector(3 downto 0);
    signal large_constant_operand   : std_logic_vector(7 downto 0);
    signal branch_address           : std_logic_vector(9 downto 0);
    
begin

    ----------------------------
    -- Entity instantiations. --
    ----------------------------
    
    -- Controller instantiation.
    control_unit : entity work.control_unit
    
        port map (op_code           => instr_op_code,
                  in_condition      => instr_condition,
                  pc_condition      => pc_condition_out,
                  clock             => clock,
                  control_signals   => control_signals);

        
    -- Register file instantiation.
    register_file : entity work.register_file
    
        port map (read_address_1 => file_read_1,
                  read_address_2 => file_read_2,
                  write_address  => file_addr_in,
                  data_in        => file_data_in,
                  write_enable   => control_signals.c_reg_write,
                  data_out_1     => file_out_1,
                  data_out_2     => file_out_2,
                  clock          => clock);
                  
                  
    -- Second register file that mimics true file for debugging.
    register_file_debug : entity work.register_file
    
        port map (read_address_1 => debug_register_address,
                  read_address_2 => debug_register_address,
                  write_address  => file_addr_in,
                  data_in        => file_data_in,
                  write_enable   => control_signals.c_reg_write,
                  data_out_1     => debug_register_data,
                  data_out_2     => debug_register_data,
                  clock          => clock);
        
        
    -- ALU instantiation.
    alu : entity work.alu
    
        port map (alu_op    => c_alu_op,
                  alu_in_1  => alu_in_1,
                  alu_in_2  => alu_in_2,
                  alu_out   => alu_out,
                  zero_flag => alu_zero_flag);
        
        
    -- PC instantiation.
    pc : entity work.generic_register
    
        port map (data_in       => pc_input, 
                  data_out      => pc_output,
                  write_enable  => '1',
                  clock         => clock);
    
    
    ---------------------------
    -- Instruction decoding. --
    ---------------------------
    process(instr_raw)
    begin
    
        -- Extract op code from instruction.
        instr_op_code <= to_op_code_t(instr_raw(3 downto 0));
        
        -- Extract rd, rs1, rs2.
        rd  <= instr_raw(15 downto 12);
        rs1 <= instr_raw(11 downto 8);
        rs2 <= instr_raw(7 downto 4);
        
        -- Extract branch address.
        branch_address <= instr_raw(15 downto 6);
        
        -- Extract branch condition.
        instr_condition <= to_condition_t(instr_raw(5 downto 4));
        
        -- Extract large and small constants.
        large_constant_operand <= instr_raw(11 downto 4);
        small_constant_operand <= instr_raw(7 downto 4);
    
    end process;
    
    
    ---------------------------------------
    -- Controller datapath multiplexing. --
    ---------------------------------------
    process(clock, control_signals, branch_address, alu_out, pc_condition_out, 
            pc_pointer_out, instr_raw, memory_input_bus.data_read_bus)
    begin
    
        -- Determine PC value input.
        if (control_signals.c_branch = '0') then
        
            pc_pointer_in <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_pointer_out)) + 1, pc_pointer_in'length));
            
        else
        
            if (control_signals.c_r_type = '0') then
            
                pc_pointer_in <= branch_address;
            
            else
            
                pc_pointer_in <= std_logic_vector(to_unsigned(to_integer(unsigned(file_out_1(15 downto 6))) + 1, pc_pointer_in'length));
            
            end if;
        
        end if;
        
        
        -- Determine PC condition input.
        if (control_signals.c_compare = '0') then
        
            pc_condition_in <= pc_condition_out;
        
        else
        
            pc_condition_in <= alu_out(15) & alu_zero_flag;
        
        end if;
        
        
        -- Determine register file write data.
        if (control_signals.c_load_imm = '0') then
        
            if (control_signals.c_mem_read = '0') then
                
                file_data_in <= alu_out;
                
            else
                
                file_data_in <= memory_input_bus.data_read_bus;
                
            end if;
        
        else
        
            if (control_signals.c_upper_imm = '0') then
                
                file_data_in <= "00000000" & large_constant_operand;
                
            else
                
                file_data_in <= large_constant_operand & "00000000";
                
            end if;
        
        end if;
        
        
        -- Determine second ALU input.
        if (control_signals.c_i_type = '0') then
        
            alu_in_2 <= file_out_2;
        
        else
        
            if (instr_op_code = addi_op) then
            
                alu_in_2(15 downto 0) <= (others => small_constant_operand(3)); 
                alu_in_2(3 downto 0)  <= small_constant_operand;
            
            else
            
                alu_in_2(15 downto 0) <= (others => '0'); 
                alu_in_2(3 downto 0)  <= small_constant_operand;
            
            end if;
            
        end if;    
                
        
        -- Determine register file write address.
        if (control_signals.c_link = '0') then
        
            file_addr_in <= rd;
        
        else
        
            file_addr_in <= "1111";
            file_data_in <= pc_pointer_out & "0000" & pc_condition_out;
        
        end if;
        
        
        -- Change register read address 1 to rd if str.
        if (control_signals.c_mem_write = '1') then
        
            file_read_1 <= rd;
            
        else
        
            file_read_1 <= rs1;
        
        end if;
        

    end process;


    -------------------------
    -- Signal assignments. --
    -------------------------
    
    -- Instruction decoding related.
    c_alu_op  <= to_alu_op_t(control_signals.c_alu_op);
    
    -- PC register related.
    pc_input(15 downto 6)   <= pc_pointer_in;
    pc_input(1 downto 0)    <= pc_condition_in;
    pc_pointer_out          <= pc_output(15 downto 6);
    pc_condition_out        <= pc_output(1 downto 0);
    memory_output_bus.instruction_address_bus <= pc_pointer_out;
    
    -- Data memory related.
    memory_output_bus.data_write_enable <= control_signals.c_mem_write;
    memory_output_bus.data_address_bus  <= alu_out(9 downto 0);
    memory_output_bus.data_write_bus    <= file_out_1;
    
    -- Instruction memory related.
    instr_raw <= memory_input_bus.instruction_read_bus;
    
    -- File related.
    file_read_2 <= rs2;
    
    -- ALU related.
    alu_in_1 <= file_out_1;
    
end behavioral;
