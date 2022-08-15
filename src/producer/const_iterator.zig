const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;

test "constIterator:" {
    {
        const it = zignite.range(i32, 0, 3).constIterator();
        defer it.deinit();
        try expect(it.next().?.* == 0);
        try expect(it.next().?.* == 1);
        try expect(it.next().?.* == 2);
        try expect(it.next() == null);
    }

    {
        const it = zignite.range(i32, 0, 3).constIterator();
        defer it.deinit();

        var x: i32 = 0;
        while (it.next()) |item| : (x += 1) {
            try expect(item.* == x);
        }
    }

    {
        const it = zignite.empty(i32).constIterator();
        defer it.deinit();
        try expect(it.next() == null);
    }
}

pub fn ConstIterator(comptime S: type, comptime T: type, comptime pd_next: ProducerType(S, T).Next, comptime pd_deinit: ProducerType(S, T).Deinit) type {
    return struct {
        action: Pd.Action,

        const Pd = ProducerType(S, T);
        const Self = @This();

        pub inline fn init(state: Pd.State) Self {
            return .{ .action = Pd.Action._continue(state) };
        }

        pub inline fn next(self: *Self) ?(*const T) {
            const a_i = .{ .modifier = .always_inline };

            var a = self.action;
            while (true) {
                switch (a.tag) {
                    ._break => return null,
                    ._continue => a = @call(a_i, pd_next, .{a.state}),
                    ._yield => |v| {
                        self.action = Pd.Action._continue(a.state);
                        return &v;
                    },
                }
            }
        }

        pub fn deinit(self: *Self) void {
            defer pd_deinit(self.action.state);
        }
    };
}
