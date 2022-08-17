const zignite = @import("../zignite.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const expect = std.testing.expect;
const ObverseIndex = @import("obverse_index.zig").ObverseIndex;

test "fromArrayList" {
    const allocator = std.testing.allocator;

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try list.append(1);
        try list.append(2);
        try list.append(3);

        const a = try zignite.fromArrayList(i32, &list).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == 2);
        try expect(a.get(2) == 3);
        try expect(a.len == 3);
    }

    {
        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        try expect(zignite.fromArrayList(i32, &list).isEmpty());
    }
}

pub fn FromArrayList(comptime T: type) type {
    return struct {
        const List = *const ArrayList(T);
        const I = ObverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.items.len;
        }

        fn get(list: List, index: usize) T {
            return list.items[index];
        }
    }.I;
}
