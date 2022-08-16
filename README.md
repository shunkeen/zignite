# zignite
A lazy stream (iterator) library for Zig.

## Example Code

* The following code does **not** generate an intermediate collection.
* The following code compiles to a single While statement.
* However, removing the `sum` method only produces the initial state of the iterator, not a While statement.

```README.example.zig
const zignite = @import("src/zignite.zig");
const std = @import("std");

fn even(x: usize) bool {
    return @mod(x, 2) == 0;
}

const RepeatTake = zignite.Repeat(usize).Take();
fn repeatTake(x: usize) RepeatTake {
    return zignite.repeat(usize, x).take(x);
}

test "Example Code" {
    const x = zignite
        .range(usize, 0, 100) //            { 0, 1, ..., 99 }
        .filter(even) //                    { 0, 2, ..., 98 }
        .flatMap(RepeatTake, repeatTake) // { 2, 2, 4, 4, 4, 4, ..., 98 }
        .sum();

    try std.testing.expect(x == 161700);
}
```

## Test code and implementation

### 🔥ignite
* [chain](./src/producer/chain.zig)
* [constIterator](./src/producer/const_iterator.zig)
* [cycle](./src/producer/cycle.zig)
* [empty](./src/producer/empty.zig)
* [fromArrayList](./src/producer/from_array_list.zig)
* [fromAutoArrayHashMap](./src/producer/from_auto_array_hash_map.zig)
* [fromMultiArrayList](./src/producer/from_multi_array_list.zig)
* [fromSlice](./src/producer/from_slice.zig)
* [once](./src/producer/once.zig)
* [range](./src/producer/range.zig)
* [repeat](./src/producer/repeat.zig)
* [revSlice](./src/producer/rev_slice.zig)
* [zip](./src/producer/zip.zig)

### 🧶fuse
* [enumerate](./src/prosumer/enumerate.zig)
* [filter](./src/prosumer/filter.zig)
* [filterMap](./src/prosumer/filter_map.zig)
* [flatMap](./src/prosumer/flat_map.zig)
* [flatten](./src/prosumer/flatten.zig)
* [inspect](./src/prosumer/inspect.zig)
* [map](./src/prosumer/map.zig)
* [mapWhile](./src/prosumer/map_while.zig)
* [scan](./src/prosumer/scan.zig)
* [skip](./src/prosumer/skip.zig)
* [skipWhile](./src/prosumer/skip_while.zig)
* [take](./src/prosumer/take.zig)
* [takeWhile](./src/prosumer/take_while.zig)

### 💥bomb
* [all](./src/consumer/all.zig)
* [any](./src/consumer/any.zig)
* [count](./src/consumer/count.zig)
* [find](./src/consumer/find.zig)
* [findMap](./src/consumer/find_map.zig)
* [fold](./src/consumer/fold.zig)
* [forEach](./src/consumer/for_each.zig)
* [isEmpty](./src/consumer/is_empty.zig)
* [last](./src/consumer/last.zig)
* [max](./src/consumer/max.zig)
* [maxBy](./src/consumer/max_by.zig)
* [maxByKey](./src/consumer/max_by_key.zig)
* [min](./src/consumer/min.zig)
* [minBy](./src/consumer/min_by.zig)
* [minByKey](./src/consumer/min_by_key.zig)
* [nth](./src/consumer/nth.zig)
* [partitionSlice](./src/consumer/partition_slice.zig)
* [position](./src/consumer/position.zig)
* [product](./src/consumer/product.zig)
* [reduce](./src/consumer/reduce.zig)
* [sum](./src/consumer/sum.zig)
* [toArrayList](./src/consumer/append_array_list.zig)
* [toAutoArrayHashMap](./src/consumer/put_auto_array_hash_map.zig)
* [toAutoHashMap](./src/consumer/put_auto_hash_map.zig)
* [toBufMap](./src/consumer/put_buf_map.zig)
* [toMultiArrayList](./src/consumer/append_multi_array_list.zig)
* [toSlice](./src/consumer/to_slice.zig)
* [unzipSlice](./src/consumer/unzip_slice.zig)
