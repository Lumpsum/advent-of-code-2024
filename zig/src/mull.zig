const std = @import("std");
const io = @import("io.zig");
const expect = std.testing.expect;

const test_file = "../data/day3/test.txt";
const test_file_2 = "../data/day3/test2.txt";

const MulError = error{
    InvalidDigit,
};

fn get_mull_instructions(buffer: []const u8, enable: bool) !u32 {
    var pos: u32 = 0;
    var result: u32 = 0;
    var active: bool = true;

    while ((pos + 8) < buffer.len) {
        if (std.mem.eql(u8, buffer[pos..(pos + 4)], "mul(")) {
            pos += 4;
            const first = get_digit(buffer, &pos, ',') catch continue;
            const second = get_digit(buffer, &pos, ')') catch continue;
            if (enable and active == false) {
                continue;
            }
            result += first * second;
        } else if (enable and std.mem.eql(u8, buffer[pos..(pos + 4)], "do()")) {
            active = true;
            pos += 4;
        } else if (enable and std.mem.eql(u8, buffer[pos..(pos + 7)], "don't()")) {
            active = false;
            pos += 7;
        } else {
            pos += 1;
        }
    }

    return result;
}

fn get_digit(buffer: []const u8, pos: *u32, end_byte: u8) !u32 {
    if (buffer[pos.*] >= '0' and buffer[pos.*] <= '9') {
        const start_position = pos.*;
        pos.* += 1;
        while (buffer[pos.*] >= '0' and buffer[pos.*] <= '9') {
            pos.* += 1;
        }
        const value = std.fmt.parseInt(u32, buffer[start_position..pos.*], 10) catch return MulError.InvalidDigit;
        if (buffer[pos.*] == end_byte) {
            pos.* += 1;
            return value;
        }
    }
    return MulError.InvalidDigit;
}

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return try get_mull_instructions(buffer, false);
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return try get_mull_instructions(buffer, true);
}

test "part_one_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "{s}", .{test_file});
    defer allocator.free(path);
    const result = try solve_part_one(allocator, path);
    std.log.warn("\n{d}\n", .{result});
    try expect(result == 161);
}

test "part_two_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "{s}", .{test_file_2});
    defer allocator.free(path);
    const result = try solve_part_two(allocator, path);
    std.log.warn("\n{d}\n", .{result});
    try expect(result == 48);
}
