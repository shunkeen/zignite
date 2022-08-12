const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const Fold = @import("fold.zig").Fold;

test "reduce: *" {
    const mul = struct {
        pub fn mul(x: u32, y: u32) u32 {
            return x * y;
        }
    }.mul;

    try expect(zignite.range(u32, 1, 5).reduce(mul).? == 120);
    try expect(zignite.empty(u32).reduce(mul) == null);
}

pub fn Reduce(comptime T: type, comptime reducer: fn (accumulator: T, value: T) T) type {
    return struct {
        const F = Fold(?T, T, r);
        fn r(a: ?T, v: T) ?T {
            const a_i = .{ .modifier = .always_inline };
            return if (a == null) v else @call(a_i, reducer, .{ a.?, v });
        }

        pub const Type = F.Type;
        pub const init = F.init(null);
        pub const next = F.next;
        pub const deinit = F.deinit;
    };
}
