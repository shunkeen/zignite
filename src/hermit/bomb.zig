const HermitType = @import("hermit_type.zig").HermitType;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;
const ConsumerType = @import("../consumer/consumer_type.zig").ConsumerType;

pub fn Bomb(comptime R: type, comptime S: type, comptime pd_next: ProducerType(R, S).Next, comptime pd_deinit: ProducerType(R, S).Deinit, comptime T: type, comptime U: type, comptime cs_next: ConsumerType(S, T, U).Next, comptime cs_deinit: ConsumerType(S, T, U).Deinit) type {
    return struct {
        const Pd = ProducerType(R, S);
        const Cs = ConsumerType(S, T, U);

        pd_action: Pd.Action,
        cs_action: Cs.Action,

        pub const Type = HermitType(@This(), Cs.Out);

        pub inline fn init(pd_state: Pd.State, cs_state: Cs.State) Type.State {
            return _init(Pd.Action._continue(pd_state), Cs.Action._continue(cs_state));
        }

        pub fn next(event: Type.Event) Type.Action {
            const A = Type.Action;

            const PdA = Pd.Action;
            const pd_a = event.pd_action;
            const pd_s = pd_a.state;

            const CsA = Cs.Action;
            const CsE = Cs.Event;
            const cs_a = event.cs_action;
            const cs_s = cs_a.state;

            return switch (cs_a.tag) {
                ._continue => A._continue(_init(pd_a, cs_n(CsE._continue(cs_s)))),
                ._return => |cs_o| A._return(_init(pd_a, CsA._return(cs_s, cs_o)), cs_o),
                ._await => switch (pd_a.tag) {
                    ._continue => A._continue(_init(pd_n(pd_s), cs_a)),
                    ._break => A._continue(_init(pd_a, cs_n(CsE._break(cs_s)))),
                    ._yield => |pd_o| A._continue(_init(PdA._continue(pd_s), cs_n(CsE._yield(pd_o, cs_s)))),
                },
            };
        }

        pub fn deinit(state: Type.State) void {
            defer pd_deinit(state.pd_action.state);
            defer cs_deinit(state.cs_action.state);
        }

        pub inline fn run(pd_state: Pd.State, cs_state: Cs.State) Type.Out {
            return Type.run(init(pd_state, cs_state), next, deinit);
        }

        inline fn pd_n(pd_event: Pd.Event) Pd.Action {
            return @call(.always_inline, pd_next, .{pd_event});
        }

        inline fn cs_n(cs_event: Cs.Event) Cs.Action {
            return @call(.always_inline, cs_next, .{cs_event});
        }

        inline fn _init(pd_action: Pd.Action, cs_action: Cs.Action) Type.State {
            return .{ .pd_action = pd_action, .cs_action = cs_action };
        }
    };
}
