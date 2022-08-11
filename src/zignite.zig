const std = @import("std");

test "reference all declarations" {
    std.testing.refAllDecls(@This());
}

const _FromSlice = @import("./producer/from_slice.zig").FromSlice;

const _Bomb = @import("./hermit/bomb.zig").Bomb;
const _ToSlice = @import("./consumer/to_slice.zig").ToSlice;

pub fn FromSlice(comptime T: type) type {
    return Zignite(_FromSlice(T));
}

pub inline fn fromSlice(comptime T: type, slice: []const T) FromSlice(T) {
    return .{ .producer = _FromSlice(T).init(slice) };
}

pub fn Zignite(comptime Producer: type) type {
    return struct {
        producer: Producer,

        const Self = @This();
        pub const Producer = Producer;
        pub const Type = Producer.Type;
        pub const State = Producer.Type.State;
        pub const Out = Producer.Type.Out;
        const next = Producer.next;
        const deinit = Producer.deinit;

        pub inline fn bomb(self: Self, consumer: anytype) @TypeOf(consumer).Type.Out {
            const Cs = @TypeOf(consumer);
            const Hm = _Bomb(State, Out, next, deinit, Cs.Type.State, Cs.Type.Out, Cs.next, Cs.deinit);
            return Hm.run(self.producer, consumer);
        }

        pub inline fn toSlice(self: Self, buffer: []Out) ?[]const Out {
            return self.bomb(_ToSlice(Out).init(buffer));
        }
    };
}
