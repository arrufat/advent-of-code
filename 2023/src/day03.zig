const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const isDigit = std.ascii.isDigit;

fn findNum(line: []const u8, idx: usize) std.fmt.ParseIntError!usize {
    var begin = idx;
    while (begin > 0 and isDigit(line[begin - 1])) {
        begin -= 1;
    }
    var end = if (isDigit(line[idx])) idx + 1 else idx;
    while (end < line.len and isDigit(line[end])) {
        end += 1;
    }
    return std.fmt.parseUnsigned(usize, line[begin..end], 10);
}

pub fn solve(allocator: std.mem.Allocator, input_path: []const u8) !void {
    const input_file = try std.fs.cwd().openFile(input_path, .{ .mode = .read_only });
    defer input_file.close();

    var buffered = std.io.bufferedReader(input_file.reader());
    var reader = buffered.reader();

    var lines_array = ArrayList([]const u8).init(allocator);
    defer lines_array.deinit();
    defer {
        for (lines_array.items) |line| {
            allocator.free(line);
        }
    }
    var temp = std.ArrayList(u8).init(allocator);
    defer temp.deinit();

    while (true) {
        defer temp.clearRetainingCapacity();
        reader.streamUntilDelimiter(temp.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        try lines_array.append(try temp.toOwnedSlice());
    }
    var part_one: usize = 0;
    var part_two: usize = 0;
    const lines = lines_array.items;
    for (lines, 0..) |line, line_idx| {
        for (line, 0..) |char, char_idx| {
            if (char != '.' and !isDigit(char)) {
                // check for numbers around the symbol
                const l = char_idx > 0 and isDigit(line[char_idx - 1]);
                const r = char_idx < line.len - 1 and isDigit(line[char_idx + 1]);

                const t = line_idx > 0 and isDigit(lines[line_idx - 1][char_idx]);
                const b = line_idx < line.len - 1 and isDigit(lines[line_idx + 1][char_idx]);

                const tl = line_idx > 0 and char_idx > 0 and isDigit(lines[line_idx - 1][char_idx - 1]);
                const tr = line_idx > 0 and char_idx < line.len - 1 and isDigit(lines[line_idx - 1][char_idx + 1]);

                const bl = line_idx < line.len - 1 and char_idx > 0 and isDigit(lines[line_idx + 1][char_idx - 1]);
                const br = line_idx < line.len - 1 and char_idx < line.len - 1 and isDigit(lines[line_idx + 1][char_idx + 1]);

                var count: usize = 0;
                var ratio: usize = 1;
                if (l) {
                    const num = findNum(line, char_idx - 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (tl) {
                    const num = findNum(lines[line_idx - 1], char_idx - 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (t and !tl) {
                    const num = findNum(lines[line_idx - 1], char_idx);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (tr and !t) {
                    const num = findNum(lines[line_idx - 1], char_idx + 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (r) {
                    const num = findNum(line, char_idx + 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (bl) {
                    const num = findNum(lines[line_idx + 1], char_idx - 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (b and !bl) {
                    const num = findNum(lines[line_idx + 1], char_idx);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (br and !b) {
                    const num = findNum(lines[line_idx + 1], char_idx + 1);
                    part_one += num catch 0;
                    ratio *= num catch 1;
                    count += 1;
                }
                if (char == '*' and count == 2) {
                    part_two += ratio;
                }
            }
        }
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
