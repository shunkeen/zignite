const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;

test "chain" {
    const p_1_2 = zignite.range(i32, 1, 2);
    const p_4_8 = zignite.fromSlice(i32, &[_]i32{ 4, 8 });
    const p_emp = zignite.empty(i32);

    {
        const a = try p_1_2.chain(p_4_8).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == 2);
        try expect(a.get(2) == 4);
        try expect(a.get(3) == 8);
        try expect(a.len == 4);
    }

    {
        const a = try p_1_2.chain(p_emp).toBoundedArray(10);
        try expect(a.get(0) == 1);
        try expect(a.get(1) == 2);
        try expect(a.len == 2);
    }

    {
        const a = try p_emp.chain(p_4_8).toBoundedArray(10);
        try expect(a.get(0) == 4);
        try expect(a.get(1) == 8);
        try expect(a.len == 2);
    }

    {
        try expect(p_emp.chain(p_emp).isEmpty());
    }
}

pub fn Chain(comptime S: type, comptime T: type, comptime next1: ProducerType(S, T).Next, comptime deinit1: ProducerType(S, T).Deinit, comptime U: type, comptime next2: ProducerType(U, T).Next, comptime deinit2: ProducerType(U, T).Deinit) type {
    return struct {
        const Pd1 = ProducerType(S, T);
        const Pd2 = ProducerType(U, T);

        action1: Pd1.Action,
        action2: Pd2.Action,

        pub const Type = ProducerType(@This(), T);

        pub inline fn init(state1: Pd1.State, state2: Pd2.State) Type.State {
            return _init(Pd1.Action._continue(state1), Pd2.Action._continue(state2));
        }

        pub fn next(event: Type.Event) Type.Action {
            const Pd1A = Pd1.Action;
            const a1 = event.action1;
            const s1 = a1.state;

            const Pd2A = Pd2.Action;
            const a2 = event.action2;
            const s2 = a2.state;

            return switch (a1.tag) {
                ._continue => Type.Action._continue(_init(n1(s1), Pd2A._continue(s2))),
                ._yield => |v| Type.Action._yield(_init(Pd1A._continue(s1), Pd2A._continue(s2)), v),
                ._break => switch (a2.tag) {
                    ._continue => Type.Action._continue(_init(Pd1A._break(s1), n2(s2))),
                    ._yield => |v| Type.Action._yield(_init(Pd1A._break(s1), n2(s2)), v),
                    ._break => Type.Action._break(_init(Pd1A._break(s1), Pd2A._break(s2))),
                },
            };
        }

        pub fn deinit(state: Type.State) void {
            defer deinit1(state.action1.state);
            defer deinit2(state.action2.state);
        }

        inline fn _init(action1: Pd1.Action, action2: Pd2.Action) Type.State {
            return .{ .action1 = action1, .action2 = action2 };
        }

        inline fn n1(event1: Pd1.Event) Pd1.Action {
            return @call(.{ .modifier = .always_inline }, next1, .{event1});
        }

        inline fn n2(event2: Pd2.Event) Pd2.Action {
            return @call(.{ .modifier = .always_inline }, next2, .{event2});
        }
    };
}
