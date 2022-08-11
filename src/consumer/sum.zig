const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Fold = @import("fold.zig").Fold;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "sum:" {
    try expect(zignite.range(u32, 1, 5).sum() == 15);
    try expect(zignite.once(f16, 3.0).sum() == 3.0);
    try expect(zignite.empty(i32).sum() == 0);
    try expect(zignite.fromSlice(f32, &[_]f32{ 1, 0.1, 0.01, 0.001, 0.0001, 0.00001 }).sum() == 1.11111);
}

pub fn Sum(comptime T: type) type {
    if (comptime !std.meta.trait.isNumber(T)) {
        @compileError("!std.meta.trait.isNumber(" ++ @typeName(T) ++ ")");
    }

    if (comptime std.meta.trait.isIntegral(T)) {
        return struct {
            const F = Fold(T, T, addition);
            fn addition(x: T, y: T) T {
                return x + y;
            }

            pub const Type = F.Type;
            pub const init = F.init(0);
            pub const next = F.next;
            pub const deinit = F.deinit;
        };
    }

    return struct {
        accumulator: T,
        kahan: T,

        pub const Type = ConsumerType(T, @This(), T);

        pub const init = _init(0.0, 0.0);

        pub fn next(event: Type.Event) Type.Action {
            const a = event.state.accumulator;
            const k = event.state.kahan;
            switch (event.tag) {
                ._continue => return Type.Action._await(_init(a, k)),
                ._break => return Type.Action._return(_init(a, k), a),
                ._yield => |v| {
                    @setFloatMode(.Strict);
                    const v2 = v - k;
                    const a2 = a + v2;
                    return Type.Action._await(_init(a2, (a2 - a) - v2));
                },
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(accumulator: T, kahan: T) Type.State {
            return .{ .accumulator = accumulator, .kahan = kahan };
        }
    };
}
