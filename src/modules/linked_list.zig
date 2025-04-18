const std = @import("std");
const NodeMod = @import("node.zig");

pub fn doubly_linked_list(comptime K: type, comptime V: type) type {
    const Node = NodeMod.Node(K, V);

    return struct {
        allocator: *std.mem.Allocator,
        head: ?*Node = null,
        tail: ?*Node = null,
        size: usize = 0,

        pub fn init(allocator: *std.mem.Allocator) doubly_linked_list(K, V) {
            return doubly_linked_list(K, V){
                .allocator = allocator,
                .head = null,
                .tail = null,
                .size = 0,
            };
        }

        const Self = @This();
    };
}

pub fn is_empty(comptime K: type, comptime V: type, self: *doubly_linked_list(K, V)) bool {
    return self.size == 0;
}

pub fn append(comptime K: type, comptime V: type, self: *doubly_linked_list(K, V), node: *NodeMod.Node(K, V)) void {
    node.prev = null;
    node.next = self.head;

    if (self.head) |h| {
        h.prev = node;
    } else {
        self.tail = node;
    }

    self.head = node;
    self.size += 1;
}

pub fn remove(comptime K: type, comptime V: type, self: *doubly_linked_list(K, V), node: *NodeMod.Node(K, V)) void {
    if (node.prev) |p| {
        p.next = node.next;
    } else {
        self.head = node.next;
    }

    if (node.next) |n| {
        n.prev = node.prev;
    } else {
        self.tail = node.prev;
    }

    node.prev = null;
    node.next = null;
    self.size -= 1;
}

pub fn popTail(comptime K: type, comptime V: type, self: *doubly_linked_list(K, V)) ?*NodeMod.Node(K, V) {
    if (self.tail) |t| {
        remove(K, V, self, t);
        return t;
    }
    return null;
}
