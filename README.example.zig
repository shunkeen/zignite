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

test "Example Code 2" {
    const lazy = zignite
        .range(usize, 1, 10) // { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
        .filter(even); //     { 2, 4, 6, 8, 10 }

    try std.testing.expect(lazy.sum() == 30);
    try std.testing.expect(lazy.product() == 3840);
}
