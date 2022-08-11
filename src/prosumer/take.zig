const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "take:" {
    var buffer1: [10]i32 = undefined;
    const b1 = zignite.range(i32, 1, 5).take(3).toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 2);
    try expect(b1[2] == 3);
    try expect(b1.len == 3);

    var buffer2: [10]i32 = undefined;
    const b2 = zignite.range(i32, 1, 2).take(3).toSlice(&buffer2).?;
    try expect(b2[0] == 1);
    try expect(b2[1] == 2);
    try expect(b2.len == 2);

    try expect(zignite.empty(i32).take(3).isEmpty());
    try expect(zignite.range(i32, 1, 2).take(0).isEmpty());
}

pub fn Take(comptime T: type) type {
    return struct {
        count: usize,

        pub const Type = ProsumerType(T, @This(), T);

        pub inline fn init(count: usize) Type.State {
            return .{ .count = count };
        }

        pub fn next(event: Type.Event) Type.Action {
            const c = event.state.count;
            return switch (event.tag) {
                ._continue => break_or_await(c),
                ._break => Type.Action._break(init(c)),
                ._yield => |x| Type.Action._yield(init(c - 1), x),
            };
        }

        pub const deinit = Type.nop;

        inline fn break_or_await(count: usize) Type.Action {
            if (count <= 0) {
                return Type.Action._break(init(count));
            } else {
                return Type.Action._await(init(count));
            }
        }
    };
}
