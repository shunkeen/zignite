const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "repeat" {
    const a = try zignite.repeat(u8, 'A').take(10).toBoundedArray(10);
    try expect(a.get(0) == 'A');
    try expect(a.get(1) == 'A');
    try expect(a.get(2) == 'A');
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
