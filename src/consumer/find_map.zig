const zignite = @import("../zignite.zig");
const std = @import("std");
const expect = std.testing.expect;
const ConsumerType = @import("consumer_type.zig").ConsumerType;

test "find_map: parseInt" {
    const parseInt = struct {
        pub fn parseInt(x: []const u8) ?i32 {
            return std.fmt.parseInt(i32, x, 10) catch null;
        }
    }.parseInt;

    const Str = []const u8;
    try expect(zignite.fromSlice(Str, &[_]Str{ "-two", "+three", "-4", "five" }).findMap(i32, parseInt).? == -4);
    try expect(zignite.fromSlice(Str, &[_]Str{ "-two", "+three", "five" }).findMap(i32, parseInt) == null);
    try expect(zignite.empty(Str).findMap(i32, parseInt) == null);
}

pub fn FindMap(comptime S: type, comptime T: type, comptime transformer: fn (value: S) ?T) type {
    return struct {
        pub const Type = ConsumerType(S, @This(), ?T);

        pub const init = Type.State{};

        pub fn next(event: Type.Event) Type.Action {
            return switch (event.tag) {
                ._break => Type.Action._return(init, null),
                ._continue => Type.Action._await(init),
                ._yield => |v| await_or_return(v),
            };
        }

        pub const deinit = Type.nop;

        inline fn await_or_return(value: S) Type.Action {
            const x = @call(.{ .modifier = .always_inline }, transformer, .{value});
            if (x == null) {
                return Type.Action._await(init);
            } else {
                return Type.Action._return(init, x.?);
            }
        }
    };
}
