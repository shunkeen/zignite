const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Fold = @import("fold.zig").Fold;

test "product:" {
    try expect(zignite.range(u32, 1, 5).product() == 120);
    try expect(zignite.once(f16, 3.0).product() == 3.0);
    try expect(zignite.empty(i32).product() == 1);
}

pub fn Product(comptime T: type) type {
    if (comptime !std.meta.trait.isNumber(T)) {
        @compileError("!std.meta.trait.isNumber(" ++ @typeName(T) ++ ")");
    }

    return struct {
        const F = Fold(T, T, multiplication);
        fn multiplication(x: T, y: T) T {
            return x * y;
        }

        pub const Type = F.Type;
        pub const init = F.init(1);
        pub const next = F.next;
        pub const deinit = F.deinit;
    };
}
