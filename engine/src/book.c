#include "book.h"
#include "order.h"
#include "string.h"
#include "types.h"

#include <stdio.h>

void book_init(struct book *b) {
  memset(b, 0, sizeof *b);
  b->best_bid = -1;              /* "no bids" - lower that any tick */
  b->best_ask = MAX_PRICE_TICKS; /* "no asks" - higher that any tick */
}

void book_submit(struct book *b, struct order *o) {
  if (o->side == SIDE_BUY) {
    while (o->qty > 0 && b->best_ask <= o->price) {
      struct level *lvl = &b->levels[SIDE_SELL][b->best_ask];
      qty_t eat = (o->qty < lvl->total_qty) ? o->qty : lvl->total_qty;

      lvl->total_qty -= eat;
      o->qty -= eat;

      printf("TRADE @ %d qty %lld\n", b->best_ask, (long long)eat);

      if (lvl->total_qty == 0) {
        price_t p = b->best_ask + 1;

        while (p < MAX_PRICE_TICKS && b->levels[SIDE_SELL][p].total_qty == 0) {
          p++;
        }
        b->best_ask = p;
      }
    }

    if (o->qty > 0) {
      b->levels[SIDE_BUY][o->price].total_qty += o->qty;

      if (o->price > b->best_bid) {
        b->best_bid = o->price;
      }
    }

  } else {
    while (o->qty > 0 && b->best_bid >= o->price) {
      struct level *lvl = &b->levels[SIDE_BUY][b->best_bid];
      qty_t eat = (o->qty < lvl->total_qty) ? o->qty : lvl->total_qty;

      lvl->total_qty -= eat;
      o->qty -= eat;

      printf("TRADE @ %d qty %lld\n", b->best_bid, (long long)eat);

      if (lvl->total_qty == 0) {
        price_t p = b->best_bid - 1;

        while (p >= 0 && b->levels[SIDE_BUY][p].total_qty == 0) {
          p--;
        }
        b->best_bid = p;
      }
    }

    if (o->qty > 0) {
      b->levels[SIDE_SELL][o->price].total_qty += o->qty;

      if (o->price < b->best_ask) {
        b->best_ask = o->price;
      }
    }
  }
}
