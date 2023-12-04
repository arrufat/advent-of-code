const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Set = std.AutoHashMap(usize, void);

const Scratchcard = struct {
    winners: usize,
    amount: usize = 1,
};

pub fn solve(allocator: Allocator, input_path: []const u8) !void {
    // https://www.openmsevenymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/
    const input_file = try std.fs.cwd().openFile(input_path, .{ .mode = .read_only });
    defer input_file.close();

    var buffered = std.io.bufferedReader(input_file.reader());
    var reader = buffered.reader();

    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    var part_one: usize = 0;
    var scratchcards = ArrayList(Scratchcard).init(allocator);
    defer scratchcards.deinit();
    while (true) {
        defer line.clearRetainingCapacity();
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        const colon_pos = for (line.items, 0..) |char, idx| {
            if (char == ':') {
                break idx;
            }
        } else line.items.len;

        var parts = std.mem.split(u8, line.items[colon_pos + 1 ..], "|");
        var winning_numbers = blk: {
            var set = Set.init(allocator);
            var nums = std.mem.tokenize(u8, parts.next().?, " ");
            while (nums.next()) |num| {
                try set.put(try std.fmt.parseInt(usize, num, 10), {});
            }
            break :blk set;
        };
        defer winning_numbers.deinit();

        var count: u6 = 0;
        var owned_numbers = std.mem.tokenize(u8, parts.next().?, " ");
        while (owned_numbers.next()) |num_str| {
            const num = try std.fmt.parseInt(usize, num_str, 10);
            if (winning_numbers.contains(num)) {
                count += 1;
            }
        }

        try scratchcards.append(.{ .winners = count });

        switch (count) {
            0 => continue,
            1 => part_one += 1,
            else => part_one += @as(usize, 1) << (count - 1),
        }
    }

    var part_two: usize = 0;
    for (scratchcards.items, 0..) |scratchcard, current_id| {
        for (1..scratchcard.winners + 1) |i| {
            scratchcards.items[current_id + i].amount += scratchcard.amount;
        }
        part_two += scratchcard.amount;
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
