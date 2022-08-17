const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ReverseIndex = @import("Reverse_index.zig").ReverseIndex;

test "revSlice" {
    {
        const a = try zignite.revSlice(u8, "ABC").toBoundedArray(10);
        try expect(a.get(0) == 'C');
        try expect(a.get(1) == 'B');
        try expect(a.get(2) == 'A');
        try expect(a.len == 3);
    }

    {
        const a = try zignite.revSlice(u8, "ABCDEF"[2..5]).toBoundedArray(10);
        try expect(a.get(0) == 'E');
        try expect(a.get(1) == 'D');
        try expect(a.get(2) == 'C');
        try expect(a.len == 3);
    }

    {
        try expect(zignite.revSlice(u8, "").isEmpty());
    }
}

pub fn RevSlice(comptime T: type) type {
    return struct {
        const List = []const T;
        const I = ReverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list[index];
        }
    }.I;
}
