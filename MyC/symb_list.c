
#include "symb_list.h"


struct symb_list *create_node(char *name) {
    struct symb_list *new_node = malloc(sizeof(struct symb_list));
    if (new_node == NULL) {
        fprintf(stderr, "Memory allocation error\n");
        exit(EXIT_FAILURE);
    }
    new_node->name = strdup(name);
    new_node->next = NULL;
    return new_node;
}

void append_node(struct symb_list **head, char *name) {
    struct symb_list *new_node = create_node(name);
    if (*head == NULL) {
        *head = new_node;
    } else {
        struct symb_list *current = *head;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = new_node;
    }
}

void print_list(struct symb_list *head) {
    struct symb_list *current = head;
    while (current != NULL) {
        printf("Name: %s\n", current->name);
        current = current->next;
    }
    printf("\n");
}

void free_list(struct symb_list *head) {
    struct symb_list *current = head;
    while (current != NULL) {
        struct symb_list *next_node = current->next;
        free(current->name);
        free(current);
        current = next_node;
    }
}