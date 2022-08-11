const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "is_epmty:" {
    try expect(zignite.empty(i32).isEmpty());
    try expect(zignite.fromSlice(i32, &[_]i32{}).isEmpty());

    try expect(!zignite.fromSlice(i32, &[_]i32{1}).isEmpty());
    try expect(!zignite.fromSlice(i32, &[_]i32{ 0, 1 }).isEmpty());
}

pub fn IsEmpty(comptime T: type) type {
    return struct {
        pub const Type = ConsumerType(T, @This(), bool);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._return(init, true),
                ._continue => Type.Action._await(init),
                ._yield => Type.Action._return(init, false),
            };
        }

        pub const deinit = Type.nop;
    };
}
