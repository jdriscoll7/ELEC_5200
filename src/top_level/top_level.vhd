library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;
use work.all;


entity top_level is
    
    port (read_data_bus     : in  std_logic_vector(15 downto 0);
          write_data_bus    : out std_logic_vector(15 downto 0);
          address_bus       : out std_logic_vector(15 downto 0);
          instruction       : in  std_logic_vector(15 downto 0);
          clock             : in  std_logic);                   
    
end top_level;


architecture behavioral of top_level is

    ------------------------------------
    -- Signals used for interconnect. --
    ------------------------------------
    
    -- Internal state of control signals.
    signal control_signals  : control_signal_bus_t;
    
    -- PC-related signals.
    signal pc_condition_in     : condition_t;
    signal pc_condition_out    : condition_t;
    signal pc_pointer_in       : std_logic_vector(9 downto 0);
    signal pc_pointer_out      : std_logic_vector(9 downto 0);
    
    -- Register file related signals.
    signal file_data_in     : std_logic_vector(15 downto 0);
    signal file_addr_in     : std_logic_vector(3 downto 0);
    signal file_out_1       : std_logic_vector(15 downto 0);
    signal file_out_2       : std_logic_vector(15 downto 0);
    
    -- ALU related signals.
    signal alu_in_1         : std_logic_vector(15 downto 0):
    signal alu_in_2         : std_logic_vector(15 downto 0):
    signal alu_out          : std_logic_vector(15 downto 0):
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
    signal branch_address           : std_logic_vector(9 downto 0)
    
begin

    ----------------------------
    -- Entity instantiations. --
    ----------------------------
    
    -- Controller instantiation.
    entity control_unit : work.control_unit
        port map (op_code           => current_op_code;
                  in_condition      => instr_condition;
                  pc_condition      => pc_condition;
                  clock             => clock;
                  control_signals   => control_signals);

        
    -- Register file instantiation.
    entity register_file : work.register_file
        port map (read_address_1 => rs1;
                  read_address_2 => rs2;
                  write_address  => file_addr_in;
                  data_in        => register_file_data_in;
                  write_enable   => control_signals.c_reg_write;
                  data_out_1     => file_out_1;
                  data_out_2     => file_out_2);
        
        
    -- ALU instantiation.
    entity alu : work.alu
        port map (alu_op    => control_signals.c_alu_op;
                  alu_in_1  => alu_in_1;
                  alu_in_2  => alu_in_2;
                  alu_out   => alu_out;
                  zero_flag => alu_zero_flag);
        
        
    -- PC instantiation.
    entity pc : work.generic_register
        port map (data_in       => pc_input;
                  data_out      => pc_output;
                  write_enable  => '1';
                  clock         => clock;);
    
    
    ---------------------------
    -- Instruction decoding. --
    ---------------------------
    process(instr_raw)
    begin
    
        -- Extract op code from instruction.
        instr_op_code <= instr_raw(3 downto 0);
        
        -- Extract rd, rs1, rs2.
        rd  <= instr_raw(15 downto 12);
        rs1 <= instr_raw(11 downto 8);
        rs2 <= instr_raw(7 downto 4);
        
        -- Extract branch address.
        branch_address <= instr_raw(15 downto 6);
        
        -- Extract branch condition.
        instr_condition <= instr_raw(5 downto 4);
        
        -- Extract large and small constants.
        large_constant_operand <= instr_raw(7 downto 4);
        small_constant_operand <= instr_raw(11 downto 4);
    
    end process;
    
    
    ---------------------------------------
    -- Controller datapath multiplexing. --
    ---------------------------------------
    process(control_signals)
    begin
    
        -- Determine PC value input.
        if (control_signals.c_branch = '0') then
        
            pc_pointer_in <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_pointer_out)) + 1, pc_pointer_in'length));
            
        else
        
            if (control_signals.c_r_type = '0') then
            
                pc_pointer_in <= branch_address;
            
            else
            
                pc_pointer_in <= file_out_1;
            
            end if;
        
        end if;
        
        
        -- Determine PC condition input.
        if (control_signals.c_cmp = '0') then
        
            pc_condition_in <= pc_condition_out;
        
        else
        
            pc_condition_in <= alu_out(15) & alu_zero_flag;
        
        end if;
        
        
        -- Determine register file write address.
        if (control_signals.c_link = '0') then
        
            file_addr_in <= rd;
        
        else
        
            file_addr_in <= "1111";
        
        end if;
        
        
        -- Determine register file write data.
        if (control_signals.c_load_imm = '0') then
        
            if (control_signals.c_mem_read = '0') then
                
                file_data_in <= alu_out;
                
            else
                
                file_data_in <= ;
                
            end if;
        
        else
        
            if (control_signals.c_upper_imm = '0') then
                
                
                
            else
                
                
                
            end if;
        
        end if;
        
        
        -- Determine second ALU input.
        if (control_signals.c_i_type = '0') then
        
        
        
        
        else
        
        
        
        
        end if;
        
        
    end process;


    -------------------------
    -- Signal assignments. --
    -------------------------
    instr_raw <= instruction;


end behavioral;