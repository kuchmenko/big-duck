#ifndef BOOK_H
#define BOOK_H

#include "types.h"

struct order;

struct level {
  qty_t total_qty;
};

struct book {
  struct level levels[2][MAX_PRICE_TICKS];
  price_t best_bid;
  price_t best_ask;
};

void book_init(struct book *);
void book_submit(struct book *, struct order *);

#endif // !BOOK_H
