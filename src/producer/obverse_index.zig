const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("producer_type.zig").ProducerType;

pub fn ObverseIndex(comptime S: type, comptime T: type, comptime len: fn (state: S) usize, comptime get: fn (state: S, index: usize) T) type {
    return struct {
        state: S,
        index: usize,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(state: S) Type.State {
            return _init(state, 0);
        }

        pub fn next(event: Type.Event) Type.Action {
            const s = event.state;
            const i = event.index;
            if (0 <= i and i < _len(s)) {
                return Type.Action._yield(_init(s, i + 1), _get(s, i));
            } else {
                return Type.Action._break(_init(s, i));
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(state: S, index: usize) Type.State {
            return .{ .state = state, .index = index };
        }

        inline fn _len(state: S) usize {
            return @call(.{ .modifier = .always_inline }, len, .{state});
        }

        inline fn _get(state: S, index: usize) T {
            return @call(.{ .modifier = .always_inline }, get, .{ state, index });
        }
    };
}
