const zignite = @import("../zignite.zig");
const std = @import("std");
const AutoArrayHashMap = std.AutoArrayHashMap;
const expect = std.testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "from_auto_array_hash_map:" {
    const allocator = std.testing.allocator;
    {
        var hash_map = AutoArrayHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try hash_map.put(97, "a"[0]);
        try hash_map.put(98, "b"[0]);
        try hash_map.put(99, "c"[0]);

        var buffer: [10]AutoArrayHashMap(u32, u8).Entry = undefined;
        const b = zignite.fromAutoArrayHashMap(u32, u8, &hash_map).toSlice(&buffer).?;
        try expect(b[0].key_ptr.* == 97);
        try expect(b[0].value_ptr.* == "a"[0]);
        try expect(b[1].key_ptr.* == 98);
        try expect(b[1].value_ptr.* == "b"[0]);
        try expect(b[2].key_ptr.* == 99);
        try expect(b[2].value_ptr.* == "c"[0]);
        try expect(b.len == 3);
    }

    {
        var hash_map = AutoArrayHashMap(u32, u8).init(allocator);
        defer hash_map.deinit();
        try expect(zignite.fromAutoArrayHashMap(u32, u8, &hash_map).isEmpty());
    }
}

pub fn FromAutoArrayHashMap(comptime S: type, comptime T: type) type {
    return struct {
        hash_map: *const AutoArrayHashMap(S, T),
        iterator: ?*AutoArrayHashMap(S, T).Iterator,

        pub const Type = ProducerType(@This(), AutoArrayHashMap(S, T).Entry);

        pub inline fn init(hash_map: *const AutoArrayHashMap(S, T)) Type.State {
            return _init(hash_map, null);
        }

        pub fn next(event: Type.Event) Type.Action {
            const h = event.hash_map;
            if (event.iterator) |i| {
                if (i.next()) |v| {
                    return Type.Action._yield(_init(h, i), v);
                } else {
                    return Type.Action._break(_init(h, null));
                }
            } else {
                return Type.Action._continue(_init(h, &h.iterator()));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(hash_map: *const AutoArrayHashMap(S, T), iterator: ?*AutoArrayHashMap(S, T).Iterator) Type.State {
            return .{ .hash_map = hash_map, .iterator = iterator };
        }
    };
}
