const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const Tuple = std.meta.Tuple;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;

test "zip" {
    const r = zignite.range(i32, 1, 2);
    const f = zignite.fromSlice(f32, &[_]f32{ 0.4, 0.8, 1.0 });
    const e = zignite.empty(u32);

    {
        const a = try r.zip(f).toBoundedArray(10);
        try expect(a.get(0)[0] == 1);
        try expect(a.get(0)[1] == 0.4);
        try expect(a.get(1)[0] == 2);
        try expect(a.get(1)[1] == 0.8);
        try expect(a.len == 2);
    }

    {
        const a = try f.zip(r).toBoundedArray(10);
        try expect(a.get(0)[0] == 0.4);
        try expect(a.get(0)[1] == 1);
        try expect(a.get(1)[0] == 0.8);
        try expect(a.get(1)[1] == 2);
        try expect(a.len == 2);
    }

    {
        try expect(r.zip(e).isEmpty());
        try expect(e.zip(f).isEmpty());
        try expect(e.zip(e).isEmpty());
    }
}

pub fn Zip(comptime S: type, comptime T: type, comptime next1: ProducerType(S, T).Next, comptime deinit1: ProducerType(S, T).Deinit, comptime U: type, comptime V: type, comptime next2: ProducerType(U, V).Next, comptime deinit2: ProducerType(U, V).Deinit) type {
    return struct {
        const Pd1 = ProducerType(S, T);
        const Pd2 = ProducerType(U, V);

        action1: Pd1.Action,
        action2: Pd2.Action,

        pub const Type = ProducerType(@This(), Tuple(&.{ T, V }));

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
                ._break => Type.Action._break(_init(Pd1A._continue(s1), Pd2A._continue(s2))),
                ._continue => switch (a2.tag) {
                    ._break => Type.Action._break(_init(Pd1A._continue(s1), Pd2A._continue(s2))),
                    ._continue => Type.Action._continue(_init(n1(s1), n2(s2))),
                    ._yield => Type.Action._continue(_init(n1(s1), a2)),
                },
                ._yield => |v| switch (a2.tag) {
                    ._break => Type.Action._break(_init(Pd1A._continue(s1), Pd2A._continue(s2))),
                    ._continue => Type.Action._continue(_init(a1, n2(s2))),
                    ._yield => |w| Type.Action._yield(_init(Pd1A._continue(s1), Pd2A._continue(s2)), .{ v, w }),
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
