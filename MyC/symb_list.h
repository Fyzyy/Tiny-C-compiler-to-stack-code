#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct symb_list {
    char *name;
    struct symb_list *next;
};


struct symb_list *create_node(char *name);

void append_node(struct symb_list **head, char *name);

void print_list(struct symb_list *head);

void free_list(struct symb_list *head);