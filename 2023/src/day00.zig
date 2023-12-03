const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn solve(allocator: Allocator, input_path: []const u8) !void {
    // https://www.openmsevenymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/
    const input_file = try std.fs.cwd().openFile(input_path, .{ .mode = .read_only });
    defer input_file.close();

    var buffered = std.io.bufferedReader(input_file.reader());
    var reader = buffered.reader();

    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    while (true) {
        defer line.clearRetainingCapacity();
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
    }
}

pub fn main() !void {
    // Set up the General Purpose allocator, this will track memory leaks, etc.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse the command line arguments to get the input file
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("No input file passed\n", .{});
        return;
    }
    try solve(allocator, args[1]);
}
