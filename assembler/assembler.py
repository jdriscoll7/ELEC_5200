import ply.lex as lex


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
          "LSL",
          "LABEL",
          "CONSTANT",
          "REGISTER")


# Regular expression rules for tokens.
t_ADD       = r'add'
t_SUB       = r'sub'
t_STR       = r'str'
t_LDR       = r'ldr'
t_AND       = r'and'
t_OR        = r'or'    
t_NOT       = r'not'
t_CMP       = r'cmp'
t_BR        = r'br(eq|lt|gt)*'
t_B         = r'b(eq|lt|gt)*'
t_BL        = r'bl(eq|lt|gt)*'
t_LOADIL    = r'loadil'
t_LOADIU    = r'loadiu'
t_ADDI      = r'addi'
t_LSR       = r'lsr'
t_LSL       = r'lsl'
t_CONSTANT  = r' (0x[A-F0-9]+|\d+)'


def t_REGISTER(t):
    r'r\d{1,2}'
    t.value = (t.value, t.value[1:])
    return t


def t_LABEL(t):
    r'\S+$'
    symbol_table[t.value] = len(symbol_table)
    t.value = (t.value, symbol_table[t.value])
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
add     r0, r0, r2''')


# Input test program to lexer.
lexer.input(test_program)

                
while True:
    tok = lexer.token()
    if not tok:
        break
    print(tok)