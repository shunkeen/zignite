const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Tuple = std.meta.Tuple;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "enumerate:" {
    var buffer1: [10]zignite.FromSlice(u8).Enumerate().Out = undefined;
    const b1 = zignite.fromSlice(u8, "ABC").enumerate().toSlice(&buffer1).?;
    try expect(b1[0][0] == 0 and b1[0][1] == 'A');
    try expect(b1[1][0] == 1 and b1[1][1] == 'B');
    try expect(b1[2][0] == 2 and b1[2][1] == 'C');
    try expect(b1.len == 3);

    try expect(zignite.empty(u8).enumerate().isEmpty());
}

pub fn Enumerate(comptime T: type) type {
    return struct {
        count: usize,

        pub const Type = ProsumerType(T, @This(), Tuple(&.{ usize, T }));

        pub const init = _init(0);

        pub fn next(event: Type.Event) Type.Action {
            const c = event.state.count;
            return switch (event.tag) {
                ._break => Type.Action._break(_init(c)),
                ._yield => |v| Type.Action._yield(_init(c + 1), .{ c, v }),
                ._continue => Type.Action._await(_init(c)),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(count: usize) Type.State {
            return .{ .count = count };
        }
    };
}
