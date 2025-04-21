const std = @import("std");
const LFUCacheMod = @import("lfu.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("LFU Cache in O(1) \n", .{});
    const cache = LFUCacheMod.LFUCache([]const u8, []const u8);
    var _lfu_cache = try cache.init(&allocator, 10);

    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdout.print("Usage: <put> key value\n <get> key value", .{});
    }

    const command = args[1];
    if (std.mem.eql(u8, command, "get")) {
        if (args.len != 3) {
            try stdout.print("Usage: get <key>\n", .{});
        }

        const key = args[2];

        const value = _lfu_cache.get(key) catch {
            try stdout.print("Key {s} not found\n", .{key});
            return;
        };
        if (std.mem.eql(u8, "", value)) {
            try stdout.print("Key {s} not found\n", .{key});
        } else {
            try stdout.print("Value for key {s}: {s}\n", .{ key, value });
        }
    } else if (std.mem.eql(u8, command, "put")) {
        if (args.len != 4) {
            try stdout.print("Usage: put <key> <value>\n", .{});
            return;
        }
        const key = args[2];
        const value = args[3];
        _lfu_cache.put(key, value) catch |err| {
            try stdout.print("Error: {}\n", .{err});
            return;
        };
        try stdout.print("Inserted key {s} with value {s}\n", .{ key, value });
    } else {
        try stdout.print("Unknown command: {s}\n", .{command});
        try stdout.print("Available commands: get, put\n", .{});
    }
}
