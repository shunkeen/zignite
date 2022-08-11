pub fn ProducerType(comptime S: type, comptime T: type) type {
    return struct {
        pub const State = S;
        pub const Out = T;

        pub const Event = State;

        pub const ActionTag = enum {
            _break,
            _continue,
            _yield,
        };
        pub const Action = struct {
            state: State,
            tag: union(ActionTag) {
                _break: void,
                _continue: void,
                _yield: Out,
            },

            pub inline fn _break(state: State) Action {
                return .{ .state = state, .tag = .{ ._break = {} } };
            }

            pub inline fn _continue(state: State) Action {
                return .{ .state = state, .tag = .{ ._continue = {} } };
            }

            pub inline fn _yield(state: State, out: Out) Action {
                return .{ .state = state, .tag = .{ ._yield = out } };
            }
        };

        pub const Next = fn (event: Event) Action;

        pub const Deinit = fn (state: State) void;

        pub fn nop(_: State) void {}
    };
}
