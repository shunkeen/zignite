const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "takeWhile" {
    const odd = struct {
        pub fn odd(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.odd;

    {
        const a = try zignite.fromSlice(i32, &[_]i32{ 1, 3, 4, 5, 6 }).takeWhile(odd).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == 3);
        try expect(a.len == 2);
    }

    {
        try expect(zignite.range(i32, 0, 3).takeWhile(odd).isEmpty());
        try expect(zignite.empty(i32).takeWhile(odd).isEmpty());
    }
}

pub fn TakeWhile(comptime T: type, comptime predicate: fn (value: T) bool) type {
    return struct {
        pub const Type = ProsumerType(T, @This(), T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._break(init),
                ._continue => Type.Action._await(init),
                ._yield => |v| if (p(v)) Type.Action._yield(init, v) else Type.Action._break(init),
            };
        }

        pub const deinit = Type.nop;

        inline fn p(value: T) bool {
            return @call(.{ .modifier = .always_inline }, predicate, .{value});
        }
    };
}
