#include "book.h"
#include "order.h"
#include <stdio.h>

// struct book;

int main(void) {
  printf("big-duck engine: ready\n");
  struct book b;
  book_init(&b);

  printf("--- Scenario 1: rest two SELLs (no trades) ---\n");
  struct order s1 = {.id = 1, .side = SIDE_SELL, .price = 51, .qty = 500};
  struct order s2 = {.id = 2, .side = SIDE_SELL, .price = 50, .qty = 300};
  book_submit(&b, &s1);
  book_submit(&b, &s2);
  printf("best_ask=%d best_bid=%d\n", b.best_ask, b.best_bid);

  printf("\n--- Scenario 2: BUY 700 @ 52 crosses both asks ---\n");
  struct order b1 = {.id = 3, .side = SIDE_BUY, .price = 52, .qty = 700};
  book_submit(&b, &b1);
  printf("best_ask=%d best_bid=%d  remaining BUY qty=%lld\n", b.best_ask,
         b.best_bid, (long long)b1.qty);

  printf("\n--- Scenario 3: BUY 200 @ 40 rests, no cross ---\n");
  struct order b2 = {.id = 4, .side = SIDE_BUY, .price = 40, .qty = 200};
  book_submit(&b, &b2);
  printf("best_ask=%d best_bid=%d\n", b.best_ask, b.best_bid);

  return 0;
}
