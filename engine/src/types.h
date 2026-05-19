#ifndef TYPES_H
#define TYPES_H

#include "stdint.h"

#define MAX_PRICE_TICKS 10001 /* 0..10000 inclusive */
typedef int32_t price_t;      /* ticks 0..10000 = 0.0000..1.0000 */
typedef int64_t qty_t;        /* base units */
typedef uint64_t order_id_t;

typedef enum { SIDE_BUY = 0, SIDE_SELL = 1 } side_t;

#endif
