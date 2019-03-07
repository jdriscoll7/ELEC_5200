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

    -- Bus that packs all control signals like a C struct.
    type control_signal_bus_t is record
        c_alu_op    : std_logic_vector(2 downto 0);
        c_compare   : std_logic;
        c_i_type    : std_logic;
        c_fetch     : std_logic;
        c_mem_write : std_logic;
        c_link      : std_logic;
        c_reg_write : std_logic;
        c_mem_read  : std_logic;
        c_load_imm  : std_logic;
        c_upper_imm : std_logic;
        c_r_type    : std_logic;
        c_branch    : std_logic;
    end record control_signal_bus_t;

    -- Function interface for casting std_logic_vector to control_signal_bus_t.
    function control_signal_bus(x : in std_logic_vector) return control_signal_bus_t;

end package control_unit_package;


package body control_unit_package is

    -- Convert std_logic_vector to control signal bus (saves much code space).
    -- Note: assumes first three bits are alu_op.
    function control_signal_bus(x : in std_logic_vector) return control_signal_bus_t is

        variable output_bus : control_signal_bus_t;

    begin

        output_bus.c_alu_op    := x((x'length - 1) downto (x'length - 3));
        output_bus.c_compare   := x(10);
        output_bus.c_i_type    := x(9);
        output_bus.c_r_type    := x(8);
        output_bus.c_load_imm  := x(7);
        output_bus.c_upper_imm := x(6);
        output_bus.c_fetch     := x(5);
        output_bus.c_mem_read  := x(4);
        output_bus.c_mem_write := x(3);
        output_bus.c_reg_write := x(2);
        output_bus.c_link      := x(1);
        output_bus.c_branch    := x(0);

        return output_bus;

    end function control_signal_bus;
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
          condition         : in  condition_t;
          control_signals   : out control_signal_bus_t);

end control_unit;


-- Basically a massive switch statement that activates control signals
-- when they are needed by an instruction.
architecture behavioral of control_unit is

    -- Number of control signals can change after updates to design.
    constant num_control_SIGNALS : integer := 14;
    subtype control_constant_t is std_logic_vector((num_control_SIGNALS - 1) downto 0);

    -- This table is based on the tables created for the second project report.
    constant ADD_SIGNALS    : control_constant_t := "00000000000100";
    constant SUB_SIGNALS    : control_constant_t := "00100000000100";
    constant STR_SIGNALS    : control_constant_t := "00000000001000";
    constant LDR_SIGNALS    : control_constant_t := "00000000010100";
    constant AND_SIGNALS    : control_constant_t := "01000000000100";
    constant OR_SIGNALS     : control_constant_t := "01100000000100";
    constant NOT_SIGNALS    : control_constant_t := "10000000000100";
    constant CMP_SIGNALS    : control_constant_t := "00010000000000";
    constant BR_SIGNALS     : control_constant_t := "00000100000001";
    constant B_SIGNALS      : control_constant_t := "00000000000001";
    constant BL_SIGNALS     : control_constant_t := "00000000000111";
    constant LOADIL_SIGNALS : control_constant_t := "00000010000100";
    constant LOADIU_SIGNALS : control_constant_t := "00000011000100";
    constant ADDI_SIGNALS   : control_constant_t := "00001000000100";
    constant LSR_SIGNALS    : control_constant_t := "10101000000100";
    constant LSL_SIGNALS    : control_constant_t := "11001000000100";

begin

    process(op_code, condition)
    begin

        case op_code is
            when add_op     => control_SIGNALS <= control_signal_bus(ADD_SIGNALS);
            when sub_op     => control_SIGNALS <= control_signal_bus(SUB_SIGNALS);
            when str_op     => control_SIGNALS <= control_signal_bus(STR_SIGNALS);
            when ldr_op     => control_SIGNALS <= control_signal_bus(LDR_SIGNALS);
            when and_op     => control_SIGNALS <= control_signal_bus(AND_SIGNALS);
            when or_op      => control_SIGNALS <= control_signal_bus(OR_SIGNALS);
            when not_op     => control_SIGNALS <= control_signal_bus(NOT_SIGNALS);
            when cmp_op     => control_SIGNALS <= control_signal_bus(CMP_SIGNALS);
            when br_op      => control_SIGNALS <= control_signal_bus(BR_SIGNALS);
            when b_op       => control_SIGNALS <= control_signal_bus(B_SIGNALS);
            when bl_op      => control_SIGNALS <= control_signal_bus(BL_SIGNALS);
            when loadil_op  => control_SIGNALS <= control_signal_bus(LOADIL_SIGNALS);
            when loadiu_op  => control_SIGNALS <= control_signal_bus(LOADIU_SIGNALS);
            when addi_op    => control_SIGNALS <= control_signal_bus(ADDI_SIGNALS);
            when lsr_op     => control_SIGNALS <= control_signal_bus(LSR_SIGNALS);
            when lsl_op     => control_SIGNALS <= control_signal_bus(LSL_SIGNALS);

        end case;

    end process;

end behavioral;