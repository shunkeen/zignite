const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Fold = @import("fold.zig").Fold;

test "for_each:" {
    const sum = struct {
        var acc: i32 = 0;
        pub fn add(x: i32) void {
            acc += x;
        }
    };

    sum.acc = 0;
    zignite.range(i32, 1, 4).forEach(sum.add);
    try expect(sum.acc == 10);

    sum.acc = 0;
    zignite.empty(i32).forEach(sum.add);
    try expect(sum.acc == 0);
}

pub fn ForEach(comptime T: type, transformer: fn (value: T) void) type {
    return struct {
        const F = Fold(void, T, t);
        pub fn t(_: void, value: T) void {
            @call(.{ .modifier = .always_inline }, transformer, .{value});
        }

        pub const Type = F.Type;
        pub const init = F.init({});
        pub const next = F.next;
        pub const deinit = F.deinit;
    };
}
