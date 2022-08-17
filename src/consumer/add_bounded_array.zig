const zignite = @import("../zignite.zig");
const std = @import("std");
const BoundedArray = std.BoundedArray;
const expect = std.testing.expect;
const TrySet = @import("try_set.zig").TrySet;

test "add_bounded_array:" {
    {
        const array = try zignite.range(i32, 1, 3).toBoundedArray(10);
        try expect(array.get(0) == 1);
        try expect(array.get(1) == 2);
        try expect(array.get(2) == 3);
        try expect(array.len == 3);
    }

    {
        const array = try zignite.empty(i32).toBoundedArray(10);
        try expect(array.len == 0);
    }

    {
        if (zignite.range(i32, 1, 11).toBoundedArray(10)) |_| {
            unreachable;
        } else |err| {
            try expect(err == error.Overflow);
        }
    }
}

pub fn AddBoundedArray(comptime T: type, comptime capacity: usize) type {
    return TrySet(T, *BoundedArray(T, capacity), error{Overflow}, struct {
        fn set(list: *BoundedArray(T, capacity), value: T) error{Overflow}!void {
            (try list.addOne()).* = value;
        }
    }.set);
}
