const ProducerType = @import("../producer/producer_type.zig").ProducerType;
const ProsumerType = @import("../prosumer/prosumer_type.zig").ProsumerType;

pub fn Fuse(comptime R: type, comptime S: type, comptime pd_next: ProducerType(R, S).Next, comptime pd_deinit: ProducerType(R, S).Deinit, comptime T: type, comptime U: type, comptime ps_next: ProsumerType(S, T, U).Next, comptime ps_deinit: ProsumerType(S, T, U).Deinit) type {
    return struct {
        const Pd = ProducerType(R, S);
        const Ps = ProsumerType(S, T, U);

        pd_action: Pd.Action,
        ps_action: Ps.Action,

        pub const Type = ProducerType(@This(), Ps.Out);

        pub inline fn init(pd_state: Pd.State, ps_state: Ps.State) Type.State {
            return _init(Pd.Action._continue(pd_state), Ps.Action._continue(ps_state));
        }

        pub fn next(event: Type.Event) Type.Action {
            const A = Type.Action;

            const PdA = Pd.Action;
            const pd_a = event.pd_action;
            const pd_s = pd_a.state;

            const PsA = Ps.Action;
            const PsE = Ps.Event;
            const ps_a = event.ps_action;
            const ps_s = ps_a.state;

            return switch (ps_a.tag) {
                ._break => A._break(_init(pd_a, ps_a)),
                ._continue => A._continue(_init(pd_a, ps_n(PsE._continue(ps_s)))),
                ._yield => |ps_o| A._yield(_init(pd_a, PsA._continue(ps_s)), ps_o),
                ._await => switch (pd_a.tag) {
                    ._continue => A._continue(_init(pd_n(pd_s), ps_a)),
                    ._break => A._continue(_init(pd_a, ps_n(PsE._break(ps_s)))),
                    ._yield => |pd_o| A._continue(_init(PdA._continue(pd_s), ps_n(PsE._yield(pd_o, ps_s)))),
                },
            };
        }

        pub fn deinit(state: Type.State) void {
            defer pd_deinit(state.pd_action.state);
            defer ps_deinit(state.ps_action.state);
        }

        inline fn pd_n(pd_event: Pd.Event) Pd.Action {
            return @call(.{ .modifier = .always_inline }, pd_next, .{pd_event});
        }

        inline fn ps_n(ps_event: Ps.Event) Ps.Action {
            return @call(.{ .modifier = .always_inline }, ps_next, .{ps_event});
        }

        inline fn _init(pd_action: Pd.Action, ps_action: Ps.Action) Type.State {
            return .{ .pd_action = pd_action, .ps_action = ps_action };
        }
    };
}
