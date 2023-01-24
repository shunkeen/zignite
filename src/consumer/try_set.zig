const zignite = @import("../zignite.zig");
const ConsumerType = @import("consumer_type.zig").ConsumerType;

pub fn TrySet(comptime R: type, comptime S: type, comptime T: type, comptime set: fn (state: S, value: R) T!void) type {
    return struct {
        state: S,

        pub const Type = ConsumerType(R, @This(), T!void);

        pub inline fn init(state: S) Type.State {
            return .{ .state = state };
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.state.state;
            return switch (event.tag) {
                ._continue => Type.Action._await(init(s)),
                ._break => Type.Action._return(init(s), {}),
                ._yield => |v| await_or_throw(s, v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_throw(state: S, value: R) Type.Action {
            if (_set(state, value)) |_| {
                return Type.Action._await(init(state));
            } else |err| {
                return Type.Action._return(init(state), err);
            }
        }

        inline fn _set(state: S, value: R) T!void {
            return @call(.always_inline, set, .{ state, value });
        }
    };
}
