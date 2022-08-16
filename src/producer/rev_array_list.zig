const zignite = @import("../zignite.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const expect = std.testing.expect;
const ReverseIndex = @import("reverse_index.zig").ReverseIndex;

test "rev_array_list:" {
    const allocator = std.testing.allocator;

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try list.append(1);
        try list.append(2);
        try list.append(3);

        var buffer: [10]i32 = undefined;
        const b = zignite.revArrayList(i32, &list).toSlice(&buffer).?;

        try expect(b[0] == 3);
        try expect(b[1] == 2);
        try expect(b[2] == 1);
        try expect(b.len == 3);
    }

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try expect(zignite.revArrayList(i32, &list).isEmpty());
    }
}

pub fn RevArrayList(comptime T: type) type {
    return struct {
        const List = *const ArrayList(T);
        const I = ReverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.items.len;
        }

        fn get(list: List, index: usize) T {
            return list.items[index];
        }
    }.I;
}
