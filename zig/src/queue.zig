const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const io = @import("io.zig");

fn create_rules(allocator: Allocator, hm: *std.StringHashMap(std.ArrayList(u32)), buffer: []const u8) !void {
    var lines = std.mem.splitAny(u8, buffer, "\n|");
    const first_digit = lines.next() orelse unreachable;
    const second_digit = lines.next() orelse unreachable;

    const value = try hm.getOrPut(first_digit);
    if (!value.found_existing) {
        var l = ArrayList(u32).init(allocator);
        try l.append(try std.fmt.parseInt(u32, second_digit, 10));
        value.value_ptr.* = l;
    } else {
        try value.value_ptr.*.append(try std.fmt.parseInt(u32, second_digit, 10))
    }
}

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    var lines = std.mem.splitSequence(u8, buffer, "\n\n");

    var hm = std.StringHashMap(ArrayList(u32)).init(allocator);
    defer {
        var it = hm.valueIterator();
        while (it.next()) |value_ptr| {
            value_ptr.deinit();
        }
        hm.deinit();
    }
    const rules = lines.next() orelse unreachable;
    try create_rules(allocator, &hm, rules);

    // const instructions = lines.next() orelse unreachable;

    return 0;
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    _ = allocator;
    _ = path;

    return 0;
}

test "part_one_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day5/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_one(allocator, path);
    try expect(result == 143);
}

test "part_two_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day5/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_one(allocator, path);
    try expect(result == 143);
}
