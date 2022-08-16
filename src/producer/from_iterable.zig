const zignite = @import("../zignite.zig");
const ProducerType = @import("producer_type.zig").ProducerType;

pub fn FromIterable(comptime S: type, comptime T: type, comptime U: type) type {
    return struct {
        iterable: S,
        iterator: ?*T,
        pub const Type = ProducerType(@This(), U);

        pub inline fn init(iterable: S) Type.State {
            return _init(iterable, null);
        }

        pub fn next(event: Type.Event) Type.Action {
            const i = event.iterable;
            if (event.iterator) |j| {
                if (j.next()) |v| {
                    return Type.Action._yield(_init(i, j), v);
                } else {
                    return Type.Action._break(_init(i, null));
                }
            } else {
                return Type.Action._continue(_init(i, &i.iterator()));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(iterable: S, iterator: ?*T) Type.State {
            return .{ .iterable = iterable, .iterator = iterator };
        }
    };
}
