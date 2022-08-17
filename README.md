# zignite
A lazy stream (iterator) library for Zig.

## Example Code

* The following code does **not** generate an intermediate collection.
* The following code compiles to [a single loop](./src/hermit/hermit_type.zig#L31).
* However, removing the `sum` method only produces the initial state of the iterator, not a loop.

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

test "Example Code 1" {
    const x = zignite
        .range(usize, 0, 100) //            { 0, 1, ..., 99 }
        .filter(even) //                    { 0, 2, ..., 98 }
        .flatMap(RepeatTake, repeatTake) // { 2, 2, 4, 4, 4, 4, ..., 98 }
        .sum();

    try std.testing.expect(x == 161700);
}
```

* The `lazy` in the following code can be reused without resetting.
* However, in this case `lazy` is calculated twice.
* This is because no collection is created to store intermediate results.

```README.example.zig
test "Example Code 2" {
    const lazy = zignite
        .range(usize, 1, 10) // { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
        .filter(even); //     { 2, 4, 6, 8, 10 }

    try std.testing.expect(lazy.sum() == 30);
    try std.testing.expect(lazy.product() == 3840);
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
* [fromAutoHashMap](./src/producer/from_auto_hash_map.zig)
* [fromBoundedArray](./src/producer/from_bounded_array.zig)
* [fromBufMap](./src/producer/from_buf_map.zig)
* [fromMultiArrayList](./src/producer/from_multi_array_list.zig)
* [fromSlice](./src/producer/from_slice.zig)
* [once](./src/producer/once.zig)
* [range](./src/producer/range.zig)
* [repeat](./src/producer/repeat.zig)
* [revArrayList](./src/producer/rev_array_list.zig)
* [revBoundedArray](./src/producer/rev_bounded_array.zig)
* [revMultiArrayList](./src/producer/rev_multi_array_list.zig)
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
* [toBoundedArray](./src/consumer/add_bounded_array.zig)
* [toBufMap](./src/consumer/put_buf_map.zig)
* [toMultiArrayList](./src/consumer/append_multi_array_list.zig)
* [toSlice](./src/consumer/to_slice.zig)
* [unzipSlice](./src/consumer/unzip_slice.zig)
