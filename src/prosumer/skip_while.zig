const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "skipWhile" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    {
        const a = try zignite.fromSlice(i32, &[_]i32{ 1, 3, 4, 5, 6 }).skipWhile(odd).toBoundedArray(10);
        try expect(a.get(0) == 4);
        try expect(a.get(1) == 5);
        try expect(a.get(2) == 6);
        try expect(a.len == 3);
    }

    {
        try expect(zignite.fromSlice(i32, &[_]i32{ 1, 3, 5 }).skipWhile(odd).isEmpty());
        try expect(zignite.empty(i32).skipWhile(odd).isEmpty());
    }
}

pub fn SkipWhile(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        skip: bool,

        pub const Type = ProsumerType(T, @This(), T);

        pub const init = _init(true);

        pub fn next(event: Type.Event) Type.Action {
            const s = event.state.skip;
            return switch (event.tag) {
                ._break => Type.Action._break(_init(s)),
                ._continue => Type.Action._await(_init(s)),
                ._yield => |v| await_or_yield(s, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_yield(skip: bool, value: T) Type.Action {
            const a_i = .{ .modifier = .always_inline };
            if (skip and @call(a_i, predicate, .{value})) {
                return Type.Action._await(_init(true));
            } else {
                return Type.Action._yield(_init(false), value);
            }
        }

        inline fn _init(skip: bool) Type.State {
            return .{ .skip = skip };
        }
    };
}
