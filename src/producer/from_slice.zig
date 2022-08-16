const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ObverseIndex = @import("obverse_index.zig").ObverseIndex;

test "from_slice:" {
    var buffer1: [10]u8 = undefined;
    const b1 = zignite.fromSlice(u8, "ABC").toSlice(&buffer1).?;
    try expect(b1[0] == 'A');
    try expect(b1[1] == 'B');
    try expect(b1[2] == 'C');
    try expect(b1.len == 3);

    var buffer2: [10]u8 = undefined;
    const b2 = zignite.fromSlice(u8, "ABCDEF"[2..5]).toSlice(&buffer2).?;
    try expect(b2[0] == 'C');
    try expect(b2[1] == 'D');
    try expect(b2[2] == 'E');
    try expect(b2.len == 3);

    try expect(zignite.fromSlice(u8, "").isEmpty());
}

pub fn FromSlice(comptime T: type) type {
    return struct {
        const List = []const T;
        const I = ObverseIndex(List, T, len, get);

        fn len(list: List) usize {
            return list.len;
        }

        fn get(list: List, index: usize) T {
            return list[index];
        }
    }.I;
}
