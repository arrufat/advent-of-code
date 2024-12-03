const std = @import("std");
const parseInt = std.fmt.parseInt;

const input = @embedFile("inputs/input03");

pub fn main() !void {
    var sum_part1: i64 = 0;
    var tokens_mul = std.mem.tokenizeSequence(u8, input, "mul(");
    if (!std.mem.eql(u8, "mul(", input[0..4])) _ = tokens_mul.next();
    while (tokens_mul.next()) |mul| {
        var tokens_par = std.mem.tokenizeScalar(u8, mul, ')');
        if (tokens_par.next()) |contents| {
            if (std.mem.indexOfScalar(u8, contents, ',')) |pos| {
                const left: i64 = parseInt(i64, contents[0..pos], 10) catch continue;
                const right: i64 = parseInt(i64, contents[pos + 1 ..], 10) catch continue;
                sum_part1 += left * right;
            }
        }
    }
    std.debug.print("part1: {d}\n", .{sum_part1});

    var sum_part2: i64 = 0;
    var enabled = true;
    var pos: usize = 0;
    while (pos < input.len) {
        const mul_pos = std.mem.indexOfPos(u8, input, pos, "mul(") orelse input.len;
        const do_pos = std.mem.indexOfPos(u8, input, pos, "do()") orelse input.len;
        const dont_pos = std.mem.indexOfPos(u8, input, pos, "don't()") orelse input.len;
        if (mul_pos < do_pos and mul_pos < dont_pos) {
            pos = mul_pos + 4;
            if (!enabled) continue;
            const par_pos = std.mem.indexOfScalar(u8, input[mul_pos..], ')') orelse continue;
            const contents = input[mul_pos + 4 .. mul_pos + par_pos];
            if (std.mem.indexOfScalar(u8, contents, ',')) |idx| {
                const left: i64 = parseInt(i64, contents[0..idx], 10) catch continue;
                const right: i64 = parseInt(i64, contents[idx + 1 ..], 10) catch continue;
                sum_part2 += left * right;
            }
        } else if (dont_pos < mul_pos and dont_pos < do_pos) {
            pos = dont_pos + 7;
            enabled = false;
        } else if (do_pos < mul_pos and do_pos < dont_pos) {
            pos = do_pos + 4;
            enabled = true;
        } else {
            break;
        }
    }
    std.debug.print("part2: {d}\n", .{sum_part2});
}
