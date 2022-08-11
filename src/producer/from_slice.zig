const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "from_slice:" {
    var buffer1: [10]u8 = undefined;
    const b1 = zignite.fromSlice(u8, "ABC").toSlice(&buffer1).?;
    try expect(b1[0] == 'A');
    try expect(b1[1] == 'B');
    try expect(b1[2] == 'C');
    try expect(b1.len == 3);

    var buffer2: [10]u8 = undefined;
    const b2 = zignite.fromSlice(u8, "ABCDEF"[2..5]).toSlice(&buffer2).?;
    try expect(b2[0] == 'C');
    try expect(b2[1] == 'D');
    try expect(b2[2] == 'E');
    try expect(b2.len == 3);

    try expect(zignite.fromSlice(u8, "").isEmpty());
}

pub fn FromSlice(comptime T: type) type {
    return struct {
        slice: []const T,
        index: usize,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(slice: []const T) Type.State {
            return _init(slice, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.slice;
            const i = event.index;
            if (0 <= i and i < s.len) {
                return Type.Action._yield(_init(s, i + 1), s[i]);
            } else {
                return Type.Action._break(_init(s, i));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(slice: []const T, index: usize) Type.State {
            return .{ .slice = slice, .index = index };
        }
    };
}
