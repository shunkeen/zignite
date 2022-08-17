const zignite = @import("../zignite.zig");
const std = @import("std");
const BoundedArray = std.BoundedArray;
const expect = std.testing.expect;
const ObverseIndex = @import("obverse_index.zig").ObverseIndex;

test "from_bounded_array:" {
    const Str10 = BoundedArray(u8, 10);

    {
        const a = try Str10.fromSlice("ABC");
        var buffer1: [10]u8 = undefined;
        const b1 = zignite.fromBoundedArray(u8, 10, &a).toSlice(&buffer1).?;
        try expect(b1[0] == 'A');
        try expect(b1[1] == 'B');
        try expect(b1[2] == 'C');
        try expect(b1.len == 3);
    }

    {
        const a = try Str10.init(0);
        try expect(zignite.fromBoundedArray(u8, 10, &a).isEmpty());
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
