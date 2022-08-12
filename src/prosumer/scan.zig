const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "scan: 2 *" {
    const mul = struct {
        pub fn mul(x: u32, y: u32) u32 {
            return x * y;
        }
    }.mul;

    var buffer1: [10]u32 = undefined;
    const b1 = zignite.range(u32, 1, 5).scan(u32, 2, mul).toSlice(&buffer1).?;
    try expect(b1[0] == 2);
    try expect(b1[1] == 2);
    try expect(b1[2] == 4);
    try expect(b1[3] == 12);
    try expect(b1[4] == 48);
    try expect(b1[5] == 240);
    try expect(b1.len == 6);

    var buffer2: [10]u32 = undefined;
    const b2 = zignite.empty(u32).scan(u32, 2, mul).toSlice(&buffer2).?;
    try expect(b2[0] == 2);
    try expect(b2.len == 1);
}

pub fn Scan(comptime S: type, comptime T: type, reducer: fn (accumulator: S, value: T) S) type {
    return struct {
        is_first: bool,
        accumulator: S,

        pub const Type = ProsumerType(T, @This(), S);

        pub inline fn init(accumulator: S) Type.State {
            return _init(true, accumulator);
        }

        pub fn next(event: Type.Event) Type.Action {
            const is_first = event.state.is_first;
            const a = event.state.accumulator;
            return if (is_first) Type.Action._yield(_init(false, a), a) else switch (event.tag) {
                ._break => Type.Action._break(_init(false, a)),
                ._continue => Type.Action._await(_init(false, a)),
                ._yield => |v| reduce_then_yield(a, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(is_first: bool, accumulator: S) Type.State {
            return .{ .is_first = is_first, .accumulator = accumulator };
        }

        inline fn reduce_then_yield(accumulator: S, value: T) Type.Action {
            const a = @call(.{ .modifier = .always_inline }, reducer, .{ accumulator, value });
            return Type.Action._yield(_init(false, a), a);
        }
    };
}
