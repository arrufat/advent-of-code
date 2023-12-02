const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Color = enum {
    red,
    green,
    blue,

    fn fromString(string: []const u8) ?Color {
        return for (std.meta.tags(Color)) |tag| {
            const name = @tagName(tag);
            if (name.len > string.len)
                continue;
            if (std.mem.eql(u8, name, string[0..name.len])) {
                break tag;
            }
        } else null;
    }
};

const Subset = struct {
    color: Color,
    amount: usize,
};

fn Game() type {
    return struct {
        const Self = @This();
        id: usize,
        subsets: ArrayList(Subset),

        pub fn init(allocator: Allocator) Self {
            return Self{ .id = 0, .subsets = ArrayList(Subset).init(allocator) };
        }
        pub fn deinit(self: *Self) void {
            self.subsets.deinit();
        }

        fn check(self: Self, subsets: []const Subset) bool {
            for (subsets) |subset| {
                for (self.subsets.items) |candidate| {
                    if (subset.color == candidate.color) {
                        if (candidate.amount > subset.amount) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }

        fn power(self: Self) usize {
            var max_red: usize = 0;
            var max_green: usize = 0;
            var max_blue: usize = 0;
            for (self.subsets.items) |item| {
                switch (item.color) {
                    .red => max_red = @max(max_red, item.amount),
                    .green => max_green = @max(max_green, item.amount),
                    .blue => max_blue = @max(max_blue, item.amount),
                }
            }
            return max_red * max_green * max_blue;
        }

        fn parseId(self: *Self, string: []const u8) !void {
            var parts = std.mem.split(u8, string, " ");
            _ = parts.first();
            self.id = try std.fmt.parseUnsigned(usize, parts.next().?, 10);
        }

        fn parseSubsets(self: *Self, string: []const u8) !void {
            var subgames = std.mem.tokenize(u8, string, ";");
            while (subgames.next()) |subgame| {
                var pairs = std.mem.tokenize(u8, subgame, ",");
                while (pairs.next()) |pair| {
                    var parts = std.mem.tokenize(u8, pair, " ");
                    try self.subsets.append(.{
                        .amount = try std.fmt.parseUnsigned(usize, parts.next().?, 10),
                        .color = Color.fromString(parts.next().?).?,
                    });
                }
            }
        }
    };
}

pub fn solve(allocator: std.mem.Allocator, input_path: []const u8) !void {
    // https://www.openmsevenymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/
    const input_file = try std.fs.cwd().openFile(input_path, .{ .mode = .read_only });
    defer input_file.close();

    var buffered = std.io.bufferedReader(input_file.reader());
    var reader = buffered.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    var part_one: usize = 0;
    var part_two: usize = 0;
    while (true) {
        defer line.clearRetainingCapacity();
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        var parts = std.mem.split(u8, line.items, ":");
        var game = Game().init(allocator);
        defer game.deinit();
        try game.parseId(parts.first());
        try game.parseSubsets(parts.next().?);
        const contents: []const Subset = &.{
            .{ .amount = 12, .color = Color.red },
            .{ .amount = 13, .color = Color.green },
            .{ .amount = 14, .color = Color.blue },
        };
        part_one += if (game.check(contents)) game.id else 0;
        part_two += game.power();
    }
    print("part_one: {}\n", .{part_one});
    print("part_two: {}\n", .{part_two});
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
