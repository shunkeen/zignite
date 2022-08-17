const zignite = @import("../zignite.zig");
const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const TrySet = @import("try_set.zig").TrySet;

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

        const Cs = TrySet(T, @This(), Allocator.Error, set);
        fn set(state: @This(), value: T) Allocator.Error!void {
            try state.list.append(state.allocator, value);
        }

        pub const Type = Cs.Type;
        pub const next = Cs.next;
        pub const deinit = Cs.deinit;

        pub inline fn init(list: *MultiArrayList(T), allocator: Allocator) Cs {
            return Cs.init(.{ .list = list, .allocator = allocator });
        }
    };
}
