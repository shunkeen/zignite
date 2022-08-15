const zignite = @import("../zignite.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "append_array_list:" {
    const allocator = std.testing.allocator;

    {
        const list = try zignite.range(i32, 1, 3).toArrayList(allocator);
        defer list.deinit();

        try expect(list.items[0] == 1);
        try expect(list.items[1] == 2);
        try expect(list.items[2] == 3);
        try expect(list.items.len == 3);
    }

    {
        const list = try zignite.empty(i32).toArrayList(allocator);
        defer list.deinit();
        try expect(list.items.len == 0);
    }
}

pub fn AppendArrayList(comptime T: type) type {
    return struct {
        list: *ArrayList(T),

        pub const Type = ConsumerType(T, @This(), Allocator.Error!void);

        pub inline fn init(list: *ArrayList(T)) Type.State {
            return .{ .list = list };
        }

        pub fn next(event: Type.Event) Type.Action {
            const l = event.state.list;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(l)),
                ._break => Type.Action._return(init(l), {}),
                ._yield => |v| await_or_throw(l, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_throw(list: *ArrayList(T), value: T) Type.Action {
            if (list.append(value)) |_| {
                return Type.Action._await(init(list));
            } else |err| {
                return Type.Action._return(init(list), err);
            }
        }
    };
}