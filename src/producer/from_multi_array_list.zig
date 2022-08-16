const zignite = @import("../zignite.zig");
const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const expect = std.testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "from_multi_array_list:" {
    const allocator = std.testing.allocator;
    const Foo = struct {
        a: u32,
        b: u8,
    };

    {
        var list = MultiArrayList(Foo){};
        defer list.deinit(allocator);
        try list.append(allocator, .{ .a = 1, .b = 2 });
        try list.append(allocator, .{ .a = 3, .b = 4 });

        var buffer: [10]Foo = undefined;
        const b = zignite.fromMultiArrayList(Foo, &list).toSlice(&buffer).?;
        try expect(b[0].a == 1);
        try expect(b[0].b == 2);
        try expect(b[1].a == 3);
        try expect(b[1].b == 4);
        try expect(b.len == 2);
    }

    {
        var list = MultiArrayList(Foo){};
        defer list.deinit(allocator);

        var buffer: [10]Foo = undefined;
        const b = zignite.fromMultiArrayList(Foo, &list).toSlice(&buffer).?;
        try expect(b.len == 0);
    }
}

pub fn FromMultiArrayList(comptime T: type) type {
    return struct {
        list: *const MultiArrayList(T),
        index: usize,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(list: *const MultiArrayList(T)) Type.State {
            return _init(list, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const l = event.list;
            const i = event.index;
            if (0 <= i and i < l.len) {
                return Type.Action._yield(_init(l, i + 1), l.get(i));
            } else {
                return Type.Action._break(_init(l, i));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(list: *const MultiArrayList(T), index: usize) Type.State {
            return .{ .list = list, .index = index };
        }
    };
}
