const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "all: odd" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    try expect(zignite.fromSlice(i32, &[_]i32{ 1, 3, 5 }).all(odd));
    try expect(zignite.empty(i32).all(odd));

    try expect(!zignite.range(i32, 1, 5).all(odd));
    try expect(!zignite.repeat(i32, 2).all(odd));
}

pub fn All(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        pub const Type = ConsumerType(T, @This(), bool);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._return(init, true),
                ._continue => Type.Action._await(init),
                ._yield => |v| await_or_return(v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_return(value: T) Type.Action {
            const a_i = .{ .modifier = .always_inline };
            if (@call(a_i, predicate, .{value})) {
                return Type.Action._await(init);
            } else {
                return Type.Action._return(init, false);
            }
        }
    };
}
