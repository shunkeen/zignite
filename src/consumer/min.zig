const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Reduce = @import("reduce.zig").Reduce;

test "min:" {
    try expect(zignite.fromSlice(f32, &[_]f32{ 9.1, 2.8, 7.3 }).min().? == 2.8);
    try expect(zignite.empty(f32).min() == null);
}

pub fn Min(comptime T: type) type {
    return struct {
        const R = Reduce(T, min);
        pub fn min(x: T, y: T) T {
            return if (x > y) y else x;
        }
    }.R;
}
