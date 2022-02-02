#include<stdio.h>
#include<stdlib.h>

#define INITIAL_SIZE 5
#define INC_DEC_SIZE 5

struct Item
{
    int itemId;
    char itemName[100];
    int quantity;
    double pricePerItem;
};

struct InventoryItem
{
    int currentIndex;
    int currentSize;
    struct Item *database;
};
typedef InventoryItem InventoryItem;
typedef Item Item;
InventoryItem *initDB(){
    InventoryItem *db = (InventoryItem*)malloc(sizeof(InventoryItem));
    db->currentIndex = 0;
    db->currentSize = INITIAL_SIZE;
    db->database = (Item*)malloc(sizeof(Item)*db->currentSize);
    return db;
}
void increaseDbSize(InventoryItem *inv){
    inv->currentSize = inv->currentSize + INC_DEC_SIZE;
    Item * temp = (Item*)malloc(sizeof(Item)*inv->currentSize);
    for(int i=0;i<=inv->currentIndex;i++){
        temp[i].itemId = inv->database[i].itemId;
        strcpy(temp[i].itemId,inv->database[i].itemId);
        temp[i].quantity = inv->database[i].quantity;
        temp[i].pricePerItem = inv->database[i].pricePerItem;
    }
    free(inv->database);
    inv->database = temp;
}
void decreaseDbSize(InventoryItem *inv){

}
void addItem(InventoryItem * inv, Item item){
    if(inv->currentIndex==inv->currentSize){
        increaseDbSize(inv);
    }
    inv->database[inv->currentIndex++] = item;
}
void displayItem(InventoryItem *inv){
    for(int i=0;i<=inv->currentIndex;i++){
        printf("\n****************************\n");
        printf("Item ID : %d\n",inv->database[i].itemId);
        printf("Item Name : %s\n",inv->database[i].itemName);
        printf("Item Quantity : %d\n",inv->database[i].quantity);
        printf("Price Per Item : %0.2f\n",inv->database[i].pricePerItem);
    }
}
void printMenu(){
    printf("\n****************************\n");
    printf("Enter your choice:\n");
    printf("\'i\' - insert an item\n");
    printf("\'u\' - update the database\n");
    printf("\'s\' - search the database\n");
    printf("\'i\' - display the database\n");
    printf("\'q\' - exit the program\n");
    printf("\n****************************\n");
}
int main()
{
    InventoryItem *db;
    db = initDB();

    Item a;
    a.itemId = 1;
    addItem(db,a);
    displayItem(db);
    // printMenu();
}