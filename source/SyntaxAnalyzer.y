/*
    File Name:      SyntaxAnalyzer.y
    Instructor:     Prof. Mohamed Zahran
    Grader:         Robert Soule
    Author:         Shen Li
    UID:            N14361265
    Department:     Computer Science
    Note:           This SyntaxAnalyzer.y file includes
                    Rule Definitions and User Definitions.
*/

/*Prologue*/
%{
    /*Head File*/
    #include <stdio.h>
    #include <stdlib.h>
    #include "SyntaxAnalyzer.h"
    #include "lex.yy.c"

    /*Variable Definition*/
    SYMREC  *symbol_table;          //symbol table link chain
%}

/*Declarations*/
%union {
    double      dval;       //number type
    char        cval;       //symbol type
    char        *sval;      //identifer type
    SYMREC      *symptr;    //symbol table pointer
}

%start  program

%token  <sval> AND PBEGIN FORWARD DIV DO ELSE END FOR FUNCTION IF ARRAY MOD NOT OF OR PROCEDURE PROGRAM RECORD THEN TO TYPE VAR WHILE
%token  <dval> NUMBER
%token  <sval> STRING
%token  <symptr> ID
%token  <cval> PLUS MINUS MULTI DIVIS
%token  <sval> ASSIGNOP
%token  <cval> LT EQ GT
%token  <sval> LE GE NE
%token  <cval> LPARENTHESIS RPARENTHESIS LBRACKET RBRACKET
%token  <cval> DOT COMMA COLON SEMICOLON
%token  <sval> DOTDOT

%type   <dval> constant
%type   <symptr> type
%type   <symptr> identifier_list
%type   <symptr> formal_parameter_list formal_parameter_list_section

%right  ASSIGNOP
%left   PLUS MINUS OR
%left   MULTI DIVIS DIV MOD AND
%right  POS NEG
%nonassoc   LT EQ GT LE GE NE

/*Grammer Rules*/
%%

program :   PROGRAM ID SEMICOLON type_definitions variable_declarations subprogram_declarations compound_statement DOT
                {
                    fprintf(yyout, "program -> %s %s%c type_definitions variable_declarations subprogram_declarations compound_statement%c\n",  $1,
                                                                                                                                                $2->name,
                                                                                                                                                $3,
                                                                                                                                                $8);
                    setIdentifier($2, DECLARATION_LEFT, $1, NULL);
                    putSymbolTable(symbol_table, $2);
                    YYACCEPT;
                }
        ;
type_definitions    :   /*empty*/                   {fprintf(yyout, "type_definitions -> /*empty*/\n");}
                    |   TYPE type_definition_list   {fprintf(yyout, "type_definitions -> %s type_definition_list\n", $1);}
                    ;
type_definition_list    :   type_definition_list type_definition SEMICOLON  {fprintf(yyout, "type_definition_list -> type_definition_list type_definition%c\n", $3);}
                        |   type_definition SEMICOLON                       {fprintf(yyout, "type_definition_list -> type_definition;%c\n", $2);}
                        ;
variable_declarations   :   /*empty*/                       {fprintf(yyout, "variable_declarations -> /*empty*/\n");}
                        |   VAR variable_declaration_list   {fprintf(yyout, "variable_declarations -> %s variable_declaration_list\n", $1);}
                        ;
variable_declaration_list   :   variable_declaration_list variable_declaration SEMICOLON
                                    {fprintf(yyout, "variable_declaration_list -> variable_declaration_list variable_declaration%c\n", $3);}
                            |   variable_declaration SEMICOLON
                                    {fprintf(yyout, "variable_declaration_list -> variable_declaration%c\n", $2);}
                            ;
subprogram_declarations :   /*empty*/
                                {fprintf(yyout, "subprogram_declarations -> /*empty*/\n");}
                        |   procedure_declaration SEMICOLON subprogram_declarations
                                {fprintf(yyout, "subprogram_declarations -> procedure_declaration%c subprogram_declarations\n", $2);}
                        |   function_declaration SEMICOLON subprogram_declarations
                                {fprintf(yyout, "subprogram_declarations -> function_declaration%c subprogram_declarations\n", $2);}
                        ;
type_definition :   ID EQ type
                        {
                            fprintf(yyout, "type_definition -> %s %c type\n", $1->name, $2);
                            setIdentifier($1, DECLARATION_LEFT, $3->name, NULL);
                            putSymbolTable(symbol_table, $1);
                            setIdentifier($3, DECLARATION_RIGHT, NULL, NULL);
                            putSymbolTable(symbol_table, $3);
                        }
                ;
variable_declaration    :   identifier_list COLON type
                                {
                                    fprintf(yyout, "variable_declaration -> identifier_list%c type\n", $2);
                                    setIdentifier($1, DECLARATION_LEFT, $3->name, NULL);
                                    putSymbolTable(symbol_table, $1);
                                    setIdentifier($3, DECLARATION_RIGHT, NULL, NULL);
                                    putSymbolTable(symbol_table, $3);
                                }
                        ;
procedure_declaration   :   PROCEDURE ID LPARENTHESIS formal_parameter_list RPARENTHESIS SEMICOLON declaration_body
                                {
                                    fprintf(yyout, "procedure_declaration -> %s %s %cformal_parameter_list%c%c declaration_body\n", $1,
                                                                                                                                    $2->name,
                                                                                                                                    $3,
                                                                                                                                    $5,
                                                                                                                                    $6);
                                    countParameter($4);
                                    setIdentifier($2, PROCEDURE_DECLARATION, NULL, $4);
                                    putSymbolTable(symbol_table, $2);
                                }
                        ;
function_declaration    :   FUNCTION ID LPARENTHESIS formal_parameter_list RPARENTHESIS COLON result_type SEMICOLON declaration_body
                                {
                                    fprintf(yyout, "function_declaration -> %s %s %cformal_parameter_list%c%c result_type%c declaration_body\n",    $1,
                                                                                                                                                    $2->name,
                                                                                                                                                    $3,
                                                                                                                                                    $5,
                                                                                                                                                    $6,
                                                                                                                                                    $8);
                                    countParameter($4);
                                    setIdentifier($2, FUNCTION_DECLARATION, NULL, $4);
                                    putSymbolTable(symbol_table, $2);
                                }
                        ;
declaration_body    :   block       {fprintf(yyout, "declaration_body -> block\n");}
                    |   FORWARD     {fprintf(yyout, "declaration_body -> %s\n", $1);}
                    ;
formal_parameter_list   :   /*empty*/
                                {
                                    fprintf(yyout, "formal_parameter_list -> /*empty*/\n");
                                    $$ = NULL;
                                }
                        |   formal_parameter_list_section
                                {
                                    fprintf(yyout, "formal_paramter_list -> formal_parameter_list_section\n");
                                    $$ = $1;
                                }
                        ;
formal_parameter_list_section   :   formal_parameter_list_section SEMICOLON identifier_list COLON type
                                        {
                                            fprintf(yyout, "formal_parameter_list_section -> formal_parameter_list_section%c identifier_list%c type\n", $2, $4);
                                            $$ = $1;
                                            setIdentifier($3, DECLARATION_LEFT, $5->name, NULL);
                                            putSymbolTable($$, $3);
                                            setIdentifier($5, DECLARATION_RIGHT, NULL, NULL);
                                            putSymbolTable(symbol_table, $5);
                                        }
                                |   identifier_list COLON type
                                        {
                                            fprintf(yyout, "formal_parameter_list_section -> identifier_list%c type\n", $2);
                                            $$ = (SYMREC*)malloc(sizeof(SYMREC));
                                            initSymbolTable($$, NULL);
                                            setIdentifier($1, DECLARATION_LEFT, $3->name, NULL);
                                            putSymbolTable($$, $1);
                                            setIdentifier($3, DECLARATION_RIGHT, NULL, NULL);
                                            putSymbolTable(symbol_table, $3);
                                        }
                                ;
block   :   variable_declarations compound_statement    {fprintf(yyout, "block -> variable_declarations compound_statement\n");}
        ;
compound_statement  :   PBEGIN statement_sequence END   {fprintf(yyout, "compound_statement -> %s statement_sequence %s\n", $1, $3);}
                    ;
statement_sequence  :   statement_sequence SEMICOLON statement  {fprintf(yyout, "statement_sequence -> statement_sequence%c statement\n", $2);}
                    |   statement                               {fprintf(yyout, "statement_sequence -> statement\n");}
                    ;
statement   :   open_statement          {fprintf(yyout, "statement -> open_statement\n");}
            |   closed_statement        {fprintf(yyout, "statement -> closed_statement\n");}
            ;
open_statement  :   open_if_statement       {fprintf(yyout, "open_statement -> open_if_statement\n");}
                |   open_while_statement    {fprintf(yyout, "open_statement -> open_while_statement\n");}
                |   open_for_statement      {fprintf(yyout, "open_statement -> open_for_statement\n");}
                ;
closed_statement    :   /*empty*/                   {fprintf(yyout, "closed_statement -> /*empty*/\n");}
                    |   assignment_statement        {fprintf(yyout, "closed_statement -> assignment_statement\n");}
                    |   procedure_statement         {fprintf(yyout, "closed_statement -> procedure_statement\n");}
                    |   compound_statement          {fprintf(yyout, "closed_statement -> compound_statment\n");}
                    |   closed_if_statement         {fprintf(yyout, "closed_statement -> closed_if_statement\n");}
                    |   closed_while_statement      {fprintf(yyout, "closed_statement -> closed_while_statement\n");}
                    |   closed_for_statement        {fprintf(yyout, "closed_statement -> closed_for_statement\n");}
                    ;
open_if_statement   :   IF expression THEN statement
                            {fprintf(yyout, "open_if_statement -> %s expression %s statement\n", $1, $3);}
                    |   IF expression THEN closed_statement ELSE open_statement
                            {fprintf(yyout, "open_if_statement -> %s expression %s closed_statement %s open_statement\n", $1, $3, $5);}
                    ;
closed_if_statement :   IF expression THEN closed_statement ELSE closed_statement
                            {fprintf(yyout, "closed_if_statement -> %s expression %s closed_statement %s closed_statement\n", $1, $3, $5);}
                    ;
open_while_statement    :   WHILE expression DO open_statement      {fprintf(yyout, "open_while_statement -> %s expression %s open_statement\n", $1, $3);}
                        ;
closed_while_statement  :   WHILE expression DO closed_statement    {fprintf(yyout, "closed_while_statement -> %s expression %s closed_statement\n", $1, $3);}
                        ;
open_for_statement  :   FOR ID ASSIGNOP expression TO expression DO open_statement
                            {
                                fprintf(yyout, "open_for_statement -> %s %s %s expression %s expression %s open_statement\n",   $1,
                                                                                                                                $2->name,
                                                                                                                                $3,
                                                                                                                                $5,
                                                                                                                                $7);
                                setIdentifier($2, VARIABLE_REFERENCE, NULL, NULL);
                                putSymbolTable(symbol_table, $2);
                            }
                    ;
closed_for_statement    :   FOR ID ASSIGNOP expression TO expression DO closed_statement
                                {
                                    fprintf(yyout, "closed_for_statement -> %s %s %s expression %s expression %s closed_statement\n",   $1,
                                                                                                                                        $2->name,
                                                                                                                                        $3,
                                                                                                                                        $5,
                                                                                                                                        $7);
                                    setIdentifier($2, VARIABLE_REFERENCE, NULL, NULL);
                                    putSymbolTable(symbol_table, $2);
                                }
                        ;
assignment_statement    :   variable ASSIGNOP expression    {fprintf(yyout, "assignment_statement -> variable %s expression\n", $2);}
                        ;
procedure_statement :   ID LPARENTHESIS actual_parameter_list RPARENTHESIS
                            {
                                fprintf(yyout, "procedure_statement -> %s %cactual_parameter_list%c\n", $1->name, $2, $4);
                                setIdentifier($1, PROCEDURE_REFERENCE, NULL, NULL);
                                putSymbolTable(symbol_table, $1);
                            }
                    ;
type    :   ID
                {
                    fprintf(yyout, "type -> %s\n", $1->name);
                    $$ = $1;
                }
        |   ARRAY LBRACKET constant DOTDOT constant RBRACKET OF type
                {
                    fprintf(yyout, "type -> %s %c%.3f %s %.3f%c %s type\n", $1, $2, $3, $4, $5, $6, $7);
                    char    *s = (char*)malloc(strlen($8->name) + strlen($1) + 3);
                    sprintf(s, "%s%c%s%c", $8->name, $2, $1, $6);
                    $$ = $8;
                    $$->name = strdup(s);
                }
        |   RECORD field_list END
                {
                    fprintf(yyout, "type -> %s field_list %s\n", $1, $3);
                    $$ = (SYMREC*)malloc(sizeof(SYMREC));
                    initSymbolTable($$, $1);
                }
        ;
result_type :   ID
                    {
                        fprintf(yyout, "result_type -> %s\n", $1->name);
                        setIdentifier($1, DECLARATION_RIGHT, NULL, NULL);
                        putSymbolTable(symbol_table, $1);
                    }
            ;
field_list  :   /*empty*/               {fprintf(yyout, "field_list -> /*empty*/\n");}
            |   field_list_section      {fprintf(yyout, "field_list -> field_list_section\n");}
            ;
field_list_section  :   field_list_section SEMICOLON identifier_list COLON type
                            {
                                fprintf(yyout, "field_list_section -> field_list_section%c identifier_list%c type\n", $2, $4);
                                setIdentifier($3, DECLARATION_LEFT, $5->name, NULL);
                                putSymbolTable(symbol_table, $3);
                                setIdentifier($5, DECLARATION_RIGHT, NULL, NULL);
                                putSymbolTable(symbol_table, $5);
                            }
                    |   identifier_list COLON type
                            {
                                fprintf(yyout, "field_list_section -> identifier_list%c type\n", $2);
                                setIdentifier($1, DECLARATION_LEFT, $3->name, NULL);
                                putSymbolTable(symbol_table, $1);
                                setIdentifier($3, DECLARATION_RIGHT, NULL, NULL);
                                putSymbolTable(symbol_table, $3);
                            }
                    ;
constant    :   NUMBER                      {   fprintf(yyout, "constant -> %.3f\n", $1);       $$ = $1;    }
            |   PLUS NUMBER     %prec POS   {   fprintf(yyout, "constant -> %c%.3f\n", $1, $2); $$ = +$1;   }
            |   MINUS NUMBER    %prec NEG   {   fprintf(yyout, "constant -> %c%.3f\n", $1, $2); $$ = -$1;   }
            ;
expression  :   simple_expression                           {fprintf(yyout, "expression -> simple_expression\n");}
            |   simple_expression LT simple_expression      {fprintf(yyout, "expression -> simple_expression %c simple_expression\n", $2);}
            |   simple_expression LE simple_expression      {fprintf(yyout, "expression -> simple_expression %s simple_expression\n", $2);}
            |   simple_expression EQ simple_expression      {fprintf(yyout, "expression -> simple_expression %c simple_expression\n", $2);}
            |   simple_expression GE simple_expression      {fprintf(yyout, "expression -> simple_expression %s simple_expression\n", $2);}
            |   simple_expression GT simple_expression      {fprintf(yyout, "expression -> simple_expression %c simple_expression\n", $2);}
            |   simple_expression NE simple_expression      {fprintf(yyout, "expression -> simple_expression %s simple_expression\n", $2);}
            ;
simple_expression   :   simple_expression_list                      {fprintf(yyout, "simple_expression -> simple_expression_list\n");}
                    |   PLUS simple_expression_list     %prec POS   {fprintf(yyout, "simple_expression -> %csimple_expression_list\n", $1);}
                    |   MINUS simple_expression_list    %prec NEG   {fprintf(yyout, "simple_expression -> %csimple_expression_list\n", $1);}
                    ;
simple_expression_list  :   term                                {fprintf(yyout, "simple_expression_list -> term\n");}
                        |   simple_expression_list PLUS term    {fprintf(yyout, "simple_expression_list -> simple_expression_list%cterm\n", $2);}
                        |   simple_expression_list MINUS term   {fprintf(yyout, "simple_expression_list -> simple_expression_list%cterm\n", $2);}
                        |   simple_expression_list OR term      {fprintf(yyout, "simple_expression_list -> simple_expression_list %s term\n", $2);}
                        ;
term    :   factor              {fprintf(yyout, "term -> factor\n");}
        |   term MULTI factor   {fprintf(yyout, "term -> term%cfactor\n", $2);}
        |   term DIV factor     {fprintf(yyout, "term -> term %s factor\n", $2);}
        |   term DIVIS factor   {fprintf(yyout, "term -> term%cfactor\n", $2);}
        |   term MOD factor     {fprintf(yyout, "term -> term %s factor\n", $2);}
        |   term AND factor     {fprintf(yyout, "term -> term %s factor\n", $2);}
        ;
factor  :   NUMBER                                  {fprintf(yyout, "factor -> %.3f\n", $1);}
        |   STRING                                  {fprintf(yyout, "factor -> %s\n", $1);}
        |   variable                                {fprintf(yyout, "factor -> variable\n");}
        |   function_reference                      {fprintf(yyout, "factor -> function_reference\n");}
        |   NOT factor                              {fprintf(yyout, "factor -> %s factor\n", $1);}
        |   LPARENTHESIS expression RPARENTHESIS    {fprintf(yyout, "factor -> %cexpression%c\n", $1, $3);}
        ;
function_reference  :   ID LPARENTHESIS actual_parameter_list RPARENTHESIS
                            {
                                fprintf(yyout, "function_reference -> %s %cactual_parameter_list%c\n", $1->name, $2, $4);
                                setIdentifier($1, FUNCTION_REFERENCE, NULL, NULL);
                                putSymbolTable(symbol_table, $1);
                            }
                    ;
variable    :   ID component_selection
                    {
                        fprintf(yyout, "variable -> %s component_selection\n", $1->name);
                        setIdentifier($1, VARIABLE_REFERENCE, NULL, NULL);
                        putSymbolTable(symbol_table, $1);
                    }
            ;
component_selection :   /*empty*/
                            {fprintf(yyout, "component_selection -> /*empty*/\n");}
                    |   DOT ID component_selection
                            {
                                fprintf(yyout, "component_selection -> %c%s component_selection\n", $1, $2->name);
                                setIdentifier($2, VARIABLE_REFERENCE, NULL, NULL);
                                putSymbolTable(symbol_table, $2);
                            }
                    |   LBRACKET expression RBRACKET component_selection
                            {fprintf(yyout, "component_selection -> %cexpression%c component_selection\n", $1, $3);}
                    ;
actual_parameter_list   :   /*empty*/                       {fprintf(yyout, "actual_parameter_list -> /*empty*/\n");}
                        |   actual_parameter_list_section   {fprintf(yyout, "actual_parameter_list -> actual_parameter_list_section\n");}
                        ;
actual_parameter_list_section   :   actual_parameter_list_section COMMA expression
                                        {fprintf(yyout, "actual_parameter_list_section -> actual_parameter_list_section%c expression\n", $2);}
                                |   expression
                                        {fprintf(yyout, "actual_parameter_list_section -> expression\n");}
                                ;
identifier_list :   identifier_list COMMA ID
                                {
                                    fprintf(yyout, "identifier_list -> identifier_list%c %s\n", $2, $3->name);
                                    $$ = $3;
                                    $3->next = $1;
                                }
                        |   ID
                                {
                                    fprintf(yyout, "identifier_list -> %s\n", $1->name);
                                    $$ = $1;
                                }
                        ;

%%
/*Epilogue*/
/*  Main Function
    Variable Definition:
    -- argc: number of command arguments
    -- argv: each variable of command arguments(argv[0] is the path of execution file forever)
    Return Value: exit number
*/
int main(int argc, char *argv[]){
    //Test for correct number of arguments
    if (argc != 2){
        dieWithUserMessage("Parameter(s)", "<input file name>");
    }

    //Open file for reading input stream
    if ((yyin = fopen(argv[1], "r")) == NULL){
        dieWithUserMessage("fopen() failed", "Cannot open file to read input stream!");
    }
    //Open file for writing output rules
    if ((yyout = fopen(RULE_FILE, "w")) == NULL){
        dieWithUserMessage("fopen() failed", "Cannot open file to write rules!");
    }

    //Initialize symbol table
    symbol_table = (SYMREC*)malloc(sizeof(SYMREC));
    initSymbolTable(symbol_table, NULL);
    //Start syntax analysis
    do {
        yyparse();
    } while (!feof(yyin));
    
    //Open file for writing symbol table
    if ((yyout = fopen(SYMBOL_TABLE_FILE, "w")) == NULL){
        dieWithUserMessage("fopen() failed", "Cannot open file to write symbol table!");
    }
    //Output symbol table
    outputSymbolTable(yyout);

    //Free symbol table
    freeSymbolTable(symbol_table);
    //Close file stream
    fclose(yyin);
    fclose(yyout);

    return 0;
}

/*  Parser Error Function
    Variable Definition:
    -- detail: detail error message
    Return Value: NULL
*/
void yyerror(const char* detail){
    fprintf(stderr, "Line %u:%u : %s\n",    line_number,
                                            column_number,
                                            detail);

    return;
}

/*  Count Parameter Function
    Variable Definition:
    -- table: symbol table
    Return Value: NULL
*/
void countParameter(SYMREC* table){
    SYMREC  *node = table->next;    //identifier _symrec struct node
    u_int16 count = 0;              //parameter number

    //Count the parameter number
    while (node != NULL){
        count++;
        node = node->next;
    }
    //Set parameter number
    table->id_type = count;

    return;
}
