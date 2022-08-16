const zignite = @import("../zignite.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const expect = std.testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "from_array_list:" {
    const allocator = std.testing.allocator;

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try list.append(1);
        try list.append(2);
        try list.append(3);

        var buffer: [10]i32 = undefined;
        const b = zignite.fromArrayList(i32, &list).toSlice(&buffer).?;

        try expect(b[0] == 1);
        try expect(b[1] == 2);
        try expect(b[2] == 3);
        try expect(b.len == 3);
    }

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try expect(zignite.fromArrayList(i32, &list).isEmpty());
    }
}

pub fn FromArrayList(comptime T: type) type {
    return struct {
        list: *const ArrayList(T),
        index: usize,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(list: *const ArrayList(T)) Type.State {
            return _init(list, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const l = event.list;
            const i = event.index;
            if (0 <= i and i < l.items.len) {
                return Type.Action._yield(_init(l, i + 1), l.items[i]);
            } else {
                return Type.Action._break(_init(l, i));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(list: *const ArrayList(T), index: usize) Type.State {
            return .{ .list = list, .index = index };
        }
    };
}
