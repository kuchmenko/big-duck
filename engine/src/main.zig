const std = @import("std");
const book = @import("book.zig");
const Book = book.Book;
const Order = book.Order;

pub fn main(init: std.process.Init) void {
    std.debug.print("big-duck engine: ready\n", .{});

    var b: Book = undefined;
    b.init(init.gpa);
    defer b.orders.deinit(init.gpa);

    std.debug.print("--- Scenario 1: rest two SELLs (no trades) ---\n", .{});
    var s1 = Order{ .id = 1, .side = .sell, .price = 51, .qty = 500 };
    var s2 = Order{ .id = 2, .side = .sell, .price = 50, .qty = 300 };
    b.submit(&s1);
    b.submit(&s2);
    std.debug.print("best_ask={d} best_bid={d}\n", .{ b.best_ask, b.best_bid });

    std.debug.print("\n--- Scenario 2: BUY 700 @ 52 crosses both asks ---\n", .{});
    var b1 = Order{ .id = 3, .side = .buy, .price = 52, .qty = 700 };
    b.submit(&b1);
    std.debug.print("best_ask={d} best_bid={d}  remaining BUY qty={d}\n", .{ b.best_ask, b.best_bid, b1.qty });

    std.debug.print("\n--- Scenario 3: BUY 200 @ 40 rests, no cross ---\n", .{});
    var b2 = Order{ .id = 4, .side = .buy, .price = 40, .qty = 200 };
    b.submit(&b2);
    std.debug.print("best_ask={d} best_bid={d}\n", .{ b.best_ask, b.best_bid });
}
