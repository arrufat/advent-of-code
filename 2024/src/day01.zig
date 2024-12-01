const std = @import("std");
const input = @embedFile("inputs/input01");
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var left = std.ArrayList(i32).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i32).init(allocator);
    defer right.deinit();

    var tokens = std.mem.tokenizeAny(u8, input, " \n");
    while (tokens.next()) |token| {
        try left.append(try parseInt(i32, token, 10));
        try right.append(try parseInt(i32, tokens.next() orelse @panic("expected 2 tokens"), 10));
    }

    std.mem.sort(i32, left.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, std.sort.asc(i32));
    var sum_diffs: u32 = 0;
    for (left.items, right.items) |l, r| sum_diffs += @abs(l - r);
    std.debug.print("part 1: {}\n", .{sum_diffs});

    var counts = std.AutoArrayHashMap(i32, i32).init(allocator);
    defer counts.deinit();
    for (right.items) |i| try counts.put(i, (counts.get(i) orelse 0) + 1);
    var sum_counts: i32 = 0;
    for (left.items) |i| sum_counts += i * (counts.get(i) orelse 0);
    std.debug.print("part 2: {}\n", .{sum_counts});
}
