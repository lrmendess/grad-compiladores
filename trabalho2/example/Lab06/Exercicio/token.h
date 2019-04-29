
#ifndef TOKEN_H
#define TOKEN_H

typedef enum {
    IF,
    THEN,
    ELSE,
    END,
    REPEAT,
    UNTIL,
    READ,
    WRITE,
    PLUS,
    MINUS,
    TIMES,
    OVER,
    EQ,
    LT,
    LPAREN,
    RPAREN,
    SEMI,
    ASSIGN,
    NUM,
    ID,
    ENDFILE
} TokenType;

#endif // TOKEN_H
