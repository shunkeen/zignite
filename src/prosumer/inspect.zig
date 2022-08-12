const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Map = @import("map.zig").Map;

test "inspect:" {
    const sum = struct {
        var acc: i32 = 0;
        pub fn add(x: i32) void {
            acc += x;
        }
    };

    sum.acc = 0;
    try expect(zignite.range(i32, 1, 5).inspect(sum.add).product() == 120);
    try expect(sum.acc == 15);

    sum.acc = 0;
    try expect(zignite.empty(i32).inspect(sum.add).product() == 1);
    try expect(sum.acc == 0);
}

pub fn Inspect(comptime T: type, comptime transformer: fn (value: T) void) type {
    return struct {
        const M = Map(T, T, t);
        fn t(value: T) T {
            @call(.{ .modifier = .always_inline }, transformer, .{value});
            return value;
        }
    }.M;
}
