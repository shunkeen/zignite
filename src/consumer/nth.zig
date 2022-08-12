const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "nth:" {
    try expect(zignite.range(i32, 10, 5).nth(0).? == 10);
    try expect(zignite.range(i32, 10, 5).nth(2).? == 12);
    try expect(zignite.range(i32, 10, 5).nth(4).? == 14);
    try expect(zignite.range(i32, 10, 5).nth(5) == null);
    try expect(zignite.empty(i32).nth(0) == null);
}

pub fn Nth(comptime T: type) type {
    return struct {
        count: usize,

        pub const Type = ConsumerType(T, @This(), ?T);

        pub inline fn init(count: usize) Type.State {
            return .{ .count = count };
        }

        pub fn next(event: Type.Event) Type.Action {
            const c = event.state.count;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(c)),
                ._break => Type.Action._return(init(c), null),
                ._yield => |v| if (c == 0) Type.Action._return(init(c), v) else Type.Action._continue(init(c - 1)),
            };
        }

        pub const deinit = Type.nop;
    };
}
