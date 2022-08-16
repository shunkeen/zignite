const zignite = @import("../zignite.zig");
const std = @import("std");
const BufMap = std.BufMap;
const BufMapHashMap = std.StringHashMap([]const u8);
const expect = std.testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "from_buf_map:" {
    const allocator = std.testing.allocator;
    {
        var buf_map = BufMap.init(allocator);
        defer buf_map.deinit();
        try buf_map.put("key1", "val1");
        try buf_map.put("key2", "val2");
        try buf_map.put("key3", "val3");

        var buffer: [10]BufMapHashMap.Entry = undefined;
        for (zignite.fromBufMap(&buf_map).toSlice(&buffer).?) |entry| {
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

pub const FromBufMap = struct {
    buf_map: *const BufMap,
    iterator: ?*BufMapHashMap.Iterator,

    pub const Type = ProducerType(@This(), BufMapHashMap.Entry);

    pub inline fn init(buf_map: *const BufMap) Type.State {
        return _init(buf_map, null);
    }

    pub fn next(event: Type.Event) Type.Action {
        const b = event.buf_map;
        if (event.iterator) |i| {
            if (i.next()) |v| {
                return Type.Action._yield(_init(b, i), v);
            } else {
                return Type.Action._break(_init(b, null));
            }
        } else {
            return Type.Action._continue(_init(b, &b.iterator()));
        }
    }

    pub const deinit = Type.nop;

    inline fn _init(buf_map: *const BufMap, iterator: ?*BufMapHashMap.Iterator) Type.State {
        return .{ .buf_map = buf_map, .iterator = iterator };
    }
};
