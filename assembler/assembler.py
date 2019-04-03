op_to_machine_code_table = {"add":     0,
                            "sub":     1,
                            "str":     2,
                            "ldr":     3,
                            "and":     4,
                            "or":      5,
                            "not":     6,
                            "cmp":     7,
                            "br":      8,
                            "b":       9,
                            "bl":      10,
                            "loadil":  11,
                            "loadiu":  12,
                            "addi":    13,
                            "lsr":     14,
                            "lsl":     15}


def assembly_to_machine_code(instruction):
    """
    Expects input of the form "<op> <operand_1,operand_2,...,operand_n".
    """

    # Make output have function scope.
    machine_code_output = ""

    # Extract op and operands.
    op, operands = instruction.split(' ', 1)
    
    # Strip commas from operands, and split operands
    operands = operands.replace(',', ' ').split()

    # Replace register numbers with numbers.
    for i in range(0, len(operands)):
        if operands[i][0] == "r":
            operands[i] = operands[1:]

    # If there is one operand, then it is J-type. Add condition as operand.
    if len(operands) == 1:
        if op == "b":
            operands.insert(0, "0")
        elif op == "beq":
            operands.insert(0, "1")
        elif op == "blt":
            operands.insert(0, "2")
        elif op == "bgt":
            operands.insert(0, "3")

    # Convert op to lower four bits of machine code - treat instructions with 3 and 2 operands differently.
    if len(operands) == 3:
        machine_code_output = "{0:04b}".format(int(operands[2])) + "{0:04b}".format(int(operands[1])) \
                            + "{0:04b}".format(int(operands[0])) + "{0:04b}".format(op_to_machine_code_table[op])

    elif len(operands) == 2:

        # If first operand is longer, then it is J-type.
        if len(operands[0]) > len(operands[1]):


    else:
        print("Error.")



