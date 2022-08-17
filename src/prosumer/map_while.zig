const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "mapWhile" {
    const parseInt = struct {
        pub fn parseInt(x: []const u8) ?i32 {
            return std.fmt.parseInt(i32, x, 10) catch null;
        }
    }.parseInt;

    const Str = []const u8;

    {
        const a = try zignite.fromSlice(Str, &[_]Str{ "+1", "-2", "+three", "-4", "five" }).mapWhile(i32, parseInt).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == -2);
        try expect(a.len == 2);
    }

    {
        try expect(zignite.fromSlice(Str, &[_]Str{ "+one", "-2", "+3", "-4", "five" }).mapWhile(i32, parseInt).isEmpty());
        try expect(zignite.empty(Str).mapWhile(i32, parseInt).isEmpty());
    }
}

pub fn MapWhile(comptime S: type, comptime T: type, comptime transformer: fn (value: S) ?T) type {
    return struct {
        pub const Type = ProsumerType(S, @This(), T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._break(init),
                ._continue => Type.Action._await(init),
                ._yield => |v| break_or_yield(v),
            };
        }

        pub const deinit = Type.nop;

        inline fn break_or_yield(value: S) Type.Action {
            const x = @call(.{ .modifier = .always_inline }, transformer, .{value});
            if (x == null) {
                return Type.Action._break(init);
            } else {
                return Type.Action._yield(init, x.?);
            }
        }
    };
}
