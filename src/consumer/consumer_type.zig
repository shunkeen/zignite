pub fn ConsumerType(comptime S: type, comptime T: type, comptime U: type) type {
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
            _return,
            _continue,
            _await,
        };
        pub const Action = struct {
            state: State,
            tag: union(ActionTag) {
                _return: Out,
                _continue: void,
                _await: void,
            },

            pub inline fn _return(state: State, out: Out) Action {
                return .{ .state = state, .tag = .{ ._return = out } };
            }

            pub inline fn _continue(state: State) Action {
                return .{ .state = state, .tag = .{ ._continue = {} } };
            }

            pub inline fn _await(state: State) Action {
                return .{ .state = state, .tag = .{ ._await = {} } };
            }
        };

        pub const Next = fn (event: Event) Action;

        pub const Deinit = fn (state: State) void;

        pub fn nop(_: State) void {}
    };
}
