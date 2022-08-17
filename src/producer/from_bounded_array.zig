const zignite = @import("../zignite.zig");
const std = @import("std");
const BoundedArray = std.BoundedArray;
const expect = std.testing.expect;
const ObverseIndex = @import("obverse_index.zig").ObverseIndex;

test "fromBoundedArray" {
    const Str10 = BoundedArray(u8, 10);

    {
        const s = try Str10.fromSlice("ABC");
        const a = try zignite.fromBoundedArray(u8, 10, &s).toBoundedArray(10);
        try expect(a.get(0) == 'A');
        try expect(a.get(1) == 'B');
        try expect(a.get(2) == 'C');
        try expect(a.len == 3);
    }

    {
        const s = try Str10.init(0);
        try expect(zignite.fromBoundedArray(u8, 10, &s).isEmpty());
    }
}

pub fn FromBoundedArray(comptime T: type, comptime capacity: usize) type {
    return struct {
        const List = *const BoundedArray(T, capacity);
        const I = ObverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list.get(index);
        }
    }.I;
}
