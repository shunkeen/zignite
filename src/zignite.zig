const std = @import("std");

test "reference all declarations" {
    std.testing.refAllDecls(@This());
}
