import ply.lex as lex
import ply.yacc as yacc
import re


symbol_table = {}


tokens = ("INSTRUCTION",
          "LABEL")


def t_LABEL(t):
    r'.+:'

    symbol_table[t.value[:-1]] = str(t.lexer.lineno - 1)
    t.lexer.lineno = t.lexer.lineno - 1

    t.value = {'label': t.value[:-1]}


def t_INSTRUCTION(t):
    r'.+'
    
    # Extract tokens from instruction line.
    instruction_tokens = re.sub('[,]*[ ]+[,]*', ',', t.value).split(',')

    # Initialize value to dict.
    if instruction_tokens[0][0] == 'b':
        
        if len(instruction_tokens[0]) < 3:

            t.value = {'op'     : instruction_tokens[0],
                       'cond'   : 'none'}
        
        elif len(instruction_tokens[0]) == 3:
        
            t.value = {'op'     : instruction_tokens[0][0],
                       'cond'   : instruction_tokens[0][1:]}
        
        elif len(instruction_tokens[0]) == 4:
            
            t.value = {'op'     : instruction_tokens[0][0:2],
                       'cond'   : instruction_tokens[0][2:]}
        
    else:

        t.value = {'op': instruction_tokens[0]}
    
    # Pull out operands of instruction and put them into t.value.
    for i in range(1, len(instruction_tokens)):
    
        t.value['arg' + str(i - 1)] = instruction_tokens[i]
    
    # Add in all zeros for unused arg2 for not instruction.
    if t.value['op'] == 'not':
        t.value['arg2'] = '0'
    
    return t


def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)


def t_error(p):
    print("Syntax error at %s" %p.value)


# Ignore commas, spaces, and tabs.
t_ignore = ', \t'


# Build lexer.
lexer = lex.lex()


# Testing.
test_program = ""
with open('program.txt', 'r') as file:
    test_program = file.read()


# Instead of using parser, directly manipulate lextokens from lexer.

# Op code mappings.
op_code_mapping = {'add'   : '0000',
                   'sub'   : '0001', 
                   'str'   : '0010',
                   'ldr'   : '0011',
                   'and'   : '0100',
                   'or'    : '0101',
                   'not'   : '0110',
                   'cmp'   : '0111',
                   'br'    : '1000',
                   'b'     : '1001',
                   'bl'    : '1010',
                   'loadil': '1011',
                   'loadiu': '1100',
                   'addi'  : '1101',
                   'lsr'   : '1110',
                   'lsl'   : '1111'}
               
# Condition branch code mappings
conditional_mapping = {'none'   : '00',
                       'eq'     : '01',
                       'lt'     : '10',
                       'gt'     : '11'}
        
        
# Convert decimal number into n-bit binary number.
def decimal_to_binary_string(decimal, n_bits):

    output = ""

    if decimal[0:2] == '0x':
        output = ('{0:0'+ str(n_bits) + 'b}').format(int(decimal, 16))
    else:
        output = ('{0:0' + str(n_bits) + 'b}').format(int(decimal))

    return output


# Convert register into number.
def register_number_to_binary(register):

    output = ""

    if register[0] == 'r':
        output = '{0:04b}'.format(int(register[1:]))
    else:
        output = '{0:04b}'.format(int(register))

    return output

    


def generate_machine_code(token):

    output = ""
    opcode = op_code_mapping[token.value['op']]

    # Handle branches.
    if token.value['op'][0] == 'b':

        # Convert branch condition to binary.
        condition = conditional_mapping[token.value['cond']]
        
        # Handle register branches and other branches differently.
        if token.value['op'][0:2] == 'br':
        
            # Extract register number.
            register_number = register_number_to_binary(token.value['arg0'])
            
            # Form output binary.
            output = '0000' + register_number + '00' + condition
    
        else:
        
            # Extract branch address.
            branch_address = decimal_to_binary_string(symbol_table[token.value['arg0']], 10)
        
            # Form output binary.
            output = branch_address + condition
        
    # Compare instructions have different first argument.
    elif token.value['op'] == 'cmp':
    
        # Extract source registers from token.
        rs1 = register_number_to_binary(token.value['arg0'])
        rs2 = register_number_to_binary(token.value['arg1'])
        
        output = '0000' + rs1 + rs2
    
    # Loadiu and loadil have a weirdly sized constant.
    elif token.value['op'][0:4] == 'load':
        
        # Extract source register from token.
        rs1 = register_number_to_binary(token.value['arg0'])
        
        # Extract 8-bit constant.
        constant = decimal_to_binary_string(token.value['arg1'], 8)
        
        # Form output binary.
        output = rs1 + constant
        
    else:
    
        # Extract source and destination registers from token.
        rd  = register_number_to_binary(token.value['arg0'])
        rs1 = register_number_to_binary(token.value['arg1'])
        rs2 = register_number_to_binary(token.value['arg2'])

        output = rd + rs1 + rs2
            
    # Opcode always appended to end.
    return "\"" + (output + opcode)  + "\","
    


# Input test program to lexer.
lexer.input(test_program)

toks = []

while True:

    tok = lexer.token()

    if not tok:
        break

    toks.append(tok)


for token in toks:
    print(generate_machine_code(token))