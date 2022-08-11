const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

test "empty:" {
    try expect(zignite.empty(i32).isEmpty());
}

pub fn Empty(comptime T: type) type {
    return struct {
        pub const Type = ProducerType(@This(), T);

        pub const init = Type.State{};

        pub fn next(_: Type.Event) Type.Action {
            return Type.Action._break(init);
        }

        pub const deinit = Type.nop;
    };
}
