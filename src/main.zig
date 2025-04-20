const std = @import("std");
const clap = @import("clap");
const LFUCacheMod = @import("lfu.zig");

const SubCommands = enum {
    help,
    cache,
};

const main_parser = .{
    .command = clap.parsers.enumeration(SubCommands),
};

const main_params = clap.parseParamsComptime(
    \\-h, --help Display this and exit
);

const MainArgs = clap.ResultEx(clap.Help, &main_params, main_parser);

const allocator = std.heap.page_allocator;
const lfu_cache = LFUCacheMod.LFUCache([]const u8, []const u8).init(&allocator, 3);

pub fn main() !void {
    std.debug.print("LFU Cache in O(1) \n", .{});

    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var iter = try std.process.ArgIterator.initWithAllocator(gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &main_params, main_parser, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        std.debug.print("--help\n", .{});

    const command = res.positionals[0] orelse return error.MissingCommand;
    switch (command) {
        .help => std.debug.print("--help\n", .{}),
        .cache => try cacheCmd(gpa, &iter, res, &lfu_cache),
    }
}

fn cacheCmd(gpa: std.mem.Allocator, iter: *std.process.ArgIterator, main_args: MainArgs, cache: *LFUCacheMod.LFUCache([]const u8, []const u8)) !void {
    _ = main_args;

    const params = comptime clap.parseParamsComptime(
        \\-p, --put  Put value inside the cache
        \\-g, --get  Get value inside the cache
        \\<[]const u8>
        \\<[]const u8>
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &params, clap.parsers.default, iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const key = res.positionals[0] orelse return error.MissingArg1;
    const value = res.positionals[1] orelse return error.MissingArg1;
    if (res.args.help != 0) {
        try std.debug.print("--help", .{});
    }

    if (res.args.put != 0) {
        try cache.put(key, value);
    }

    if (res.args.get != 0) {
        const val = try lfu_cache.get(key);
        std.debug.print("Got: {}\n", .{val});
    }
}
