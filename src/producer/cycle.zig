const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;

test "cycle: {1, 2}" {
    try expect(zignite.empty(i32).cycle().isEmpty());

    var buffer2: [10]i32 = undefined;
    const b2 = zignite.range(i32, 1, 2).cycle().take(10).toSlice(&buffer2).?;
    try expect(b2[0] == 1);
    try expect(b2[1] == 2);
    try expect(b2[2] == 1);
    try expect(b2[3] == 2);
    try expect(b2[4] == 1);
    try expect(b2[5] == 2);
    try expect(b2[6] == 1);
    try expect(b2[7] == 2);
    try expect(b2[8] == 1);
    try expect(b2[9] == 2);
    // ...
}

pub fn Cycle(comptime S: type, comptime T: type, comptime pd_next: ProducerType(S, T).Next, comptime pd_deinit: ProducerType(S, T).Deinit) type {
    return struct {
        const Pd = ProducerType(S, T);

        reset_state: Pd.State,
        action: Pd.Action,
        is_empty: bool,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(state: Pd.State) Type.State {
            return _init(state, Pd.Action._continue(state), true);
        }

        pub fn next(event: Type.Event) Type.Action {
            const PdA = Pd.Action;
            const r = event.reset_state;
            const a = event.action;
            const i = event.is_empty;
            const s = a.state;

            return switch (a.tag) {
                ._continue => Type.Action._continue(_init(r, pd_n(s), i)),
                ._yield => |v| Type.Action._yield(_init(r, PdA._continue(s), false), v),
                ._break => if (i) Type.Action._break(event) else Type.Action._continue(_init(r, PdA._continue(r), i)),
            };
        }

        pub fn deinit(state: Type.State) void {
            defer pd_deinit(state.action.state);
        }

        inline fn _init(reset_state: Pd.State, action: Pd.Action, is_empty: bool) Type.State {
            return .{ .reset_state = reset_state, .action = action, .is_empty = is_empty };
        }

        inline fn pd_n(event: Pd.Event) Pd.Action {
            return @call(.{ .modifier = .always_inline }, pd_next, .{event});
        }
    };
}
