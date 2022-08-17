const zignite = @import("../zignite.zig");
const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const expect = std.testing.expect;
const FromIterable = @import("from_iterable.zig").FromIterable;

test "fromAutoHashMap" {
    const allocator = std.testing.allocator;
    {
        var hash_map = AutoHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try hash_map.put(97, "a"[0]);
        try hash_map.put(98, "b"[0]);
        try hash_map.put(99, "c"[0]);

        const a = try zignite.fromAutoHashMap(u32, u8, &hash_map).toBoundedArray(10);
        for (a.constSlice()) |entry| {
            // random order
            switch (entry.key_ptr.*) {
                97 => try expect(entry.value_ptr.* == "a"[0]),
                98 => try expect(entry.value_ptr.* == "b"[0]),
                99 => try expect(entry.value_ptr.* == "c"[0]),
                else => unreachable,
            }
        }
    }

    {
        var hash_map = AutoHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try expect(zignite.fromAutoHashMap(u32, u8, &hash_map).isEmpty());
    }
}

pub fn FromAutoHashMap(comptime S: type, comptime T: type) type {
    const H = AutoHashMap(S, T);
    return FromIterable(*const H, H.Iterator, H.Entry);
}
