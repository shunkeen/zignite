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
const _FilterMap = @import("./prosumer/filter_map.zig").FilterMap;
const _FlatMap = @import("./prosumer/flat_map.zig").FlatMap;
const _Flatten = @import("./prosumer/flatten.zig").Flatten;
const _Inspect = @import("./prosumer/inspect.zig").Inspect;
const _Map = @import("./prosumer/map.zig").Map;
const _MapWhile = @import("./prosumer/map_while.zig").MapWhile;
const _Scan = @import("./prosumer/scan.zig").Scan;
const _Skip = @import("./prosumer/skip.zig").Skip;
const _Take = @import("./prosumer/take.zig").Take;

const _Bomb = @import("./hermit/bomb.zig").Bomb;
const _Fold = @import("./consumer/fold.zig").Fold;
const _IsEmpty = @import("./consumer/is_empty.zig").IsEmpty;
const _Product = @import("./consumer/product.zig").Product;
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

        pub fn FilterMap(comptime T: type, comptime transformer: Transformer(?T)) type {
            return Fuse(_FilterMap(Out, T, transformer));
        }

        pub inline fn filterMap(self: Self, comptime T: type, comptime transformer: Transformer(?T)) FilterMap(T, transformer) {
            return self.fuse(_FilterMap(Out, T, transformer).init);
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

        pub fn Flatten() type {
            return Fuse(RawFlatten());
        }

        fn RawFlatten() type {
            return RawFlatMap(Out, struct {
                fn run(value: Out) Out {
                    return value;
                }
            }.run);
        }

        pub inline fn flatten(self: Self) Flatten() {
            return self.fuse(RawFlatten().init);
        }

        pub fn Inspect(comptime transformer: Transformer(void)) type {
            return Fuse(_Inspect(Out, transformer));
        }

        pub inline fn inspect(self: Self, comptime transformer: Transformer(void)) Inspect(transformer) {
            return self.fuse(_Inspect(Out, transformer).init);
        }

        pub fn Map(comptime T: type, comptime transformer: Transformer(T)) type {
            return Fuse(_Map(Out, T, transformer));
        }

        pub inline fn map(self: Self, comptime T: type, comptime transformer: Transformer(T)) Map(T, transformer) {
            return self.fuse(_Map(Out, T, transformer).init);
        }

        pub fn MapWhile(comptime T: type, comptime transformer: Transformer(?T)) type {
            return Fuse(_MapWhile(Out, T, transformer));
        }

        pub inline fn mapWhile(self: Self, comptime T: type, comptime transformer: Transformer(?T)) MapWhile(T, transformer) {
            return self.fuse(_MapWhile(Out, T, transformer).init);
        }

        pub fn Scan(comptime T: type, comptime reducer: Reducer(T)) type {
            return Fuse(_Scan(Out, T, reducer));
        }

        pub inline fn scan(self: Self, comptime T: type, init: T, comptime reducer: Reducer(T)) Scan(T, reducer) {
            return self.fuse(_Scan(Out, T, reducer).init(init));
        }

        pub fn Skip() type {
            return Fuse(_Skip(Out));
        }

        pub inline fn skip(self: Self, skip_count: usize) Skip() {
            return self.fuse(_Skip(Out).init(skip_count));
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

        pub inline fn product(self: Self) Out {
            return self.bomb(_Product(Out).init);
        }

        pub inline fn sum(self: Self) Out {
            return self.bomb(_Sum(Out).init);
        }

        pub inline fn toSlice(self: Self, buffer: []Out) ?[]const Out {
            return self.bomb(_ToSlice(Out).init(buffer));
        }
    };
}
