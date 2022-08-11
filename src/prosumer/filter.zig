const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "filter: odd" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    var buffer1: [10]i32 = undefined;
    const b1 = zignite.range(i32, 0, 6).filter(odd).toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 3);
    try expect(b1[2] == 5);
    try expect(b1.len == 3);

    try expect(zignite.fromSlice(i32, &[_]i32{ 2, 4, 6 }).filter(odd).isEmpty());
    try expect(zignite.empty(i32).filter(odd).isEmpty());
}

pub fn Filter(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        pub const Type = ProsumerType(T, @This(), T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._break(init),
                ._continue => Type.Action._await(init),
                ._yield => |v| yield_or_await(v),
            };
        }

        pub const deinit = Type.nop;

        inline fn yield_or_await(value: T) Type.Action {
            const a_i = .{ .modifier = .always_inline };
            if (@call(a_i, predicate, .{value})) {
                return Type.Action._yield(init, value);
            } else {
                return Type.Action._await(init);
            }
        }
    };
}
