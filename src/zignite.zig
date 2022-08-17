const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoArrayHashMap = std.AutoArrayHashMap;
const AutoHashMap = std.AutoHashMap;
const BoundedArray = std.BoundedArray;
const BufMap = std.BufMap;
const MultiArrayList = std.MultiArrayList;
const Order = std.math.Order;

test "reference all declarations" {
    std.testing.refAllDecls(@This());
}

const _Chain = @import("./producer/chain.zig").Chain;
const _ConstIterator = @import("./producer/const_iterator.zig").ConstIterator;
const _Cycle = @import("./producer/cycle.zig").Cycle;
const _Empty = @import("./producer/empty.zig").Empty;
const _FromArrayList = @import("./producer/from_array_list.zig").FromArrayList;
const _FromAutoArrayHashMap = @import("./producer/from_auto_array_hash_map.zig").FromAutoArrayHashMap;
const _FromAutoHashMap = @import("./producer/from_auto_hash_map.zig").FromAutoHashMap;
const _FromBoundedArray = @import("./producer/from_bounded_array.zig").FromBoundedArray;
const _FromBufMap = @import("./producer/from_buf_map.zig").FromBufMap;
const _FromMultiArrayList = @import("./producer/from_multi_array_list.zig").FromMultiArrayList;
const _FromSlice = @import("./producer/from_slice.zig").FromSlice;
const _Once = @import("./producer/once.zig").Once;
const _Range = @import("./producer/range.zig").Range;
const _Repeat = @import("./producer/repeat.zig").Repeat;
const _RevArrayList = @import("./producer/rev_array_list.zig").RevArrayList;
const _RevBoundedArray = @import("./producer/rev_bounded_array.zig").RevBoundedArray;
const _RevMultiArrayList = @import("./producer/rev_multi_array_list.zig").RevMultiArrayList;
const _RevSlice = @import("./producer/rev_slice.zig").RevSlice;
const _Zip = @import("./producer/zip.zig").Zip;

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
const _SkipWhile = @import("./prosumer/skip_while.zig").SkipWhile;
const _Take = @import("./prosumer/take.zig").Take;
const _TakeWhile = @import("./prosumer/take_while.zig").TakeWhile;

const _Bomb = @import("./hermit/bomb.zig").Bomb;
const _AddBoundedArray = @import("./consumer/add_bounded_array.zig").AddBoundedArray;
const _All = @import("./consumer/all.zig").All;
const _Any = @import("./consumer/any.zig").Any;
const _AppendArrayList = @import("./consumer/append_array_list.zig").AppendArrayList;
const _AppendMultiArrayList = @import("./consumer/append_multi_array_list.zig").AppendMultiArrayList;
const _Count = @import("./consumer/count.zig").Count;
const _Find = @import("./consumer/find.zig").Find;
const _FindMap = @import("./consumer/find_map.zig").FindMap;
const _Fold = @import("./consumer/fold.zig").Fold;
const _ForEach = @import("./consumer/for_each.zig").ForEach;
const _IsEmpty = @import("./consumer/is_empty.zig").IsEmpty;
const _Last = @import("./consumer/last.zig").Last;
const _Max = @import("./consumer/max.zig").Max;
const _MaxBy = @import("./consumer/max_by.zig").MaxBy;
const _MaxByKey = @import("./consumer/max_by_key.zig").MaxByKey;
const _Min = @import("./consumer/min.zig").Min;
const _MinBy = @import("./consumer/min_by.zig").MinBy;
const _MinByKey = @import("./consumer/min_by_key.zig").MinByKey;
const _Nth = @import("./consumer/nth.zig").Nth;
const _PartitionSlice = @import("./consumer/partition_slice.zig").PartitionSlice;
const _Position = @import("./consumer/position.zig").Position;
const _Product = @import("./consumer/product.zig").Product;
const _PutAutoArrayHashMap = @import("./consumer/put_auto_array_hash_map.zig").PutAutoArrayHashMap;
const _PutAutoHashMap = @import("./consumer/put_auto_hash_map.zig").PutAutoHashMap;
const _PutBufMap = @import("./consumer/put_buf_map.zig").PutBufMap;
const _Reduce = @import("./consumer/reduce.zig").Reduce;
const _Sum = @import("./consumer/sum.zig").Sum;
const _ToSlice = @import("./consumer/to_slice.zig").ToSlice;
const _UnzipSlice = @import("./consumer/unzip_slice.zig").UnzipSlice;

pub fn Empty(comptime T: type) type {
    return Zignite(_Empty(T));
}

pub inline fn empty(comptime T: type) Empty(T) {
    return .{ .producer = _Empty(T).init };
}

pub fn FromArrayList(comptime T: type) type {
    return Zignite(_FromArrayList(T));
}

pub inline fn fromArrayList(comptime T: type, list: *const ArrayList(T)) FromArrayList(T) {
    return .{ .producer = _FromArrayList(T).init(list) };
}

pub fn FromAutoArrayHashMap(comptime S: type, comptime T: type) type {
    return Zignite(_FromAutoArrayHashMap(S, T));
}

pub inline fn fromAutoArrayHashMap(comptime S: type, comptime T: type, hash_map: *const AutoArrayHashMap(S, T)) FromAutoArrayHashMap(S, T) {
    return .{ .producer = _FromAutoArrayHashMap(S, T).init(hash_map) };
}

pub fn FromAutoHashMap(comptime S: type, comptime T: type) type {
    return Zignite(_FromAutoHashMap(S, T));
}

pub inline fn fromAutoHashMap(comptime S: type, comptime T: type, hash_map: *const AutoHashMap(S, T)) FromAutoHashMap(S, T) {
    return .{ .producer = _FromAutoHashMap(S, T).init(hash_map) };
}

pub fn FromBoundedArray(comptime T: type, comptime capacity: usize) type {
    return Zignite(_FromBoundedArray(T, capacity));
}

pub inline fn fromBoundedArray(comptime T: type, comptime capacity: usize, list: *const BoundedArray(T, capacity)) FromBoundedArray(T, capacity) {
    return .{ .producer = _FromBoundedArray(T, capacity).init(list) };
}

pub const FromBufMap = Zignite(_FromBufMap);

pub inline fn fromBufMap(buf_map: *const BufMap) FromBufMap {
    return .{ .producer = _FromBufMap.init(buf_map) };
}

pub fn FromMultiArrayList(comptime T: type) type {
    return Zignite(_FromMultiArrayList(T));
}

pub inline fn fromMultiArrayList(comptime T: type, list: *const MultiArrayList(T)) FromMultiArrayList(T) {
    return .{ .producer = _FromMultiArrayList(T).init(list) };
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

pub fn RevArrayList(comptime T: type) type {
    return Zignite(_RevArrayList(T));
}

pub inline fn revArrayList(comptime T: type, list: *const ArrayList(T)) RevArrayList(T) {
    return .{ .producer = _RevArrayList(T).init(list) };
}

pub fn RevBoundedArray(comptime T: type, comptime capacity: usize) type {
    return Zignite(_RevBoundedArray(T, capacity));
}

pub inline fn revBoundedArray(comptime T: type, comptime capacity: usize, list: *const BoundedArray(T, capacity)) RevBoundedArray(T, capacity) {
    return .{ .producer = _RevBoundedArray(T, capacity).init(list) };
}

pub fn RevMultiArrayList(comptime T: type) type {
    return Zignite(_RevMultiArrayList(T));
}

pub inline fn revMultiArrayList(comptime T: type, list: *const MultiArrayList(T)) RevMultiArrayList(T) {
    return .{ .producer = _RevMultiArrayList(T).init(list) };
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
        const Cmparator = fn (x: Out, y: Out) Order;

        fn Transformer(comptime T: type) type {
            return fn (value: Out) T;
        }

        fn Reducer(comptime T: type) type {
            return fn (accumulator: T, value: Out) T;
        }

        pub fn Chain(T: anytype) type {
            return Zignite(_Chain(State, Out, next, deinit, T.Producer.Type.State, T.Producer.next, T.Producer.deinit));
        }

        pub inline fn chain(self: Self, other: anytype) Chain(@TypeOf(other)) {
            return .{ .producer = Chain(@TypeOf(other)).Producer.init(self.producer, other.producer) };
        }

        pub fn ConstIterator() type {
            return *_ConstIterator(State, Out, next, deinit);
        }

        pub inline fn constIterator(self: Self) ConstIterator() {
            return &_ConstIterator(State, Out, next, deinit).init(self.producer);
        }

        pub fn Cycle() type {
            return Zignite(_Cycle(State, Out, next, deinit));
        }

        pub inline fn cycle(self: Self) Cycle() {
            return .{ .producer = Cycle().Producer.init(self.producer) };
        }

        pub fn Zip(T: anytype) type {
            return Zignite(_Zip(State, Out, next, deinit, T.Producer.Type.State, T.Producer.Type.Out, T.Producer.next, T.Producer.deinit));
        }

        pub inline fn zip(self: Self, other: anytype) Zip(@TypeOf(other)) {
            return .{ .producer = Zip(@TypeOf(other)).Producer.init(self.producer, other.producer) };
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

        pub fn SkipWhile(comptime predicate: Predicate) type {
            return Fuse(_SkipWhile(Out, predicate));
        }

        pub inline fn skipWhile(self: Self, comptime predicate: Predicate) SkipWhile(predicate) {
            return self.fuse(_SkipWhile(Out, predicate).init);
        }

        pub fn Take() type {
            return Fuse(_Take(Out));
        }

        pub inline fn take(self: Self, take_count: usize) Take() {
            return self.fuse(_Take(Out).init(take_count));
        }

        pub fn TakeWhile(comptime predicate: Predicate) type {
            return Fuse(_TakeWhile(Out, predicate));
        }

        pub inline fn takeWhile(self: Self, comptime predicate: Predicate) TakeWhile(predicate) {
            return self.fuse(_TakeWhile(Out, predicate).init);
        }

        pub inline fn bomb(self: Self, consumer: anytype) @TypeOf(consumer).Type.Out {
            const Cs = @TypeOf(consumer);
            const Hm = _Bomb(State, Out, next, deinit, Cs.Type.State, Cs.Type.Out, Cs.next, Cs.deinit);
            return Hm.run(self.producer, consumer);
        }

        pub inline fn toBoundedArray(self: Self, comptime capacity: usize) error{Overflow}!BoundedArray(Out, capacity) {
            var list = try BoundedArray(Out, capacity).init(0);
            try self.bomb(_AddBoundedArray(Out, capacity).init(&list));
            return list;
        }

        pub inline fn all(self: Self, comptime predicate: Predicate) bool {
            return self.bomb(_All(Out, predicate).init);
        }

        pub inline fn any(self: Self, comptime predicate: Predicate) bool {
            return self.bomb(_Any(Out, predicate).init);
        }

        pub inline fn count(self: Self) usize {
            return self.bomb(_Count(Out).init);
        }

        pub inline fn find(self: Self, comptime predicate: Predicate) ?Out {
            return self.bomb(_Find(Out, predicate).init);
        }

        pub inline fn findMap(self: Self, comptime T: type, comptime transformer: Transformer(?T)) ?T {
            return self.bomb(_FindMap(Out, T, transformer).init);
        }

        pub inline fn fold(self: Self, comptime T: type, init: T, comptime reducer: Reducer(T)) T {
            return self.bomb(_Fold(T, Out, reducer).init(init));
        }

        pub inline fn forEach(self: Self, comptime transformer: Transformer(void)) void {
            return self.bomb(_ForEach(Out, transformer).init);
        }

        pub inline fn isEmpty(self: Self) bool {
            return self.bomb(_IsEmpty(Out).init);
        }

        pub inline fn last(self: Self) ?Out {
            return self.bomb(_Last(Out).init);
        }

        pub inline fn max(self: Self) ?Out {
            return self.bomb(_Max(Out).init);
        }

        pub inline fn maxBy(self: Self, comptime comparator: Cmparator) ?Out {
            return self.bomb(_MaxBy(Out, comparator).init);
        }

        pub inline fn maxByKey(self: Self, comptime T: type, comptime transformer: Transformer(T)) ?Out {
            return self.bomb(_MaxByKey(Out, T, transformer).init);
        }

        pub inline fn min(self: Self) ?Out {
            return self.bomb(_Min(Out).init);
        }

        pub inline fn minBy(self: Self, comptime comparator: Cmparator) ?Out {
            return self.bomb(_MinBy(Out, comparator).init);
        }

        pub inline fn minByKey(self: Self, comptime T: type, comptime transformer: Transformer(T)) ?Out {
            return self.bomb(_MinByKey(Out, T, transformer).init);
        }

        pub inline fn nth(self: Self, nth_count: usize) ?Out {
            return self.bomb(_Nth(Out).init(nth_count));
        }

        pub inline fn partitionSlice(self: Self, comptime predicate: Predicate, true_buffer: []Out, flase_buffer: []Out) _PartitionSlice(Out, predicate).Type.Out {
            return self.bomb(_PartitionSlice(Out, predicate).init(true_buffer, flase_buffer));
        }

        pub inline fn position(self: Self, comptime predicate: Predicate) ?usize {
            return self.bomb(_Position(Out, predicate).init);
        }

        pub inline fn product(self: Self) Out {
            return self.bomb(_Product(Out).init);
        }

        pub inline fn reduce(self: Self, comptime reducer: Reducer(Out)) ?Out {
            return self.bomb(_Reduce(Out, reducer).init);
        }

        pub inline fn sum(self: Self) Out {
            return self.bomb(_Sum(Out).init);
        }

        pub inline fn toArrayList(self: Self, allocator: Allocator) Allocator.Error!ArrayList(Out) {
            var list = ArrayList(Out).init(allocator);
            errdefer list.deinit();
            try self.bomb(_AppendArrayList(Out).init(&list));
            return list;
        }

        pub inline fn toAutoArrayHashMap(self: Self, comptime T: type, comptime U: type, allocator: Allocator) Allocator.Error!AutoArrayHashMap(T, U) {
            var hash_map = AutoArrayHashMap(T, U).init(allocator);
            errdefer hash_map.deinit();
            try self.bomb(_PutAutoArrayHashMap(Out, T, U).init(&hash_map));
            return hash_map;
        }

        pub inline fn toAutoHashMap(self: Self, comptime T: type, comptime U: type, allocator: Allocator) Allocator.Error!AutoHashMap(T, U) {
            var hash_map = AutoHashMap(T, U).init(allocator);
            errdefer hash_map.deinit();
            if (self.bomb(_PutAutoHashMap(Out, T, U).init(&hash_map))) |_| {
                return hash_map;
            } else |err| {
                hash_map.deinit();
                return err;
            }
        }

        pub inline fn toBufMap(self: Self, allocator: Allocator) Allocator.Error!BufMap {
            var buf_map = BufMap.init(allocator);
            errdefer buf_map.deinit();
            try self.bomb(_PutBufMap(Out).init(&buf_map));
            return buf_map;
        }

        pub inline fn toMultiArrayList(self: Self, allocator: Allocator) Allocator.Error!MultiArrayList(Out) {
            var list = MultiArrayList(Out){};
            errdefer list.deinit(allocator);
            try self.bomb(_AppendMultiArrayList(Out).init(&list, allocator));
            return list;
        }

        pub inline fn toSlice(self: Self, buffer: []Out) ?[]const Out {
            return self.bomb(_ToSlice(Out).init(buffer));
        }

        pub inline fn unzipSlice(self: Self, comptime T: type, buffer0: []T, comptime U: type, buffer1: []U) _UnzipSlice(Out, T, U).Type.Out {
            return self.bomb(_UnzipSlice(Out, T, U).init(buffer0, buffer1));
        }
    };
}
