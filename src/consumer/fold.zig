const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "fold: 2 *" {
    const mul = struct {
        pub fn mul(x: u32, y: u32) u32 {
            return x * y;
        }
    }.mul;

    try expect(zignite.range(u32, 1, 5).fold(u32, 2, mul) == 240);
    try expect(zignite.empty(u32).fold(u32, 2, mul) == 2);
}

pub fn Fold(comptime S: type, comptime T: type, comptime reducer: fn (accumulator: S, value: T) S) type {
    return struct {
        accumulator: S,

        pub const Type = ConsumerType(T, @This(), S);

        pub inline fn init(accumulator: S) Type.State {
            return .{ .accumulator = accumulator };
        }

        pub fn next(event: Type.Event) Type.Action {
            const a = event.state.accumulator;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(a)),
                ._break => Type.Action._return(init(a), a),
                ._yield => |v| Type.Action._await(init(f(a, v))),
            };
        }

        pub const deinit = Type.nop;

        inline fn f(accumulator: S, value: T) S {
            return @call(.{ .modifier = .always_inline }, reducer, .{ accumulator, value });
        }
    };
}
