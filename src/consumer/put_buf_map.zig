const zignite = @import("../zignite.zig");
const std = @import("std");
const BufMap = std.BufMap;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "put_buf_map:" {
    const allocator = std.testing.allocator;
    const Str = []const u8;

    {
        var buf_map = BufMap.init(allocator);
        defer buf_map.deinit();

        const keys = zignite.fromSlice(Str, &[_]Str{ "key1", "key2", "key3" });
        const vals = zignite.fromSlice(Str, &[_]Str{ "val1", "val2", "val3" });
        try keys.zip(vals).putBufMap(&buf_map);

        try expect(buf_map.get("key0") == null);
        try expect(std.mem.eql(u8, buf_map.get("key1").?, "val1"));
        try expect(std.mem.eql(u8, buf_map.get("key2").?, "val2"));
        try expect(std.mem.eql(u8, buf_map.get("key3").?, "val3"));
        try expect(buf_map.get("key4") == null);
    }

    {
        var buf_map = BufMap.init(allocator);
        defer buf_map.deinit();

        const keys = zignite.empty(Str);
        const vals = zignite.empty(Str);
        try keys.zip(vals).putBufMap(&buf_map);

        try expect(buf_map.count() == 0);
    }
}

pub fn PutBufMap(comptime T: type) type {
    return struct {
        buf_map: *BufMap,

        pub const Type = ConsumerType(T, @This(), anyerror!void);

        pub inline fn init(buf_map: *BufMap) Type.State {
            return .{ .buf_map = buf_map };
        }

        pub fn next(event: Type.Event) Type.Action {
            const b = event.state.buf_map;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(b)),
                ._break => Type.Action._return(init(b), {}),
                ._yield => |v| await_or_throw(b, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_throw(buf_map: *BufMap, value: T) Type.Action {
            if (buf_map.put(value[0], value[1])) |_| {
                return Type.Action._await(init(buf_map));
            } else |err| {
                return Type.Action._return(init(buf_map), err);
            }
        }
    };
}
