pub fn ProsumerType(comptime S: type, comptime T: type, comptime U: type) type {
    return struct {
        pub const In = S;
        pub const State = T;
        pub const Out = U;

        pub const EventTag = enum {
            _break,
            _continue,
            _yield,
        };
        pub const Event = struct {
            state: State,
            tag: union(EventTag) {
                _break: void,
                _continue: void,
                _yield: In,
            },

            pub inline fn _break(state: State) Event {
                return .{ .state = state, .tag = .{ ._break = {} } };
            }

            pub inline fn _continue(state: State) Event {
                return .{ .state = state, .tag = .{ ._continue = {} } };
            }

            pub inline fn _yield(in: In, state: State) Event {
                return .{ .state = state, .tag = .{ ._yield = in } };
            }
        };

        pub const ActionTag = enum {
            _break,
            _continue,
            _await,
            _yield,
        };
        pub const Action = struct {
            state: State,
            tag: union(ActionTag) {
                _break: void,
                _continue: void,
                _await: void,
                _yield: Out,
            },

            pub inline fn _break(state: State) Action {
                return .{ .state = state, .tag = .{ ._break = {} } };
            }

            pub inline fn _continue(state: State) Action {
                return .{ .state = state, .tag = .{ ._continue = {} } };
            }

            pub inline fn _await(state: State) Action {
                return .{ .state = state, .tag = .{ ._await = {} } };
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
