const zignite = @import("../zignite.zig");
const std = @import("std");
const AutoArrayHashMap = std.AutoArrayHashMap;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const TrySet = @import("try_set.zig").TrySet;

test "put_auto_array_hash_map:" {
    const allocator = std.testing.allocator;

    {
        const keys = zignite.range(u32, 97, 256);
        const vals = zignite.fromSlice(u8, "abc");
        var hash_map = try keys.zip(vals).toAutoArrayHashMap(u32, u8, allocator);
        defer hash_map.deinit();

        try expect(hash_map.get(96) == null);
        try expect(hash_map.get(97).? == "a"[0]);
        try expect(hash_map.get(98).? == "b"[0]);
        try expect(hash_map.get(99).? == "c"[0]);
        try expect(hash_map.get(100) == null);
    }

    {
        const keys = zignite.empty(u32);
        const vals = zignite.empty(u8);
        var hash_map = try keys.zip(vals).toAutoArrayHashMap(u32, u8, allocator);
        defer hash_map.deinit();

        try expect(hash_map.count() == 0);
    }
}

pub fn PutAutoArrayHashMap(comptime S: type, comptime T: type, comptime U: type) type {
    return TrySet(S, *AutoArrayHashMap(T, U), Allocator.Error, struct {
        fn set(hash_map: *AutoArrayHashMap(T, U), value: S) Allocator.Error!void {
            try hash_map.put(value[0], value[1]);
        }
    }.set);
}
