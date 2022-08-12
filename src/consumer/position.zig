const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "position: odd" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    try expect(zignite.range(i32, 2, 5).position(odd).? == 1);
    try expect(zignite.repeat(i32, 3).position(odd).? == 0);

    try expect(zignite.fromSlice(i32, &[_]i32{ 2, 4, 6 }).position(odd) == null);
    try expect(zignite.empty(i32).position(odd) == null);
}

pub fn Position(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        count: usize,

        pub const Type = ConsumerType(T, @This(), ?usize);

        pub const init = _init(0);

        pub fn next(event: Type.Event) Type.Action {
            const c = event.state.count;
            return switch (event.tag) {
                ._break => Type.Action._return(init, null),
                ._continue => Type.Action._await(init),
                ._yield => |v| return_or_await(c, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(count: usize) Type.State {
            return .{ .count = count };
        }

        inline fn return_or_await(count: usize, value: T) Type.Action {
            const s = _init(count + 1);
            const a_i = .{ .modifier = .always_inline };
            if (@call(a_i, predicate, .{value})) {
                return Type.Action._return(s, count);
            } else {
                return Type.Action._await(s);
            }
        }
    };
}
