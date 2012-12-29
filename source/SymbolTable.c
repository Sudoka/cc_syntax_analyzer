///////////////////////////////////////////////////////////
/*
 * File Name:       SymbolTable.c
 * Instructor:      Prof. Mohamed Zahran
 * Grader:          Robert Soule
 * Author:          Shen Li
 * UID:             N14361265
 * Department:      Computer Science
 * Note:            This SymbolTable.c file includes
 *                  Process Symbol Table Functions.
*/
///////////////////////////////////////////////////////////

//////////Head File//////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SyntaxAnalyzer.h"

//////////Function Definition//////////
/*  Initialize Symbol Table Function
    Variable Definition:
    -- table: symbol table
    -- name: symbol table name
    Return Value: NULL
*/
void initSymbolTable(SYMREC* table, const char* name){
    //Initialize head node
    if (name != NULL){
        table->name = (char*)malloc(strlen(name) + 1);
        table->name = strdup(name);
    }
    else{
        table->name = NULL;
    }
    table->id_type = 0;
    table->value.type = NULL;
    table->location = NULL;
    table->next = NULL;

    return;
}

/*  Free Symbol Table Function
    Variable Definition:
    -- table: symbol table
    Return Value: NULL
*/
void freeSymbolTable(SYMREC* table){
    SYMREC  *node;      //_symrec struct node

    //Initialize node
    node = table->next;
    //Free all node in symbol table link chain
    while (node != NULL){
        //Free all node in value.list
        if ((node->id_type == PROCEDURE_DECLARATION)
                || (node->id_type == FUNCTION_DECLARATION)){
            //Recursive
            freeSymbolTable(node->value.list);
        }
        table->next = node->next;
        free(node->location);
        free(node);
        node = table->next;
    }
    //Free symbol table head node
    free(table);

    return;
}

/*  Check Identifier in Symbol Table Function
    Variable Definition:
    -- table: symbol table
    -- name: identifier name
    -- type: identifier classic
    -- column: identifier column number
    Return Value: if identifier exists, return false; else return true
*/
bool checkSymbolTable(  const SYMREC*   table,
                        const char*     name,
                        u_int16         type,
                        const SYMLOC*   location){
    SYMREC  *node;      //identifier _symrec struct node

    //Check identifier in symbol table
    for (node = table->next; node != NULL; node = node->next){
        //Find the same name in symbol table
        if (strcmp(name, node->name) == 0){
            //Based on the identifier classic
            switch (type){
                case DECLARATION_LEFT:
                    //Output multiple declaration error
                    fprintf(stderr, "Line %u:%u : Multiple Declaration of Identifier '%s'\n",   location->line,
                                                                                                location->column,
                                                                                                name);
                    break;
                case PROCEDURE_DECLARATION:
                    //Output multiple declaration error
                    fprintf(stderr, "Line %u:%u : Multiple Declaration of Procedure '%s'\n",    location->line,
                                                                                                location->column,
                                                                                                name);
                    break;
                case FUNCTION_DECLARATION:
                    //Output multiple declaration error
                    fprintf(stderr, "Line %u:%u : Multiple Declaration of Function '%s'\n", location->line,
                                                                                            location->column,
                                                                                            name);
                    break;
                default:
                    break;
            }
            
            return false;
        }
    }
    
    //Based on the identifier classic if we could not search
    switch (type){
        case PROCEDURE_REFERENCE:
            //Output undefined error
            fprintf(stderr, "Line %u:%u : Undefined Procedure Reference '%s'\n",    location->line,
                                                                                    location->column,
                                                                                    name);
            break;
        case FUNCTION_REFERENCE:
            //Output undefined error
            fprintf(stderr, "Line %u:%u : Undefined Function Reference '%s'\n", location->line,
                                                                                location->column,
                                                                                name);
            break;
        case VARIABLE_REFERENCE:
            //Output undefined error
            fprintf(stderr, "Line %u:%u : Undefined Variable Reference '%s'\n", location->line,
                                                                                location->column,
                                                                                name);
            break;
        default:
            break;
    }

    return true;
}

/*  Put Identifier into Symbol Table Function
    Variable Definition:
    -- table: symbol table
    -- list: identifier _symrec struct list
    Return Value: NULL
*/
void putSymbolTable(SYMREC* table, SYMREC* list){
    SYMREC  *node;      //identifier _symrec struct node

    //Initialize node
    node = list;
    //Put list into Symbol Table
    while (node != NULL){
        //Delete the first node in list
        list = node->next;
        node->next = NULL;
        //First check identifier in symbol table
        if (checkSymbolTable(table, node->name, node->id_type, node->location)){
            //Put the identifier into Symbol Table
            node->next = table->next;
            table->next = node;
        }
        else{
            //Delete identifier node
            free(node);
        }
        //Set node as the first node in list
        node = list;
    }
    return;
}

/*  Output Symbol Table Function
    Variable Definition:
    -- stream: output file stream
    Return Value: NULL
*/
void outputSymbolTable(FILE *stream){
    SYMREC  *node_g;        //identifier _symrec struct node
    SYMREC  *node_p;        //identifier _symrec struct node

    //Output Symbol Table
    for (node_g = symbol_table->next; node_g != NULL; node_g = node_g->next){
        //Identifier for Function & Procedure
       if ((node_g->id_type == FUNCTION_DECLARATION)
               || (node_g->id_type == PROCEDURE_DECLARATION)){
            fprintf(stream, "%15s    %2u %15u\n",   node_g->name,
                                                    node_g->id_type,
                                                    node_g->value.list->id_type);
            //Output identifier in function or procedure
            for (node_p = node_g->value.list->next; node_p != NULL; node_p = node_p->next){
                fprintf(stream, "   %15s %2u %15s\n",   node_p->name,
                                                        node_p->id_type,
                                                        node_p->value.type);
            }
       }
       //Identifier for others
       else{
            fprintf(stream, "%15s    %2u %15s\n",   node_g->name,
                                                    node_g->id_type,
                                                    node_g->value.type);
       }
    }

    return;
}

/*  Set Identifier Property Function
    Variable Definition:
    -- list: list of identifier
    -- type: identifier classic
    -- value: identifier type
    -- child: identifier child _symrec struct list
    Return Value: NULL
*/
void setIdentifier( SYMREC*     list,
                    u_int16     type,
                    const char  *value,
                    SYMREC*     child){
    SYMREC  *node;      //identifier _symrec struct node

    //Set identifier in the list
    for (node = list; node != NULL; node = node->next){
        //Assign node id_type
        node->id_type = type;
        //Assign node value
        if ((value == NULL) && (child == NULL)){
            node->value.type = NULL;
        }
        else if (value != NULL){
            node->value.type = strdup(value);
        }
        else{
            node->value.list = child;
        }
    }

    return;                    
}
