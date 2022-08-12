const std = @import("std");

test "reference all declarations" {
    std.testing.refAllDecls(@This());
}

const _FromSlice = @import("./producer/from_slice.zig").FromSlice;
const _Empty = @import("./producer/empty.zig").Empty;
const _Once = @import("./producer/once.zig").Once;
const _Range = @import("./producer/range.zig").Range;
const _Repeat = @import("./producer/repeat.zig").Repeat;
const _RevSlice = @import("./producer/rev_slice.zig").RevSlice;

const _Fuse = @import("./producer/fuse.zig").Fuse;
const _Enumerate = @import("./prosumer/enumerate.zig").Enumerate;
const _Filter = @import("./prosumer/filter.zig").Filter;
const _FlatMap = @import("./prosumer/flat_map.zig").FlatMap;
const _Take = @import("./prosumer/take.zig").Take;

const _Bomb = @import("./hermit/bomb.zig").Bomb;
const _Fold = @import("./consumer/fold.zig").Fold;
const _IsEmpty = @import("./consumer/is_empty.zig").IsEmpty;
const _Sum = @import("./consumer/sum.zig").Sum;
const _ToSlice = @import("./consumer/to_slice.zig").ToSlice;

pub fn Empty(comptime T: type) type {
    return Zignite(_Empty(T));
}

pub inline fn empty(comptime T: type) Empty(T) {
    return .{ .producer = _Empty(T).init };
}

pub fn FromSlice(comptime T: type) type {
    return Zignite(_FromSlice(T));
}

pub inline fn fromSlice(comptime T: type, slice: []const T) FromSlice(T) {
    return .{ .producer = _FromSlice(T).init(slice) };
}

pub fn Once(comptime T: type) type {
    return Zignite(_Once(T));
}

pub inline fn once(comptime T: type, value: T) Once(T) {
    return .{ .producer = _Once(T).init(value) };
}

pub fn Range(comptime T: type) type {
    return Zignite(_Range(T));
}

pub inline fn range(comptime T: type, start: T, count: usize) Range(T) {
    return .{ .producer = _Range(T).init(start, count) };
}

pub fn Repeat(comptime T: type) type {
    return Zignite(_Repeat(T));
}

pub inline fn repeat(comptime T: type, value: T) Repeat(T) {
    return .{ .producer = _Repeat(T).init(value) };
}

pub fn RevSlice(comptime T: type) type {
    return Zignite(_RevSlice(T));
}

pub inline fn revSlice(comptime T: type, slice: []const T) RevSlice(T) {
    return .{ .producer = _RevSlice(T).init(slice) };
}

pub fn Zignite(comptime Producer: type) type {
    return struct {
        producer: Producer,

        const Self = @This();
        pub const Producer = Producer;
        pub const Type = Producer.Type;
        pub const State = Producer.Type.State;
        pub const Out = Producer.Type.Out;
        const next = Producer.next;
        const deinit = Producer.deinit;

        const Predicate = fn (value: Out) bool;

        fn Transformer(comptime T: type) type {
            return fn (value: Out) T;
        }

        fn Reducer(comptime T: type) type {
            return fn (accumulator: T, value: Out) T;
        }

        pub fn Fuse(comptime T: type) type {
            return Zignite(_Fuse(State, Out, next, deinit, T.Type.State, T.Type.Out, T.next, T.deinit));
        }

        pub inline fn fuse(self: Self, prosumer: anytype) Fuse(@TypeOf(prosumer)) {
            return .{ .producer = Fuse(@TypeOf(prosumer)).Producer.init(self.producer, prosumer) };
        }

        pub fn Enumerate() type {
            return Fuse(_Enumerate(Out));
        }

        pub inline fn enumerate(self: Self) Enumerate() {
            return self.fuse(_Enumerate(Out).init);
        }

        pub fn Filter(comptime predicate: Predicate) type {
            return Fuse(_Filter(Out, predicate));
        }

        pub inline fn filter(self: Self, comptime predicate: Predicate) Filter(predicate) {
            return self.fuse(_Filter(Out, predicate).init);
        }

        pub fn FlatMap(comptime T: type, comptime transformer: Transformer(T)) type {
            return Fuse(RawFlatMap(T, transformer));
        }

        fn RawFlatMap(comptime T: type, comptime transformer: Transformer(T)) type {
            return _FlatMap(Out, T.Producer.Type.State, T.Producer.Type.Out, T.Producer.next, T.Producer.deinit, struct {
                fn run(value: Out) T.Producer {
                    return @call(.{ .modifier = .always_inline }, transformer, .{value}).producer;
                }
            }.run);
        }

        pub inline fn flatMap(self: Self, comptime T: type, comptime transformer: Transformer(T)) FlatMap(T, transformer) {
            return self.fuse(RawFlatMap(T, transformer).init);
        }

        pub fn Take() type {
            return Fuse(_Take(Out));
        }

        pub inline fn take(self: Self, take_count: usize) Take() {
            return self.fuse(_Take(Out).init(take_count));
        }

        pub inline fn bomb(self: Self, consumer: anytype) @TypeOf(consumer).Type.Out {
            const Cs = @TypeOf(consumer);
            const Hm = _Bomb(State, Out, next, deinit, Cs.Type.State, Cs.Type.Out, Cs.next, Cs.deinit);
            return Hm.run(self.producer, consumer);
        }

        pub inline fn fold(self: Self, comptime T: type, init: T, comptime reducer: Reducer(T)) T {
            return self.bomb(_Fold(T, Out, reducer).init(init));
        }

        pub inline fn isEmpty(self: Self) bool {
            return self.bomb(_IsEmpty(Out).init);
        }

        pub inline fn sum(self: Self) Out {
            return self.bomb(_Sum(Out).init);
        }

        pub inline fn toSlice(self: Self, buffer: []Out) ?[]const Out {
            return self.bomb(_ToSlice(Out).init(buffer));
        }
    };
}
