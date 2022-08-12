const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "min_by_key: len" {
    const Str = []const u8;
    const len = struct {
        fn len(str: Str) usize {
            return str.len;
        }
    }.len;

    const x = zignite.fromSlice(Str, &[_]Str{ "four", "three", "two", "one" }).minByKey(usize, len).?;
    try expect(std.mem.eql(u8, x, "two"));
    try expect(zignite.empty(Str).minByKey(usize, len) == null);
}

pub fn MinByKey(comptime S: type, comptime T: type, comptime transformer: fn (value: S) T) type {
    return struct {
        key: ?T,
        value: ?S,

        pub const Type = ConsumerType(S, @This(), ?S);

        pub const init = _init(null, null);

        pub fn next(event: Type.Event) Type.Action {
            const k = event.state.key;
            const v = event.state.value;
            return switch (event.tag) {
                ._yield => |w| by_key(k, v, w),
                ._continue => Type.Action._await(_init(k, v)),
                ._break => Type.Action._return(_init(k, v), v),
            };
        }

        pub const deinit = Type.nop;

        inline fn _init(key: ?T, value: ?S) Type.State {
            return .{ .key = key, .value = value };
        }
        inline fn t(value: S) T {
            return @call(.{ .modifier = .always_inline }, transformer, .{value});
        }

        inline fn by_key(key1: ?T, value1: ?S, value2: S) Type.Action {
            if (value1 == null) {
                return Type.Action._await(_init(null, value2));
            }

            const k1 = if (key1 == null) t(value1.?) else key1.?;
            const k2 = t(value2);
            return Type.Action._await(if (k1 > k2) _init(k2, value2) else _init(k1, value1));
        }
    };
}
