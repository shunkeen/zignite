const zignite = @import("../zignite.zig");
const std = @import("std");
const BufMap = std.BufMap;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const TrySet = @import("try_set.zig").TrySet;

test "put_buf_map:" {
    const allocator = std.testing.allocator;
    const Str = []const u8;

    {
        const keys = zignite.fromSlice(Str, &[_]Str{ "key1", "key2", "key3" });
        const vals = zignite.fromSlice(Str, &[_]Str{ "val1", "val2", "val3" });
        var buf_map = try keys.zip(vals).toBufMap(allocator);
        defer buf_map.deinit();

        try expect(buf_map.get("key0") == null);
        try expect(std.mem.eql(u8, buf_map.get("key1").?, "val1"));
        try expect(std.mem.eql(u8, buf_map.get("key2").?, "val2"));
        try expect(std.mem.eql(u8, buf_map.get("key3").?, "val3"));
        try expect(buf_map.get("key4") == null);
    }

    {
        const keys = zignite.empty(Str);
        const vals = zignite.empty(Str);
        var buf_map = try keys.zip(vals).toBufMap(allocator);
        defer buf_map.deinit();

        try expect(buf_map.count() == 0);
    }
}

pub fn PutBufMap(comptime T: type) type {
    return TrySet(T, *BufMap, Allocator.Error, struct {
        fn set(buf_map: *BufMap, value: T) Allocator.Error!void {
            try buf_map.put(value[0], value[1]);
        }
    }.set);
}
