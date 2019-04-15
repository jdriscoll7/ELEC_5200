-- File: types.vhd
--
-- Declares some types common across implementations.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package types is
    
    -- Op code enumeration.
    type op_code_t is (add_op,
                       sub_op,
                       str_op,
                       ldr_op,
                       and_op,
                       or_op,
                       not_op,
                       cmp_op,
                       br_op,
                       b_op,
                       bl_op,
                       loadil_op,
                       loadiu_op,
                       addi_op,
                       lsr_op,
                       lsl_op);

    -- ALU operating type definitions.
    type alu_op_t is (alu_add, 
                      alu_sub, 
                      alu_and, 
                      alu_or,
                      alu_not,
                      alu_shift_right,
                      alu_shift_left);

    -- Conditional branch types.
    type condition_t is (no_condition,
                         equal_to,
                         less_than,
                         greater_than);
                         
    -- Bus that packs all control signals like a C struct.
    type control_signal_bus_t is record
        c_alu_op    : std_logic_vector(2 downto 0);
        c_compare   : std_logic;
        c_i_type    : std_logic;
        c_r_type    : std_logic;
        c_load_imm  : std_logic;
        c_upper_imm : std_logic;
        c_mem_read  : std_logic;
        c_mem_write : std_logic;
        c_reg_write : std_logic;
        c_link      : std_logic;
        c_branch    : std_logic;
        size        : integer;
    end record control_signal_bus_t;
        
     -- Used for the data memory signals.
    type memory_input_bus_t is record
        instruction_read_bus    : std_logic_vector(15 downto 0);
        data_read_bus           : std_logic_vector(15 downto 0);
    end record memory_input_bus_t;
    
    -- Used for the instruction memory signals.
    type memory_output_bus_t is record
        instruction_address_bus : std_logic_vector(9 downto 0);
        data_address_bus        : std_logic_vector(15 downto 0);
        data_write_bus          : std_logic_vector(15 downto 0);
        data_write_enable       : std_logic;
    end record memory_output_bus_t;
        
    -- Casting functions for custom types.
    function to_op_code_t(code : in std_logic_vector) return op_code_t;
    function to_alu_op_t(code : in std_logic_vector) return alu_op_t;
    function to_condition_t(code : in std_logic_vector) return condition_t;
        
end types;


package body types is


    function to_op_code_t(code : in std_logic_vector) return op_code_t is
    begin
    
        return op_code_t'val(to_integer(unsigned(code)));    
    
    end function to_op_code_t;
    
    
    function to_alu_op_t(code : in std_logic_vector) return alu_op_t is
    begin
    
        return alu_op_t'val(to_integer(unsigned(code)));
    
    end function to_alu_op_t;

    
    function to_condition_t(code : in std_logic_vector) return condition_t is
    begin
    
        return condition_t'val(to_integer(unsigned(code)));
    
    end function to_condition_t;
    
end package body types;













