const zignite = @import("../zignite.zig");
const std = @import("std");
const AutoArrayHashMap = std.AutoArrayHashMap;
const expect = std.testing.expect;
const FromIterable = @import("from_iterable.zig").FromIterable;

test "fromAutoArrayHashMap" {
    const allocator = std.testing.allocator;
    {
        var hash_map = AutoArrayHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try hash_map.put(97, "a"[0]);
        try hash_map.put(98, "b"[0]);
        try hash_map.put(99, "c"[0]);

        const a = try zignite.fromAutoArrayHashMap(u32, u8, &hash_map).toBoundedArray(10);
        try expect(a.get(0).key_ptr.* == 97);
        try expect(a.get(0).value_ptr.* == "a"[0]);
        try expect(a.get(1).key_ptr.* == 98);
        try expect(a.get(1).value_ptr.* == "b"[0]);
        try expect(a.get(2).key_ptr.* == 99);
        try expect(a.get(2).value_ptr.* == "c"[0]);
        try expect(a.len == 3);
    }

    {
        var hash_map = AutoArrayHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try expect(zignite.fromAutoArrayHashMap(u32, u8, &hash_map).isEmpty());
    }
}

pub fn FromAutoArrayHashMap(comptime S: type, comptime T: type) type {
    const H = AutoArrayHashMap(S, T);
    return FromIterable(*const H, H.Iterator, H.Entry);
}
