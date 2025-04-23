const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addModule("zeroevict", .{
        .root_source_file = b.path("src/lfu.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "zeroevict",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("zeroevict", lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    b.step("run", "Run the LFU Cache").dependOn(&run_cmd.step);
}
