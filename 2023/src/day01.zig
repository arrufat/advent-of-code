const std = @import("std");

const Digit = enum(usize) {
    one = 1,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,

    fn fromInt(n: usize) ?Digit {
        return switch (n) {
            1...9 => @as(Digit, @enumFromInt(n)),
            else => null,
        };
    }

    fn fromString(string: []const u8) ?Digit {
        return for (std.meta.tags(Digit)) |tag| {
            const name = @tagName(tag);
            if (name.len > string.len)
                continue;
            if (std.mem.eql(u8, name, string[0..name.len])) {
                break tag;
            }
        } else null;
    }
};

pub fn solve(allocator: std.mem.Allocator, input_path: []const u8) !void {
    // https://www.openmsevenymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/
    const input_file = try std.fs.cwd().openFile(input_path, .{ .mode = .read_only });
    defer input_file.close();

    var buffered = std.io.bufferedReader(input_file.reader());
    var reader = buffered.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    var total: usize = 0;
    while (true) {
        defer line.clearRetainingCapacity();
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        var idx: usize = 0;
        var found_first: bool = false;
        var last: usize = 0;
        while (idx < line.items.len) : (idx += 1) {
            // part 1
            if (std.ascii.isDigit(line.items[idx])) {
                last = try std.fmt.charToDigit(line.items[idx], 10);
                if (!found_first) {
                    found_first = true;
                    total += 10 * last;
                }
                // part 2
            } else if (Digit.fromString(line.items[idx..])) |digit| {
                last = @intFromEnum(digit);
                if (!found_first) {
                    found_first = true;
                    total += 10 * last;
                }
                // We need to decrement index by two:
                // 1 is added by the while loop
                // 1 is the maximum overlap between number names: sevenine, eighthree
                // This is completely optional, but allows us to skip parts of the line.
                idx += @tagName(Digit.fromInt(last).?).len - 2;
            }
        }
        total += last;
    }
    std.debug.print("total: {}\n", .{total});
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
