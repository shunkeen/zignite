const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "find: odd" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    try expect(zignite.range(i32, 1, 5).find(odd).? == 1);
    try expect(zignite.repeat(i32, 3).find(odd).? == 3);

    try expect(zignite.fromSlice(i32, &[_]i32{ 2, 4, 6 }).find(odd) == null);
    try expect(zignite.empty(i32).find(odd) == null);
}

pub fn Find(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        pub const Type = ConsumerType(T, @This(), ?T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._return(init, null),
                ._continue => Type.Action._await(init),
                ._yield => |v| await_or_return(v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_return(value: T) Type.Action {
            const a_i = .{ .modifier = .always_inline };
            if (@call(a_i, predicate, .{value})) {
                return Type.Action._return(init, value);
            } else {
                return Type.Action._await(init);
            }
        }
    };
}
