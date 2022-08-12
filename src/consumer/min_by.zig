const zignite = @import("../zignite.zig");
const std = @import("std");
const Order = std.math.Order;
const expect = std.testing.expect;
const Reduce = @import("reduce.zig").Reduce;

test "min_by: abs_comp" {
    const abs_comp = struct {
        fn abs_comp(x: f32, y: f32) Order {
            const x_abs = @fabs(x);
            const y_abs = @fabs(y);
            return if (x_abs < y_abs) Order.lt else if (x_abs > y_abs) Order.gt else Order.eq;
        }
    }.abs_comp;

    try expect(zignite.fromSlice(f32, &[_]f32{ -9.1, 2.8, -7.3 }).minBy(abs_comp).? == 2.8);
    try expect(zignite.empty(f32).minBy(abs_comp) == null);
}

pub fn MinBy(comptime T: type, comptime comparator: fn (x: T, y: T) Order) type {
    return struct {
        const R = Reduce(T, min);
        pub fn min(x: T, y: T) T {
            const a_i = .{ .modifier = .always_inline };
            return switch (@call(a_i, comparator, .{ x, y })) {
                .eq => x,
                .lt => x,
                .gt => y,
            };
        }
    }.R;
}
