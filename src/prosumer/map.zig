const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "map: (2 *)" {
    const double = struct {
        pub fn double(x: i32) i32 {
            return 2 * x;
        }
    }.double;

    var buffer1: [10]i32 = undefined;
    const b1 = zignite.range(i32, 1, 3).map(i32, double).toSlice(&buffer1).?;
    try expect(b1[0] == 2);
    try expect(b1[1] == 4);
    try expect(b1[2] == 6);
    try expect(b1.len == 3);

    try expect(zignite.empty(i32).map(i32, double).isEmpty());
}

pub fn Map(comptime S: type, comptime T: type, comptime transformer: fn (value: S) T) type {
    return struct {
        pub const Type = ProsumerType(S, @This(), T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._break(init),
                ._continue => Type.Action._await(init),
                ._yield => |v| Type.Action._yield(init, t(v)),
            };
        }

        pub const deinit = Type.nop;

        inline fn t(value: S) T {
            return @call(.{ .modifier = .always_inline }, transformer, .{value});
        }
    };
}
