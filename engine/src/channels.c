#include <stdatomic.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define QUEUE_SIZE 64
_Static_assert((QUEUE_SIZE & (QUEUE_SIZE - 1)) == 0, "Oopsie");

#define item_t int

struct queue {
  item_t ring[QUEUE_SIZE];
  atomic_size_t head;
  atomic_size_t tail;
};

bool produce(struct queue *q, item_t item) {
  size_t head = atomic_load(&q->head);
  size_t tail = atomic_load(&q->tail);

  if (head - tail == QUEUE_SIZE)
    return false;

  q->ring[head & (QUEUE_SIZE - 1)] = item;
  atomic_store(&q->head, head + 1);

  return true;
}

bool consume(struct queue *q, item_t *out) {
  size_t head = atomic_load(&q->head);
  size_t tail = atomic_load(&q->tail);

  if (head == tail)
    return false;

  *out = q->ring[tail & (QUEUE_SIZE - 1)];
  atomic_store(&q->tail, tail + 1);

  return true;
}
