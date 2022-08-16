const zignite = @import("../zignite.zig");
const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const expect = std.testing.expect;
const ObverseIndex = @import("obverse_index.zig").ObverseIndex;

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
        try expect(zignite.fromMultiArrayList(Foo, &list).isEmpty());
    }
}

pub fn FromMultiArrayList(comptime T: type) type {
    return struct {
        const List = *const MultiArrayList(T);
        const I = ObverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list.get(index);
        }
    }.I;
}
