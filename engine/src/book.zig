const std = @import("std");

pub const max_price_ticks = 10001; // 0..10000 inclusive

pub const Price = i32; // ticks 0..10000 = 0.0000..1.0000
pub const Qty = i64; // base units
pub const OrderId = u64;

pub const Side = enum(u1) { buy, sell };

pub const Order = struct {
    id: OrderId,
    side: Side,
    price: Price,
    qty: Qty,
};

const Level = struct {
    total_qty: Qty = 0,
    head: OrderId,
    tail: OrderId,
};

pub const Book = struct {
    orders: std.AutoHashMapUnmanaged(OrderId, Order),
    levels: [2][max_price_ticks]Level,
    best_bid: Price,
    best_ask: Price,
    allocator: std.mem.Allocator,

    pub fn init(b: *Book, allocator: std.mem.Allocator) void {
        @memset(std.mem.asBytes(&b.levels), 0);
        b.best_bid = -1; // no bids — lower than any tick
        b.best_ask = max_price_ticks; // no asks — higher than any tick
        b.allocator = allocator;
        b.orders = std.AutoHashMapUnmanaged(OrderId, Order){};
    }

    fn level(b: *Book, side: Side, price: Price) *Level {
        return &b.levels[@intFromEnum(side)][@intCast(price)];
    }

    pub fn submit(b: *Book, o: *Order) void {
        switch (o.side) {
            .buy => {
                while (o.qty > 0 and b.best_ask <= o.price) {
                    const lvl = b.level(.sell, b.best_ask);
                    const head = b.orders.get(lvl.head) orelse return error.NotFound;
                    const eat = @min(o.qty, lvl.total_qty);
                    lvl.total_qty -= eat;
                    o.qty -= eat;
                    std.debug.print("TRADE @ {d} qty {d}\n", .{ b.best_ask, eat });

                    if (lvl.total_qty == 0) {
                        var p = b.best_ask + 1;
                        while (p < max_price_ticks and b.level(.sell, p).total_qty == 0) p += 1;
                        b.best_ask = p;
                    }
                }
                if (o.qty > 0) {
                    b.level(.buy, o.price).total_qty += o.qty;
                    if (o.price > b.best_bid) b.best_bid = o.price;
                    b.orders.put(b.allocator, o.id, o.*) catch {};
                }
            },
            .sell => {
                while (o.qty > 0 and b.best_bid >= o.price) {
                    const lvl = b.level(.buy, b.best_bid);
                    const eat = @min(o.qty, lvl.total_qty);
                    lvl.total_qty -= eat;
                    o.qty -= eat;
                    std.debug.print("TRADE @ {d} qty {d}\n", .{ b.best_bid, eat });

                    if (lvl.total_qty == 0) {
                        var p = b.best_bid - 1;
                        while (p >= 0 and b.level(.buy, p).total_qty == 0) p -= 1;
                        b.best_bid = p;
                    }
                }
                if (o.qty > 0) {
                    b.level(.sell, o.price).total_qty += o.qty;
                    if (o.price < b.best_ask) b.best_ask = o.price;
                    b.orders.put(b.allocator, o.id, o.*) catch {};
                }
            },
        }
    }

    pub fn cancel(b: *Book, o: OrderId) void {
        const order = b.orders.get(o);
    }
};

test "buy crosses resting asks" {
    var b: Book = undefined;
    b.init(std.testing.allocator);
    defer b.orders.deinit(b.allocator);

    var s1 = Order{ .id = 1, .side = .sell, .price = 51, .qty = 500 };
    var s2 = Order{ .id = 2, .side = .sell, .price = 50, .qty = 300 };
    b.submit(&s1);
    b.submit(&s2);
    try std.testing.expectEqual(@as(Price, 50), b.best_ask);
    try std.testing.expectEqual(@as(Price, -1), b.best_bid);

    var buy = Order{ .id = 3, .side = .buy, .price = 52, .qty = 700 };
    b.submit(&buy);
    try std.testing.expectEqual(@as(Qty, 0), buy.qty);
    try std.testing.expectEqual(@as(Price, 51), b.best_ask);
    try std.testing.expectEqual(@as(Qty, 100), b.level(.sell, 51).total_qty);
}

test "non-crossing buy rests" {
    var b: Book = undefined;
    b.init(std.testing.allocator);
    defer b.orders.deinit(b.allocator);

    var buy = Order{ .id = 1, .side = .buy, .price = 40, .qty = 200 };
    b.submit(&buy);
    try std.testing.expectEqual(@as(Price, 40), b.best_bid);
    try std.testing.expectEqual(@as(Price, max_price_ticks), b.best_ask);
    try std.testing.expectEqual(@as(Qty, 200), b.level(.buy, 40).total_qty);
}
