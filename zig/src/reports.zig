const std = @import("std");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const expect = std.testing.expect;
const io = @import("io.zig");

const Direction = enum { increasing, decreasing, unknown };
const test_file = "../data/day2/test.txt";

fn get_reports(allocator: std.mem.Allocator, buffer: []u8, handle_error: bool) !u32 {
    var lines = std.mem.splitAny(u8, buffer, "\r\n");
    var result: u32 = 0;
    var i: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var list = ArrayList(i32).init(allocator);
        defer list.deinit();
        var characters = std.mem.splitScalar(u8, line, ' ');

        while (characters.next()) |c| {
            const value = std.fmt.parseInt(i32, c, 10) catch {
                continue;
            };
            try list.append(value);
        }

        const report = list.items;
        if (is_valid_report(report) == true) {
            result += 1;
        } else {
            if (handle_error) {
                var new_list = ArrayList(i32).init(allocator);
                defer new_list.deinit();

                for (report, 0..) |_, skip| {
                    new_list.clearRetainingCapacity();
                    for (report, 0..) |num, index| {
                        if (index != skip) {
                            try new_list.append(num);
                        }
                    }

                    if (is_valid_report(new_list.items)) {
                        result += 1;
                        break;
                    }
                }
            }
        }
        i += 1;
    }
    return result;
}

fn is_valid_report(list: []i32) bool {
    var previous_value: i32 = undefined;
    var direction = Direction.unknown;
    for (list, 0..) |n, i| {
        if (i != 0) {
            if (is_valid(n, previous_value, &direction) == false) {
                return false;
            }
        }

        previous_value = n;
    }

    return true;
}

fn is_valid(value: i32, previous_value: i32, direction: *Direction) bool {
    const difference: i32 = value - previous_value;
    if (difference == 0) return false;
    if (difference > 3) return false;
    if (difference < -3) return false;

    switch (direction.*) {
        Direction.unknown => {
            if (difference > 0) {
                direction.* = Direction.increasing;
            } else {
                direction.* = Direction.decreasing;
            }
        },
        Direction.decreasing => {
            if (difference > 0) return false;
        },
        Direction.increasing => {
            if (difference < 0) return false;
        },
    }
    return true;
}

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return try get_reports(allocator, buffer, false);
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return try get_reports(allocator, buffer, true);
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
    try expect(result == 2);
}

test "part_two_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "{s}", .{test_file});
    defer allocator.free(path);
    const result = try solve_part_two(allocator, path);
    std.log.warn("\n{d}\n", .{result});
    try expect(result == 4);
}
