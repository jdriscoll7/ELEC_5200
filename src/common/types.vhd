-- File: types.vhd
--
-- Declares some types common across implementations.


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
                      
end types;