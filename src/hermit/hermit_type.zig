pub fn HermitType(comptime S: type, comptime T: type) type {
    return struct {
        pub const State = S;
        pub const Out = T;

        pub const Event = State;

        pub const ActionTag = enum {
            _return,
            _continue,
        };
        pub const Action = struct {
            state: State,
            tag: union(ActionTag) {
                _return: Out,
                _continue: void,
            },

            pub inline fn _return(state: State, out: Out) Action {
                return .{ .state = state, .tag = .{ ._return = out } };
            }

            pub inline fn _continue(state: State) Action {
                return .{ .state = state, .tag = .{ ._continue = {} } };
            }
        };

        pub const Next = fn (event: Event) Action;

        pub const Deinit = fn (state: State) void;

        pub fn nop(_: State) void {}

        pub inline fn run(state: State, comptime next: Next, comptime deinit: Deinit) Out {
            var a = Action._continue(state);
            defer deinit(a.state);

            const a_i = .{ .modifier = .always_inline };
            while (true) {
                switch (a.tag) {
                    ._return => |x| return x,
                    ._continue => a = @call(a_i, next, .{a.state}),
                }
            }
        }
    };
}
