const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "range: 1..3" {
    var buffer1: [10]i32 = undefined;
    const b1 = zignite.range(i32, 1, 3).toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 2);
    try expect(b1[2] == 3);
    try expect(b1.len == 3);

    var buffer2: [10]i32 = undefined;
    const b2 = zignite.range(i32, -1, 3).toSlice(&buffer2).?;
    try expect(b2[0] == -1);
    try expect(b2[1] == 0);
    try expect(b2[2] == 1);
    try expect(b2.len == 3);

    try expect(zignite.range(i32, 0, 0).isEmpty());
}

pub fn Range(comptime T: type) type {
    if (comptime !std.meta.trait.isNumber(T)) {
        @compileError("!std.meta.trait.isNumber(" ++ @typeName(T) ++ ")");
    }

    return struct {
        start: T,
        count: usize,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(start: T, count: usize) Type.State {
            return .{ .start = start, .count = count };
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.start;
            const c = event.count;
            if (c <= 0) {
                return Type.Action._break(init(s, c));
            } else {
                return Type.Action._yield(init(s + 1, c - 1), s);
            }
        }

        pub const deinit = Type.nop;
    };
}
