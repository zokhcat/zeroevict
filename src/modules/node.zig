const std = @import("std");

pub fn Node(comptime K: type, comptime V: type) type {
    return struct {
        key: K,
        value: V,
        freq: usize,
        prev: ?*Node(K, V),
        next: ?*Node(K, V),

        pub fn init(key: K, value: V) Node(K, V) {
            return .{
                .key = key,
                .value = value,
                .freq = 1,
                .prev = null,
                .next = null,
            };
        }
    };
}
