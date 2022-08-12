const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Tuple = std.meta.Tuple;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "unzip:" {
    const T32 = Tuple(&.{ i32, f32 });
    const t32s = zignite.fromSlice(T32, &[_]T32{ .{ 1, 0.2 }, .{ 3, 0.4 } });

    var buffer1_0: [10]i32 = undefined;
    var buffer1_1: [10]f32 = undefined;
    const b1 = t32s.unzipSlice(i32, &buffer1_0, f32, &buffer1_1).?;
    try expect(b1[0][0] == 1);
    try expect(b1[0][1] == 3);
    try expect(b1[0].len == 2);

    try expect(b1[1][0] == 0.2);
    try expect(b1[1][1] == 0.4);
    try expect(b1[1].len == 2);

    var buffer2_0: [10]i32 = undefined;
    var buffer2_1: [10]f32 = undefined;
    const b2 = zignite.empty(T32).unzipSlice(i32, &buffer2_0, f32, &buffer2_1).?;
    try expect(b2[0].len == 0);
    try expect(b2[1].len == 0);

    var buffer3_0: [1]i32 = undefined;
    var buffer3_1: [10]f32 = undefined;
    try expect(t32s.unzipSlice(i32, &buffer3_0, f32, &buffer3_1) == null);

    var buffer4_0: [10]i32 = undefined;
    var buffer4_1: [1]f32 = undefined;
    try expect(t32s.unzipSlice(i32, &buffer4_0, f32, &buffer4_1) == null);

    var buffer5_0: [1]i32 = undefined;
    var buffer5_1: [1]f32 = undefined;
    try expect(t32s.unzipSlice(i32, &buffer5_0, f32, &buffer5_1) == null);
}

pub fn UnzipSlice(comptime S: type, comptime T: type, comptime U: type) type {
    return struct {
        buffer0: []T,
        buffer1: []U,
        index: usize,

        const Out = Tuple(&.{ []const T, []const U });

        pub const Type = ConsumerType(S, @This(), ?Out);

        pub fn init(buffer0: []T, buffer1: []U) Type.State {
            return _init(buffer0, buffer1, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.state;
            const b0 = s.buffer0;
            const b1 = s.buffer1;
            const i = s.index;
            return switch (event.tag) {
                ._continue => return_or_await(b0, b1, i),
                ._yield => |v| set_then_return_or_await(b0, b1, i, v),
                ._break => Type.Action._return(s, Out{ .@"0" = b0[0..i], .@"1" = b1[0..i] }),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(buffer0: []T, buffer1: []U, index: usize) Type.State {
            return .{ .buffer0 = buffer0, .buffer1 = buffer1, .index = index };
        }

        inline fn return_or_await(b0: []T, b1: []U, i: usize) Type.Action {
            const s = _init(b0, b1, i);
            if (i >= b0.len or i >= b1.len) {
                return Type.Action._return(s, null);
            } else {
                return Type.Action._await(s);
            }
        }

        inline fn set_then_return_or_await(b0: []T, b1: []U, i: usize, value: S) Type.Action {
            if (i >= b0.len or i >= b1.len) {
                return Type.Action._return(_init(b0, b1, i), null);
            } else {
                b0[i] = value[0];
                b1[i] = value[1];
                return Type.Action._await(_init(b0, b1, i + 1));
            }
        }
    };
}
