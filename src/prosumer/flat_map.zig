const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;
const ProsumerType = @import("prosumer_type.zig").ProsumerType;

test "flat_map:" {
    const R = zignite.Range(i32);
    const range = struct {
        fn run(x: usize) R {
            return zignite.range(i32, 1, x);
        }
    }.run;

    var buffer1: [10]i32 = undefined;
    const b1 = zignite.fromSlice(usize, &[_]usize{ 0, 1, 2 }).flatMap(R, range).toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 1);
    try expect(b1[2] == 2);
    try expect(b1.len == 3);

    try expect(zignite.fromSlice(usize, &[_]usize{ 0, 0, 0 }).flatMap(R, range).isEmpty());
    try expect(zignite.fromSlice(usize, &[_]usize{}).flatMap(R, range).isEmpty());
}

pub fn FlatMap(comptime S: type, comptime T: type, comptime U: type, comptime pd_next: ProducerType(T, U).Next, comptime pd_deinit: ProducerType(T, U).Deinit, comptime transformer: fn (value: S) T) type {
    return struct {
        const Pd = ProducerType(T, U);

        action: ?Pd.Action,

        pub const Type = ProsumerType(S, @This(), U);

        pub const init = _init(null);

        pub fn next(event: Type.Event) Type.Action {
            const _c = Pd.Action._continue;
            if (event.state.action == null) {
                return switch (event.tag) {
                    ._break => Type.Action._break(init),
                    ._continue => Type.Action._await(init),
                    ._yield => |v| Type.Action._continue(_init(_c(t(v)))),
                };
            }

            const a = event.state.action.?;
            const s = a.state;
            switch (a.tag) {
                ._yield => |v| return Type.Action._yield(_init(_c(s)), v),
                ._continue => return Type.Action._continue(_init(pd_n(s))),
                ._break => {
                    defer pd_deinit(s);
                    return Type.Action._await(init);
                },
            }
        }

        pub const deinit = Type.nop;

        inline fn _init(action: ?Pd.Action) Type.State {
            return .{ .action = action };
        }

        inline fn pd_n(event: Pd.Event) Pd.Action {
            return @call(.{ .modifier = .always_inline }, pd_next, .{event});
        }

        inline fn t(value: S) T {
            return @call(.{ .modifier = .always_inline }, transformer, .{value});
        }
    };
}
