-- File: control_unit.vhd
--
-- Implements the control unit for the CPU project.


-- Standard libraries and custom type definitions.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


-- Package that contains the control signals - basically packs the
-- control signals into a single bus using VHDL records (like a C-struct).
package control_unit_package is

    -- Function interface for casting std_logic_vector to control_signal_bus_t.
    function control_signal_bus(x : in std_logic_vector) return control_signal_bus_t;
    
    -- Function for converting control signal bus back to std_logic_vector.
    function to_std_logic_vector(x : in control_signal_bus_t) return std_logic_vector;

end package control_unit_package;


package body control_unit_package is

    -- Convert std_logic_vector to control signal bus (saves much code space).
    -- Note: assumes first three bits are alu_op.
    function control_signal_bus(x : in std_logic_vector) return control_signal_bus_t is

        variable output_bus : control_signal_bus_t;

    begin

        output_bus.c_alu_op     := x(12 downto 10);
        output_bus.c_compare    := x(9);
        output_bus.c_i_type     := x(8);
        output_bus.c_r_type     := x(7);
        output_bus.c_load_imm   := x(6);
        output_bus.c_upper_imm  := x(5);
        output_bus.c_mem_read   := x(4);
        output_bus.c_mem_write  := x(3);
        output_bus.c_reg_write  := x(2);
        output_bus.c_link       := x(1);
        output_bus.c_branch     := x(0);
        output_bus.size         := x'length;
        
        return output_bus;

    end function control_signal_bus;
    
    -- Function for converting control signal bus back to std_logic_vector.
    function to_std_logic_vector(x : in control_signal_bus_t) return std_logic_vector is
    
        variable output_vector : std_logic_vector((x.size - 1) downto 0);
        
    begin
        
        output_vector(12 downto 10) := x.c_alu_op;
        output_vector(9)  := x.c_compare;
        output_vector(8)  := x.c_i_type;
        output_vector(7)  := x.c_r_type;
        output_vector(6)  := x.c_load_imm;
        output_vector(5)  := x.c_upper_imm;
        output_vector(4)  := x.c_mem_read;
        output_vector(3)  := x.c_mem_write;
        output_vector(2)  := x.c_reg_write;
        output_vector(1)  := x.c_link;
        output_vector(0)  := x.c_branch;
        
        return output_vector;
        
    end function to_std_logic_vector;
    
end package body control_unit_package;






-- Standard libraries and custom type definitions.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.control_unit_package.all;


-- Beginning of control unit interface and implementation.
entity control_unit is

    port (op_code           : in  op_code_t;
          in_condition      : in  condition_t;
          pc_condition      : in  std_logic_vector(1 downto 0);
          clock             : in  std_logic;
          control_signals   : out control_signal_bus_t);

end control_unit;


-- Basically a massive switch statement that activates control signals
-- when they are needed by an instruction.
architecture behavioral of control_unit is

    -- Number of control signals can change after updates to design.
    constant num_control_signals : integer := 13;
    subtype  control_constant_t is std_logic_vector((num_control_signals - 1) downto 0);

    -- This table is based on the tables created for the second project report.
    constant ADD_SIGNALS    : control_constant_t := "0000000000100";
    constant SUB_SIGNALS    : control_constant_t := "0010000000100";
    constant STR_SIGNALS    : control_constant_t := "0000000001000";
    constant LDR_SIGNALS    : control_constant_t := "0000000010100";
    constant AND_SIGNALS    : control_constant_t := "0100000000100";
    constant OR_SIGNALS     : control_constant_t := "0110000000100";
    constant NOT_SIGNALS    : control_constant_t := "1000000000100";
    constant CMP_SIGNALS    : control_constant_t := "0011000000000";
    constant BR_SIGNALS     : control_constant_t := "0000010000000";
    constant B_SIGNALS      : control_constant_t := "0000000000000";
    constant BL_SIGNALS     : control_constant_t := "0000000000110";
    constant LOADIL_SIGNALS : control_constant_t := "0000001000100";
    constant LOADIU_SIGNALS : control_constant_t := "0000001100100";
    constant ADDI_SIGNALS   : control_constant_t := "0000100000100";
    constant LSR_SIGNALS    : control_constant_t := "1010100000100";
    constant LSL_SIGNALS    : control_constant_t := "1100100000100";

begin

    process(clock)
    
        -- Need to OR the constant patterns with branch taken signal based on input
        -- control signal ports.
        variable branch_setter : std_logic := '0';
    
        -- Need variables that store OR'd signals to preserve bit ordering.
        variable br_or : std_logic_vector(12 downto 0) := BR_SIGNALS;
        variable b_or  : std_logic_vector(12 downto 0) := B_SIGNALS;
        variable bl_or : std_logic_vector(12 downto 0) := BL_SIGNALS;
    
    begin

        if (rising_edge(clock)) then
        
            -- Set branch based on input condition from instruction and condition in PC.
            if (in_condition = no_condition) then
                branch_setter := '1';
            elsif (in_condition = equal_to and pc_condition(0) = '1') then
                branch_setter := '1';    
            elsif (in_condition = less_than and pc_condition(1) = '1') then
                branch_setter := '1';
            elsif (in_condition = greater_than and pc_condition(1) = '0' and pc_condition(0) = '0') then
                branch_setter := '1';
            else
                branch_setter := '0';
            end if;
    
            -- OR in the branch control signal.
            br_or(0) := branch_setter;
            b_or(0)  := branch_setter;
            bl_or(0) := branch_setter;
        
            case op_code is
                
                -- Decode instruction.
                when add_op     => control_signals <= control_signal_bus(ADD_SIGNALS);
                when sub_op     => control_signals <= control_signal_bus(SUB_SIGNALS);
                when str_op     => control_signals <= control_signal_bus(STR_SIGNALS);
                when ldr_op     => control_signals <= control_signal_bus(LDR_SIGNALS);
                when and_op     => control_signals <= control_signal_bus(AND_SIGNALS);
                when or_op      => control_signals <= control_signal_bus(OR_SIGNALS);
                when not_op     => control_signals <= control_signal_bus(NOT_SIGNALS);
                when cmp_op     => control_signals <= control_signal_bus(CMP_SIGNALS);
                when br_op      => control_signals <= control_signal_bus(br_or);
                when b_op       => control_signals <= control_signal_bus(b_or);
                when bl_op      => control_signals <= control_signal_bus(bl_or);
                when loadil_op  => control_signals <= control_signal_bus(LOADIL_SIGNALS);
                when loadiu_op  => control_signals <= control_signal_bus(LOADIU_SIGNALS);
                when addi_op    => control_signals <= control_signal_bus(ADDI_SIGNALS);
                when lsr_op     => control_signals <= control_signal_bus(LSR_SIGNALS);
                when lsl_op     => control_signals <= control_signal_bus(LSL_SIGNALS);
    
            end case;

        end if;

    end process;

end behavioral;