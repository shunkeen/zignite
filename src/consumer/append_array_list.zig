const zignite = @import("../zignite.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const TrySet = @import("try_set.zig").TrySet;

test "append_array_list:" {
    const allocator = std.testing.allocator;

    {
        const list = try zignite.range(i32, 1, 3).toArrayList(allocator);
        defer list.deinit();

        try expect(list.items[0] == 1);
        try expect(list.items[1] == 2);
        try expect(list.items[2] == 3);
        try expect(list.items.len == 3);
    }

    {
        const list = try zignite.empty(i32).toArrayList(allocator);
        defer list.deinit();
        try expect(list.items.len == 0);
    }
}

pub fn AppendArrayList(comptime T: type) type {
    return TrySet(T, *ArrayList(T), Allocator.Error, struct {
        fn set(list: *ArrayList(T), value: T) Allocator.Error!void {
            try list.append(value);
        }
    }.set);
}
