const zignite = @import("../zignite.zig");
const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const expect = std.testing.expect;
const ReverseIndex = @import("reverse_index.zig").ReverseIndex;

test "revMultiArrayList" {
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

        const array = try zignite.revMultiArrayList(Foo, &list).toBoundedArray(10);
        try expect(array.get(0).a == 3);
        try expect(array.get(0).b == 4);
        try expect(array.get(1).a == 1);
        try expect(array.get(1).b == 2);
        try expect(array.len == 2);
    }

    {
        var list = MultiArrayList(Foo){};
        defer list.deinit(allocator);
        try expect(zignite.revMultiArrayList(Foo, &list).isEmpty());
    }
}

pub fn RevMultiArrayList(comptime T: type) type {
    return struct {
        const List = *const MultiArrayList(T);
        const I = ReverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list.get(index);
        }
    }.I;
}
