const zignite = @import("../zignite.zig");
const std = @import("std");
const BufMap = std.BufMap;
const BufMapHashMap = std.StringHashMap([]const u8);
const expect = std.testing.expect;
const FromIterable = @import("from_iterable.zig").FromIterable;

test "fromBufMap" {
    const allocator = std.testing.allocator;
    {
        var buf_map = BufMap.init(allocator);
        defer buf_map.deinit();
        try buf_map.put("key1", "val1");
        try buf_map.put("key2", "val2");
        try buf_map.put("key3", "val3");

        const a = try zignite.fromBufMap(&buf_map).toBoundedArray(10);
        for (a.constSlice()) |entry| {
            // random order
            if (std.mem.eql(u8, entry.key_ptr.*, "key1")) {
                try expect(std.mem.eql(u8, entry.value_ptr.*, "val1"));
            } else if (std.mem.eql(u8, entry.key_ptr.*, "key2")) {
                try expect(std.mem.eql(u8, entry.value_ptr.*, "val2"));
            } else if (std.mem.eql(u8, entry.key_ptr.*, "key3")) {
                try expect(std.mem.eql(u8, entry.value_ptr.*, "val3"));
            } else {
                unreachable;
            }
        }
    }

    {
        var buf_map = BufMap.init(allocator);
        defer buf_map.deinit();
        try expect(zignite.fromBufMap(&buf_map).isEmpty());
    }
}

pub const FromBufMap = FromIterable(*const BufMap, BufMapHashMap.Iterator, BufMapHashMap.Entry);
