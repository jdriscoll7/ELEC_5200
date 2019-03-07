-- File: types.vhd
--
-- Declares some types common across implementations.


package types is

    -- ALU operating type definitions.
    type alu_op_t is (alu_add, 
                      alu_sub, 
                      alu_and, 
                      alu_or,
                      alu_not,
                      alu_shift_right,
                      alu_shift_left);

end types;