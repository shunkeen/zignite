const zignite = @import("../zignite.zig");
const std = @import("std");
const BoundedArray = std.BoundedArray;
const expect = std.testing.expect;
const ReverseIndex = @import("reverse_index.zig").ReverseIndex;

test "revBoundedArray" {
    const Str10 = BoundedArray(u8, 10);

    {
        const s = try Str10.fromSlice("ABC");
        const a = try zignite.revBoundedArray(u8, 10, &s).toBoundedArray(10);
        try expect(a.get(0) == 'C');
        try expect(a.get(1) == 'B');
        try expect(a.get(2) == 'A');
        try expect(a.len == 3);
    }

    {
        const s = try Str10.init(0);
        try expect(zignite.revBoundedArray(u8, 10, &s).isEmpty());
    }
}

pub fn RevBoundedArray(comptime T: type, comptime capacity: usize) type {
    return struct {
        const List = *const BoundedArray(T, capacity);
        const I = ReverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list.get(index);
        }
    }.I;
}
