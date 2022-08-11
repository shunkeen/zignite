const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "repeat:" {
    var buffer: [10]u8 = undefined;
    const b = zignite.repeat(u8, 'A').take(buffer.len).toSlice(&buffer).?;
    try expect(b[0] == 'A');
    try expect(b[1] == 'A');
    try expect(b[2] == 'A');
    // ...
}

pub fn Repeat(comptime T: type) type {
    return struct {
        value: T,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(value: T) Type.State {
            return .{ .value = value };
        }

        pub fn next(event: Type.Event) Type.Action {
            const v = event.value;
            return Type.Action._yield(init(v), v);
        }

        pub const deinit = Type.nop;
    };
}
