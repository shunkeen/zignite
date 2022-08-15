const zignite = @import("../zignite.zig");
const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "append_multi_array_list:" {
    const Foo = struct {
        a: u32,
        b: u8,
    };

    const f12 = Foo{ .a = 1, .b = 2 };
    const f34 = Foo{ .a = 3, .b = 4 };
    const allocator = std.testing.allocator;

    {
        var list = try zignite.fromSlice(Foo, &[_]Foo{ f12, f34 }).toMultiArrayList(allocator);
        defer list.deinit(allocator);

        try expect(list.items(.a)[0] == 1);
        try expect(list.items(.a)[1] == 3);
        try expect(list.items(.b)[0] == 2);
        try expect(list.items(.b)[1] == 4);
        try expect(list.len == 2);
    }

    {
        var list = try zignite.empty(Foo).toMultiArrayList(allocator);
        defer list.deinit(allocator);
        try expect(list.len == 0);
    }
}

pub fn AppendMultiArrayList(comptime T: type) type {
    return struct {
        list: *MultiArrayList(T),
        allocator: Allocator,

        pub const Type = ConsumerType(T, @This(), Allocator.Error!void);

        pub inline fn init(list: *MultiArrayList(T), allocator: Allocator) Type.State {
            return .{ .list = list, .allocator = allocator };
        }

        pub fn next(event: Type.Event) Type.Action {
            const l = event.state.list;
            const a = event.state.allocator;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(l, a)),
                ._break => Type.Action._return(init(l, a), {}),
                ._yield => |v| await_or_throw(l, a, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_throw(list: *MultiArrayList(T), allocator: Allocator, value: T) Type.Action {
            if (list.append(allocator, value)) |_| {
                return Type.Action._await(init(list, allocator));
            } else |err| {
                return Type.Action._return(init(list, allocator), err);
            }
        }
    };
}
