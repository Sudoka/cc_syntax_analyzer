///////////////////////////////////////////////////////////
/*
 * File Name:       SyntaxAnalyzer.h
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This SyntaxAnalyzer.h file includes
 *                  variable, macro, structure, function
 *                  declaration and precompile.
*/
///////////////////////////////////////////////////////////

//////////Precompile//////////
#ifndef SYNTAX_H
#define SYNTAX_H

//////////Head File//////////
#include <stdbool.h>

//////////Macro Declaration//////////
#define RULE_FILE           "rules.out"
#define SYMBOL_TABLE_FILE   "symtable.out"

//////////Type Declaration//////////
typedef unsigned short  u_int16;
typedef unsigned int    u_int32;

//////////Enum Declaration//////////
enum    identifier_type{
    DECLARATION_LEFT = 1,
    DECLARATION_RIGHT,
    PROCEDURE_DECLARATION,
    PROCEDURE_REFERENCE,
    FUNCTION_DECLARATION,
    FUNCTION_REFERENCE,
    VARIABLE_REFERENCE,
};

//////////Struct Declaration//////////
/*Symbol Location Structure*/
typedef struct _symloc{
    u_int32 line;
    u_int16 column;
}SYMLOC;

/*Symbol Table Structure*/
typedef struct _symrec{
    char    *name;              //symbol name
    u_int16 id_type;            //sumbol type
    union{
        char    *type;          //identifer type
        struct _symrec  *list;  //function parameter number
    }value;                     //symbol type or parameter number
    SYMLOC  *location;          //symbol location
    struct _symrec  *next;      //link field
}SYMREC;

//////////Variable Declaration//////////
extern u_int32  line_number;
extern u_int16  column_number;
extern SYMREC   *symbol_table;

/////////Function Declaration//////////
void    dieWithUserMessage(const char* message, const char* detail);
void    dieWithSystemMessage(const char* message);
void    yyerror(const char* detail);
SYMREC* installID(void);
void    countParameter(SYMREC *table);
void    initSymbolTable(SYMREC* table, const char* name);
void    freeSymbolTable(SYMREC* table);
void    setIdentifier(  SYMREC*     list,
                        u_int16     type,
                        const char* value,
                        SYMREC*     child);
bool    checkSymbolTable(   const SYMREC*   table,
                            const char*     name,
                            u_int16         type,
                            const SYMLOC*   location);
void    putSymbolTable(SYMREC* table, SYMREC* list);
void    outputSymbolTable(FILE *stream);

#endif  //SYNTAX_H
