const zignite = @import("../zignite.zig");
const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "put_auto_hash_map:" {
    const allocator = std.testing.allocator;

    {
        const keys = zignite.range(u32, 97, 256);
        const vals = zignite.fromSlice(u8, "abc");
        var hash_map = try keys.zip(vals).toAutoHashMap(u32, u8, allocator);
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
        var hash_map = try keys.zip(vals).toAutoHashMap(u32, u8, allocator);
        defer hash_map.deinit();

        try expect(hash_map.count() == 0);
    }
}

pub fn PutAutoHashMap(comptime S: type, comptime T: type, comptime U: type) type {
    return struct {
        hash_map: *AutoHashMap(T, U),

        pub const Type = ConsumerType(S, @This(), Allocator.Error!void);

        pub inline fn init(hash_map: *AutoHashMap(T, U)) Type.State {
            return .{ .hash_map = hash_map };
        }

        pub fn next(event: Type.Event) Type.Action {
            const h = event.state.hash_map;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(h)),
                ._break => Type.Action._return(init(h), {}),
                ._yield => |v| await_or_throw(h, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_throw(hash_map: *AutoHashMap(T, U), value: S) Type.Action {
            if (hash_map.put(value[0], value[1])) |_| {
                return Type.Action._await(init(hash_map));
            } else |err| {
                return Type.Action._return(init(hash_map), err);
            }
        }
    };
}
