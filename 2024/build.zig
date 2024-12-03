const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    for (0..3) |day| {
        const name = b.fmt("day{d:0>2}", .{day + 1});
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(b.fmt("src/{s}.zig", .{name})),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step(b.fmt("{s}", .{name}), b.fmt("Run {s}", .{name}));
        run_step.dependOn(&run_cmd.step);
    }
}
