const std = @import("std");
const input = @embedFile("inputs/input02");
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var levels = std.BoundedArray(i32, 16){};
    var safe_count_part1: u32 = 0;
    var safe_count_part2: u32 = 0;
    while (lines.next()) |line| {
        levels.clear();
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        while (tokens.next()) |token| {
            levels.appendAssumeCapacity(parseInt(i32, token, 10) catch @panic("wrong int"));
        }
        if (isSafe(levels.slice())) {
            safe_count_part1 += 1;
        } else {
            for (0..levels.len) |i| {
                var copy = levels;
                _ = copy.orderedRemove(i);
                if (isSafe(copy.slice())) {
                    safe_count_part2 += 1;
                    break;
                }
            }
        }
    }
    std.debug.print("part 1: {d}\n", .{safe_count_part1});
    std.debug.print("part 2: {d}\n", .{safe_count_part1 + safe_count_part2});
}

fn isSafe(levels: []i32) bool {
    var window = std.mem.window(i32, levels, 2, 1);
    var diffs = std.BoundedArray(i32, 16){};
    while (window.next()) |items| {
        diffs.appendAssumeCapacity(items[0] - items[1]);
    }
    return if (@abs(diffs.buffer[0]) > 3) false else for (diffs.slice()[1..]) |diff| {
        if (diffs.buffer[0] * diff <= 0 or @abs(diff) > 3) break false;
    } else true;
}
