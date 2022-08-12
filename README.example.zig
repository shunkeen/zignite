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
