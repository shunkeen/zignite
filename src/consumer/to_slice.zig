const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "to_slice:" {
    var buffer1: [10]i32 = undefined;
    const b1 = zignite.fromSlice(i32, &[_]i32{ 1, 2, 3 }).toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 2);
    try expect(b1[2] == 3);
    try expect(b1.len == 3);

    var buffer2: [10]i32 = undefined;
    try expect(zignite.fromSlice(i32, &[_]i32{}).toSlice(&buffer2).?.len == 0);

    var buffer3: [10]i32 = undefined;
    try expect(zignite.fromSlice(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }).toSlice(&buffer3) == null);
}

pub fn ToSlice(comptime T: type) type {
    return struct {
        buffer: []T,
        index: usize,

        pub const Type = ConsumerType(T, @This(), ?[]const T);

        pub fn init(buffer: []T) Type.State {
            return _init(buffer, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const b = event.state.buffer;
            const i = event.state.index;
            return switch (event.tag) {
                ._continue => return_or_await(b, i),
                ._yield => |v| set_then_return_or_await(b, i, v),
                ._break => Type.Action._return(_init(b, i), b[0..i]),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(buffer: []T, index: usize) Type.State {
            return .{ .buffer = buffer, .index = index };
        }

        inline fn return_or_await(buffer: []T, index: usize) Type.Action {
            const s = _init(buffer, index);
            if (index >= buffer.len) {
                return Type.Action._return(s, null);
            } else {
                return Type.Action._await(s);
            }
        }

        inline fn set_then_return_or_await(buffer: []T, index: usize, value: T) Type.Action {
            const s = _init(buffer, index + 1);
            if (index >= buffer.len) {
                return Type.Action._return(s, null);
            } else {
                buffer[index] = value;
                return Type.Action._await(s);
            }
        }
    };
}
