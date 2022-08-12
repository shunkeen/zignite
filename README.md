# zignite
zignite is a lazy stream library for Zig.

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
fn repeat_take(x: usize) RepeatTake {
    return zignite.repeat(usize, x).take(x);
}

test "Example Code" {
    const x = zignite
        .range(usize, 0, 100) //              { 0, 1, ..., 99 }
        .filter(even) //                      { 0, 2, ..., 98 }
        .flatMap(RepeatTake, repeat_take) // { 2, 2, 4, 4, 4, 4, ..., 98 }
        .sum();

    try std.testing.expect(x == 161700);
}
```

## Test code and implementation

### 🔥ignite
* [empty](./src/producer/empty.zig)
* [fromSlice](./src/producer/from_slice.zig)
* [once](./src/producer/once.zig)
* [range](./src/producer/range.zig)
* [repeat](./src/producer/repeat.zig)
* [revSlice](./src/producer/rev_slice.zig)

### 🧶fuse
* [enumerate](./src/prosumer/enumerate.zig)
* [filter](./src/prosumer/filter.zig)
* [filterMap](./src/prosumer/filter_map.zig)
* [flatMap](./src/prosumer/flat_map.zig)
* [take](./src/prosumer/take.zig)

### 💣bomb
* [fold](./src/consumer/fold.zig)
* [isEmpty](./src/consumer/is_empty.zig)
* [sum](./src/consumer/sum.zig)
* [toSlice](./src/consumer/to_slice.zig)
