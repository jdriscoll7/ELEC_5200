import ply.lex as lex
import re


symbol_table = {}


tokens = ("ADD",
          "SUB",
          "STR",
          "LDR",
          "AND",
          "OR",
          "NOT",
          "CMP",
          "BR",
          "B",
          "BL",
          "LOADIL",
          "LOADIU",
          "ADDI",
          "LSR",
          "LSL")



# Regular expression rules for tokens.
def t_ADD(t):
    r'add.+'
    
    return t


def t_SUB(t):
    r'sub.+'
    
    return t
     
     
def t_STR(t):
    r'str.+'
    
    return t
     
     
def t_LDR(t):
    r'ldr.+'
    
    return t
     
     
def t_AND(t):
    r'and.+'
    
    return t


def t_OR(t):
    r'or.+'
    
    return t  


def t_NOT(t):
    r'not.+'
    
    return t


def t_CMP(t):
    r'cmp.+'
    
    return t


def t_LOADIL(t):
    r'loadil.+'

    instruction, rd, constant = re.sub('[,]*[ ]+[,]*', ',', t.value).split(',')

    t.value = {"value"      : t.value,
               "rd"         : rd[1:],
               "constant"   : constant}
    return t


def t_LOADIU(t):
    r'loadiu.+'
    
    return t


def t_ADDI(t):
    r'addi.+'
    
    return t


def t_LSR(t):
    r'lsr.+'
    
    return t


def t_LSL(t):
    r'lsl.+'
    
    return t


def t_BR(t):
    r'br(eq|lt|gt)* \S+$'
    
    branch, register = t.value.split(' ')
    
    t.value = {"value"      : t.value, 
               "condition"  : branch[2:],
               "rd"         : register[1:]}
    return t


def t_B(t):
    r'b(eq|lt|gt)* \S+$'
    
    branch, label = t.value.split(' ')
    symbol_table[label] = t.lexer.lineno
    
    t.value = {"value"      : t.value, 
               "condition"  : branch[1:],
               "label"      : label,
               "address"    : symbol_table[label]}
    return t


def t_BL(t):
    r'bl(eq|lt|gt)* \S+$'
    
    branch, label = re.sub('[,]*[ ]+[,]*', ',', t.value).split(',')
    symbol_table[label] = t.lexer.lineno
    
    t.value = {"value"      : t.value, 
               "condition"  : branch[2:],
               "label"      : label,
               "address"    : symbol_table[label]}
    return t
    

def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)


# Ignore commas, spaces, and tabs.
t_ignore = ', \t'


# Build lexer.
lexer = lex.lex()


# Testing.
test_program = (
'''loadil  r0, 1
lsl     r0, r0, 10
loadil  r1, 12
sub     r0, r0, r1
loadil  r2, 6
loadil  r3, 8
or      r2, r2, r3
not     r2, r2
loadiu  r3, 0x55
lsr     r3, r3, 8
and     r2, r2, r3
add     r0, r0, r2
beq     just_a_new_label''')


# Input test program to lexer.
lexer.input(test_program)

                
while True:
    tok = lexer.token()
    if not tok:
        break
    print(tok)