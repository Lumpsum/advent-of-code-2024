const std = @import("std");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const expect = std.testing.expect;
const io = @import("io.zig");

const LocationLists = struct {
    list_one: []i32,
    list_two: []i32,

    fn sort_lists(Self: LocationLists) void {
        std.mem.sort(i32, Self.list_one, {}, comptime std.sort.asc(i32));
        std.mem.sort(i32, Self.list_two, {}, comptime std.sort.asc(i32));
    }

    fn sum_sorted_list_difference(Self: LocationLists) u32 {
        Self.sort_lists();

        var result: u32 = 0;
        for (Self.list_one, 0..) |item, index| {
            result += @abs(item - Self.list_two[index]);
        }

        return result;
    }

    fn create_from_buffer(allocator: std.mem.Allocator, buffer: []u8) !LocationLists {
        var list_one = ArrayList(i32).init(allocator);
        defer list_one.deinit();

        var list_two = ArrayList(i32).init(allocator);
        defer list_two.deinit();

        var lines = std.mem.splitAny(u8, buffer, "\r\n\t");
        while (lines.next()) |line| {
            var characters = std.mem.splitScalar(u8, line, ' ');
            var first = true;
            while (characters.next()) |c| {
                const value = std.fmt.parseInt(i32, c, 10) catch {
                    continue;
                };
                if (first) {
                    try list_one.append(value);
                    first = false;
                } else {
                    try list_two.append(value);
                }
            }
        }

        const x = try list_one.toOwnedSlice();
        const y = try list_two.toOwnedSlice();
        return LocationLists{ .list_one = x, .list_two = y };
    }

    fn cleanup(Self: LocationLists, allocator: std.mem.Allocator) void {
        defer allocator.free(Self.list_one);
        defer allocator.free(Self.list_two);
    }
};

fn create_list_hashmap(allocator: std.mem.Allocator, buffer: []u8) !u32 {
    var l = ArrayList(u32).init(allocator);
    defer l.deinit();

    var h = std.AutoHashMap(u32, u32).init(allocator);
    defer h.deinit();

    var lines = std.mem.splitAny(u8, buffer, "\r\n");
    while (lines.next()) |line| {
        var characters = std.mem.splitScalar(u8, line, ' ');
        var first = true;
        while (characters.next()) |c| {
            const value = std.fmt.parseInt(u32, c, 10) catch {
                continue;
            };
            if (first) {
                try l.append(value);
                first = false;
            } else {
                const v = h.get(value) orelse {
                    try h.put(value, 1);
                    continue;
                };
                try h.put(value, (v + 1));
            }
        }
    }

    const x = try l.toOwnedSlice();
    defer allocator.free(x);

    var result: u32 = 0;
    for (x) |item| {
        const amount = h.get(item) orelse continue;
        result += item * amount;
    }
    return result;
}

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    const location_list = try LocationLists.create_from_buffer(allocator, buffer);
    defer location_list.cleanup(allocator);

    const result = location_list.sum_sorted_list_difference();
    return result;
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return create_list_hashmap(allocator, buffer);
}

test "part_one_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day1/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_one(allocator, path);
    try expect(result == 11);
}

test "part_two_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day1/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_two(allocator, path);
    try expect(result == 31);
}
