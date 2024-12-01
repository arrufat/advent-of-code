const std = @import("std");
const input = @embedFile("inputs/input01");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var args = std.process.args();
    _ = args.skip();
    var tokens = std.mem.tokenizeAny(u8, input, " \n");
    var list_left = std.ArrayList(i32).init(allocator);
    defer list_left.deinit();
    const part: u32 = if (args.next()) |arg| if (std.mem.eql(u8, arg, "1")) 1 else 2 else 1;
    var list_right = std.ArrayList(i32).init(allocator);
    defer list_right.deinit();
    while (tokens.next()) |token| {
        try list_left.append(try std.fmt.parseInt(i32, token, 10));
        try list_right.append(try std.fmt.parseInt(
            i32,
            tokens.next() orelse @panic("expected two tokens per line"),
            10,
        ));
    }
    if (part == 1) {
        std.mem.sort(i32, list_left.items, {}, std.sort.asc(i32));
        std.mem.sort(i32, list_right.items, {}, std.sort.asc(i32));
        var sum_diffs: u32 = 0;
        for (list_left.items, list_right.items) |l, r| {
            sum_diffs += @abs(l - r);
        }
        std.debug.print("part 1: {}\n", .{sum_diffs});
    } else {
        var counts_right = std.AutoArrayHashMap(i32, i32).init(allocator);
        defer counts_right.deinit();
        for (list_right.items) |i| {
            const entry = try counts_right.getOrPut(i);
            if (entry.found_existing) entry.value_ptr.* += 1 else entry.value_ptr.* = 1;
        }
        var sum_counts: i32 = 0;
        for (list_left.items) |i| {
            sum_counts += i * (counts_right.get(i) orelse 0);
        }
        std.debug.print("part 2: {}\n", .{sum_counts});
    }
}
