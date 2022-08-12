const zignite = @import("../zignite.zig");
const expect = @import("std").testing.expect;
const ProducerType = @import("../producer/producer_type.zig").ProducerType;
const FlatMap = @import("flat_map.zig").FlatMap;

test "flatten:" {
    const R = zignite.Range(i32);
    const r0 = zignite.range(i32, 1, 0);
    const r1 = zignite.range(i32, 1, 1);
    const r2 = zignite.range(i32, 1, 2);

    var buffer1: [10]i32 = undefined;
    const b1 = zignite.fromSlice(R, &[_]R{ r0, r1, r2 }).flatten().toSlice(&buffer1).?;
    try expect(b1[0] == 1);
    try expect(b1[1] == 1);
    try expect(b1[2] == 2);
    try expect(b1.len == 3);

    try expect(zignite.fromSlice(R, &[_]R{ r0, r0, r0 }).flatten().isEmpty());
    try expect(zignite.fromSlice(R, &[_]R{}).flatten().isEmpty());
}

pub fn Flatten(comptime S: type, comptime T: type, comptime pd_next: ProducerType(S, T).Next, comptime pd_deinit: ProducerType(S, T).Deinit) type {
    return struct {
        const F = FlatMap(S, S, T, pd_next, pd_deinit, id);
        fn id(value: S) S {
            return value;
        }
    }.F;
}
