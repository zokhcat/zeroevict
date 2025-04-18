const std = @import("std");

pub fn Node(comptime K: type, comptime V: type) type {
    return struct {
        key: K,
        value: V,
        freq: usize,
        prev: ?*Node(K, V),
        next: ?*Node(K, V),
    };
}

pub fn init_node(comptime K: type, comptime V: type, key: K, value: V) Node(K, V) {
    return Node(K, V){
        .key = key,
        .value = value,
        .freq = 1,
        .prev = null,
        .next = null,
    };
}

test "test Node links" {
    const n = init_node(u32, u32, 42, 99);

    try std.testing.expectEqual(42, n.key);
    try std.testing.expectEqual(99, n.value);
    try std.testing.expectEqual(1, n.freq);
    try std.testing.expect(n.prev == null);
    try std.testing.expect(n.next == null);
}
