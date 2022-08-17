const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "skip" {
    {
        const a = try zignite.range(i32, 1, 5).skip(3).toBoundedArray(10);
        try expect(a.get(0) == 4);
        try expect(a.get(1) == 5);
        try expect(a.len == 2);
    }

    {
        const a = try zignite.range(i32, 1, 2).skip(0).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == 2);
        try expect(a.len == 2);
    }

    {
        try expect(zignite.range(i32, 1, 2).skip(3).isEmpty());
        try expect(zignite.empty(i32).skip(3).isEmpty());
    }
}

pub fn Skip(comptime T: type) type {
    return struct {
        count: usize,

        pub const Type = ProsumerType(T, @This(), T);

        pub inline fn init(count: usize) Type.State {
            return .{ .count = count };
        }

        pub fn next(event: Type.Event) Type.Action {
            const c = event.state.count;
            return switch (event.tag) {
                ._yield => |v| yield_or_await(c, v),
                ._break => Type.Action._break(init(c)),
                ._continue => Type.Action._await(init(c)),
            };
        }

        pub const deinit = Type.nop;

        inline fn yield_or_await(count: usize, value: T) Type.Action {
            if (count <= 0) {
                return Type.Action._yield(init(count), value);
            } else {
                return Type.Action._await(init(count - 1));
            }
        }
    };
}
