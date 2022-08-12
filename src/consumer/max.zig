const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Reduce = @import("reduce.zig").Reduce;

test "max:" {
    try expect(zignite.fromSlice(f32, &[_]f32{ 1.9, 8.2, 3.7 }).max().? == 8.2);
    try expect(zignite.empty(f32).max() == null);
}

pub fn Max(comptime T: type) type {
    return struct {
        const R = Reduce(T, max);
        pub fn max(x: T, y: T) T {
            return if (x < y) y else x;
        }
    }.R;
}
