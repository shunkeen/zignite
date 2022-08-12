const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Reduce = @import("reduce.zig").Reduce;

test "last:" {
    try expect(zignite.range(i32, 1, 5).last().? == 5);
    try expect(zignite.empty(i32).last() == null);
}

pub fn Last(comptime T: type) type {
    return struct {
        const R = Reduce(T, flip_const);
        pub fn flip_const(_: T, value: T) T {
            return value;
        }
    }.R;
}
