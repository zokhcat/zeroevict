const std = @import("std");

const NodeMod = @import("modules/node.zig");
const ListMod = @import("modules/linked_list.zig");

pub fn LFUCache(comptime K: type, comptime V: type) type {
    const Node = NodeMod.Node(K, V);
    const List = ListMod.doubly_linked_list(K, V);

    return struct {
        allocator: *std.mem.Allocator,
        capacity: usize,
        size: usize,
        min_freq: usize,

        key_node: std.AutoHashMap(K, *Node),
        freq_list: std.AutoHashMap(usize, *List),

        pub fn init(allocator: *std.mem.Allocator, capacity: usize) !LFUCache {
            return LFUCache{
                .allocator = allocator,
                .capacity = capacity,
                .size = 0,
                .min_freq = 0,
                .key_node = std.AutoHashMap(K, *Node).init(allocator),
                .freq_list = std.AutoHashMap(usize, *List),
            };
        }

        pub fn get(self: *Self, key: K) ?V {
            const node_ptr = self.key_node.get(key) orelse return null;
            self.increaseFreq(node_ptr);
            return node_ptr.value;
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            if (self.capacity == 0) return;

            if (self.key_node.get(key)) |node_ptr| {
                node_ptr.value = value;
                self.increaseFreq(node_ptr);
                return;
            }

            if (self.size >= self.capacity) {
                const list = self.freq_list.get(self.min_freq) orelse return;
                const to_evict = list.popTail() orelse return;
                _ = self.key_node.remove(to_evict.key);
                self.allocator.destroy(to_evict);

                self.size -= 1;
            }

            const node = try self.allocator.create(Node);
            node.* = node.init(key, value);
            self.key_node.putAssumeCapacity(key, node);

            var list = try self.getFreqList(1);
            list.append(node);

            self.min_freq = 1;
            self.size += 1;
        }

        fn increaseFreq(self: *Self, node_ptr: *Node) void {
            const old_freq = node_ptr.freq;
            const old_list = self.freq_list.get(old_freq) orelse return;

            old_list.remove(node_ptr);

            if (old_freq == self.min_freq and old_list.isEmpty()) {
                self.min_freq += 1;
            }

            node_ptr.freq += 1;
            const new_list = self.getFreqList(node_ptr.freq) catch return;
            new_list.append(node_ptr);
        }

        fn getFreqList(self: *Self, freq: usize) !*List {
            if (self.freq_list.get(freq)) |list| {
                return list;
            } else {
                const new_list = try self.allocator.create(List);
                new_list.* = List.init(self.allocator);
                try self.freq_list.put(freq, new_list);
                return new_list;
            }
        }

        const Self = @This();
    };
}
