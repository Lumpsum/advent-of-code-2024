const std = @import("std");
const io = @import("io.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

const Limits = struct {
    width_limit: usize,
    height_limit: usize,
};

const Grid = struct {
    width: usize,
    height: usize,
    items: []u8,

    fn create_from_u8(list: *std.ArrayList(u8), buffer: []u8) !Grid {
        var width: usize = undefined;
        var height: usize = 0;
        var first = true;

        for (buffer, 0..) |value, index| {
            if (std.mem.eql(u8, buffer[index .. index + 1], "\n")) {
                height += 1;
                if (first) {
                    width = index;
                    first = false;
                }
            } else {
                try list.append(value);
            }
        }

        return Grid{ .width = width, .height = height, .items = list.items };
    }

    fn find_xmas(Self: Grid, allocator: Allocator) !u32 {
        var result: u32 = 0;
        const word = "xmas";
        const width_limit = Self.width - word.len;
        const heigth_limit = Self.height - word.len;
        var row: isize = -1;

        var match_word: *const [4:0]u8 = undefined;

        for (Self.items, 0..) |_, index| {
            const mod = index % (Self.width);

            if (mod == 0) {
                row += 1;
            }

            if (std.mem.eql(u8, Self.items[index .. index + 1], "S")) {
                match_word = "SAMX";
            } else if (std.mem.eql(u8, Self.items[index .. index + 1], "X")) {
                match_word = "XMAS";
            } else {
                continue;
            }

            if (mod <= width_limit) {
                if (Self.match_right(index, match_word)) {
                    result += 1;
                }

                if (row <= heigth_limit) {
                    if (try Self.match_width_change(index, 1, match_word, allocator)) {
                        result += 1;
                    }
                }
            }

            if (row <= heigth_limit) {
                if (try Self.match_width_change(index, 0, match_word, allocator)) {
                    result += 1;
                }

                if (mod >= match_word.len - 1) {
                    if (try Self.match_width_change(index, -1, match_word, allocator)) {
                        result += 1;
                    }
                }
            }
        }

        return result;
    }

    fn match_right(Self: Grid, index: usize, word: *const [4:0]u8) bool {
        return std.mem.eql(u8, Self.items[index .. index + word.len], word);
    }

    fn match_width_change(Self: Grid, index: usize, index_change: isize, word: *const [4:0]u8, allocator: Allocator) !bool {
        var list = ArrayList(u8).init(allocator);
        defer list.deinit();

        const width: isize = @intCast(Self.width);
        const i_index: isize = @intCast(index);
        const i_index_change: isize = @intCast(index_change);

        for (0..4) |i| {
            const i_i: isize = @intCast(i);
            const new_index: usize = @intCast(i_index + (i_i * (width + i_index_change)));
            try list.append(Self.items[new_index]);
        }

        return std.mem.eql(u8, list.items, word);
    }

    fn find_x_mas(Self: Grid, allocator: Allocator) !u32 {
        var result: u32 = 0;
        const word = "mas";
        const width_limit = Self.width - word.len;
        const heigth_limit = Self.height - word.len;

        var row: isize = -1;

        for (Self.items, 0..) |_, index| {
            const mod = index % (Self.width);

            if (mod == 0) {
                row += 1;
            }

            if (mod <= width_limit and row <= heigth_limit) {
                if (std.mem.eql(u8, Self.items[index .. index + 1], "S") or std.mem.eql(u8, Self.items[index .. index + 1], "M")) {
                    if (try Self.match_x_mas(allocator, index)) {
                        result += 1;
                    }
                }
            }
        }

        return result;
    }

    fn match_x_mas(Self: Grid, allocator: Allocator, index: usize) !bool {
        var list_one = ArrayList(u8).init(allocator);
        defer list_one.deinit();

        var list_two = ArrayList(u8).init(allocator);
        defer list_two.deinit();

        try list_one.append(Self.items[index]);
        try list_one.append(Self.items[index + Self.width + 1]);
        try list_one.append(Self.items[index + (Self.width * 2) + 2]);

        try list_two.append(Self.items[index + 2]);
        try list_two.append(Self.items[index + Self.width + 1]);
        try list_two.append(Self.items[index + (Self.width * 2)]);

        if (std.mem.eql(u8, list_one.items, "MAS") or std.mem.eql(u8, list_one.items, "SAM")) {
            if (std.mem.eql(u8, list_two.items, "MAS") or std.mem.eql(u8, list_two.items, "SAM")) {
                return true;
            }
        }
        return false;
    }
};

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();
    const grid = try Grid.create_from_u8(&list, buffer);
    return try grid.find_xmas(allocator);
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();
    const grid = try Grid.create_from_u8(&list, buffer);
    return try grid.find_x_mas(allocator);
}

test "part_one_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day4/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_one(allocator, path);
    try expect(result == 18);
}

test "part_two_test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const path = try std.fmt.allocPrint(allocator, "../data/day4/test.txt", .{});
    defer allocator.free(path);
    const result = try solve_part_two(allocator, path);
    try expect(result == 9);
}
