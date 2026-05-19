#ifndef ORDER_H
#define ORDER_H

#include "types.h"

struct order {
  order_id_t id;
  side_t side;
  price_t price;
  qty_t qty;
};

#endif // !ORDER_H
