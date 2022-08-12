const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Tuple = std.meta.Tuple;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "partition_slice: odd" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    var t_b1: [10]i32 = undefined;
    var f_b1: [10]i32 = undefined;
    const b1 = zignite.range(i32, 1, 5).partitionSlice(odd, &t_b1, &f_b1).?;
    try expect(b1[0][0] == 1);
    try expect(b1[0][1] == 3);
    try expect(b1[0][2] == 5);
    try expect(b1[0].len == 3);
    try expect(b1[1][0] == 2);
    try expect(b1[1][1] == 4);
    try expect(b1[1].len == 2);

    var t_b2: [10]i32 = undefined;
    var f_b2: [10]i32 = undefined;
    const b2 = zignite.fromSlice(i32, &[_]i32{ 1, 3 }).partitionSlice(odd, &t_b2, &f_b2).?;
    try expect(b2[0][0] == 1);
    try expect(b2[0][1] == 3);
    try expect(b2[0].len == 2);
    try expect(b2[1].len == 0);

    var t_b3: [10]i32 = undefined;
    var f_b3: [10]i32 = undefined;
    const b3 = zignite.fromSlice(i32, &[_]i32{ 2, 4 }).partitionSlice(odd, &t_b3, &f_b3).?;
    try expect(b3[0].len == 0);
    try expect(b3[1][0] == 2);
    try expect(b3[1][1] == 4);
    try expect(b3[1].len == 2);

    var t_b4: [10]i32 = undefined;
    var f_b4: [10]i32 = undefined;
    const b4 = zignite.empty(i32).partitionSlice(odd, &t_b4, &f_b4).?;
    try expect(b4[0].len == 0);
    try expect(b4[1].len == 0);

    var t_b5: [10]i32 = undefined;
    var f_b5: [10]i32 = undefined;
    try expect(zignite.repeat(i32, 1).partitionSlice(odd, &t_b5, &f_b5) == null);

    var t_b6: [10]i32 = undefined;
    var f_b6: [10]i32 = undefined;
    try expect(zignite.repeat(i32, 2).partitionSlice(odd, &t_b6, &f_b6) == null);

    var t_b7: [10]i32 = undefined;
    var f_b7: [10]i32 = undefined;
    try expect(zignite.range(i32, 1, 100).partitionSlice(odd, &t_b7, &f_b7) == null);
}

pub fn PartitionSlice(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        true_buffer: []T,
        true_index: usize,
        false_buffer: []T,
        false_index: usize,

        const Out = Tuple(&.{ []const T, []const T });

        pub const Type = ConsumerType(T, @This(), ?Out);

        pub fn init(true_buffer: []T, false_buffer: []T) Type.State {
            return _init(true_buffer, 0, false_buffer, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.state;
            const t_b = s.true_buffer;
            const t_i = s.true_index;
            const f_b = s.false_buffer;
            const f_i = s.false_index;
            return switch (event.tag) {
                ._continue => return_or_await(t_b, t_i, f_b, f_i),
                ._yield => |v| set_then_return_or_await(t_b, t_i, f_b, f_i, v),
                ._break => Type.Action._return(s, Out{ .@"0" = t_b[0..t_i], .@"1" = f_b[0..f_i] }),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(true_buffer: []T, true_index: usize, false_buffer: []T, false_index: usize) Type.State {
            return .{ .true_buffer = true_buffer, .true_index = true_index, .false_buffer = false_buffer, .false_index = false_index };
        }

        inline fn return_or_await(t_b: []T, t_i: usize, f_b: []T, f_i: usize) Type.Action {
            const s = _init(t_b, t_i, f_b, f_i);
            if (t_i >= t_b.len or f_i >= f_b.len) {
                return Type.Action._return(s, null);
            } else {
                return Type.Action._await(s);
            }
        }

        inline fn set_then_return_or_await(t_b: []T, t_i: usize, f_b: []T, f_i: usize, value: T) Type.Action {
            if (t_i >= t_b.len or f_i >= f_b.len) {
                return Type.Action._return(_init(t_b, t_i, f_b, f_i), null);
            }

            const a_i = .{ .modifier = .always_inline };
            if (@call(a_i, predicate, .{value})) {
                t_b[t_i] = value;
                return Type.Action._await(_init(t_b, t_i + 1, f_b, f_i));
            } else {
                f_b[f_i] = value;
                return Type.Action._await(_init(t_b, t_i, f_b, f_i + 1));
            }
        }
    };
}
