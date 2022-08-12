const zignite = @import("../zignite.zig");
const std = @import("std");
const Order = std.math.Order;
const expect = std.testing.expect;
const Reduce = @import("reduce.zig").Reduce;

test "max_by: abs_comp" {
    const abs_comp = struct {
        fn abs_comp(x: f32, y: f32) Order {
            const x_abs = @fabs(x);
            const y_abs = @fabs(y);
            return if (x_abs < y_abs) Order.lt else if (x_abs > y_abs) Order.gt else Order.eq;
        }
    }.abs_comp;

    try expect(zignite.fromSlice(f32, &[_]f32{ 1.9, -8.2, 3.7 }).maxBy(abs_comp).? == -8.2);
    try expect(zignite.empty(f32).maxBy(abs_comp) == null);
}

pub fn MaxBy(comptime T: type, comptime comparator: fn (x: T, y: T) Order) type {
    return struct {
        const R = Reduce(T, max);
        pub fn max(x: T, y: T) T {
            const a_i = .{ .modifier = .always_inline };
            return switch (@call(a_i, comparator, .{ x, y })) {
                .eq => x,
                .gt => x,
                .lt => y,
            };
        }
    }.R;
}
