PL0 - Tiny programming language interpreter
===========================================

Interpreter for a small toy language.

Usage
-----

```
pl0 path/to/program
```

Sample Programs
---------------

#### Hello World

```
p "Hello World"
```

#### Arithmetics

```
p 2 + 2
foo = 4
bar = 24
baz = (foo + bar) / 3
p baz
```

#### Conditionals

```
bar = 2

while (bar < 99) {
    bar = bar + 2

    if (bar == 8) {
        p "blabla"
    } else {
        p "dog"
    }

    p bar
}
```

Grammar
-------

```
program := statement (t statement)*
t := '\n'
statement := if_else_statement | while_statement | assignment | print_statement
if_else_statement := 'if' '(' exp ')' '{' statement* '}' 'else' '{' statement* '}'
while_statement := 'while' '(' exp ')' '{' statement* '}'
assignment := identifier '=' exp
print_statement := 'p' exp
exp := add_exp ( ( '<' | '>' | '<=' | '>=' | '==' ) add_exp )?
add_exp := mult_exp ( ( '+' | '-' ) mult_exp )*
mult_exp := prefix_exp ( ( '*' | '/' ) prefix_exp )*
prefix_exp := not_exp | prim_exp
not_exp := ('!')* exp
prim_exp := identifier | paren_exp | int_lit | true_lit | false_lit | string_lit
paren_exp := '(' exp ')'
int_lit := [0-9] [0-9]*
true_lit := 'true'
false_lit := 'false'
string_lit := '"' (!('"'))* '"'
```
