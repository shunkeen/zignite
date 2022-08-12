const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Fold = @import("fold.zig").Fold;

test "count:" {
    try expect(zignite.range(u32, 11, 5).count() == 5);
    try expect(zignite.once(f16, 3.0).count() == 1);
    try expect(zignite.empty(i32).count() == 0);
}

pub fn Count(comptime T: type) type {
    return struct {
        const F = Fold(usize, T, increment);
        fn increment(count: usize, _: T) usize {
            return count + 1;
        }

        pub const Type = F.Type;
        pub const init = F.init(0);
        pub const next = F.next;
        pub const deinit = F.deinit;
    };
}
