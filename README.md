cc_syntax_analyzer
==================

Syntax Analysis: Parser
Your tasks:
You will be using Bison parser generator.
Use this grammer with bison, together with your previous lexer.
At that point of the project, you need to generate the following:
    A file called rules.out that contains the head of each production rule recognized, one per line.
    Update the symbol table you built in the last time with the "type" of the identifier. For "functions", their tyoe is the number of arguments
    Then you print the whole table to a file (symtable.out), one entry per line.


1. The code was written under the Ubuntu Linux System (Version 11.10)
2. The Compiler version is GCC 4.6.1
3. I have written a "makefile" document
   So just type "make" command under current directory to compile source code.
   Also, type "make clean" under current directory to remove all files except source files. 
4. The format of running source code is as below:

    ./SyntaxAnalyzer <input file name>

   (1) The <input file name> argument is necessary;
   (2) The first default output file name is "rules.out"
       *This file stores grammar rules in format.
   (3) The second default output file name is "symtable.out";
       *This file stores symbol table information.
       *The first column is identifier name.
       *The second column is identifier classic.
            1 -- declaration left operand
            2 -- declaration right operand
            3 -- procedure declaration
            4 -- procedure reference
            5 -- function declaration
            6 -- function reference
            7 -- variable reference
       *The third column is type for variable or parameter number for procedure or function.
            For the latter case, the identifiers and its' type for formal parameter list store under the procedure or function identifier.
5. Some additional information about Syntax Analyzer
   *The Syntax Analyzer program could detect lexeme error, syntax error, and several semantic error.
        For lexeme error, output illegal character and it's location, then terminate program.
        For syntax error, output syntax error message and it's location, then continue to parse program until EOF.
        For semantic error, output semantic error message(multiple declaration, undefined, ...) and it's location, then continue to parse program until EOF.
   *Moreover, I add the "/" as division operation. Its token name is "DIVIS".
