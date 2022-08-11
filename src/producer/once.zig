const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "once:" {
    var buffer: [10]i32 = undefined;
    const b = zignite.once(i32, 3).toSlice(&buffer).?;
    try expect(b[0] == 3);
    try expect(b.len == 1);
}

pub fn Once(comptime T: type) type {
    return struct {
        value: ?T,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(value: T) Type.State {
            return .{ .value = value };
        }

        pub fn next(event: Type.Event) Type.Action {
            const v = event.value;
            const s = Type.State{ .value = null };
            return if (v == null) Type.Action._break(s) else Type.Action._yield(s, v.?);
        }

        pub const deinit = Type.nop;
    };
}
