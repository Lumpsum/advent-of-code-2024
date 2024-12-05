const std = @import("std");
const io = @import("io.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

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

    fn find_xmas(Self: Grid) !u32 {
        var result: u32 = 0;
        result = 0;
        const word = "xmas";
        const right_width_limit = Self.width - word.len;
        const left_width_limit = word.len - 1;
        const heigth_limit = Self.height - word.len;
        _ = left_width_limit;
        _ = heigth_limit;
        var match_word: *const [4:0]u8 = undefined;

        for (Self.items, 0..) |_, index| {
            const mod = index % (Self.width);
            if (std.mem.eql(u8, Self.items[index .. index + 1], "S")) {
                match_word = "SAMX";
            } else if (std.mem.eql(u8, Self.items[index .. index + 1], "X")) {
                match_word = "XMAS";
            } else {
                continue;
            }
            if (mod <= right_width_limit) {
                std.log.info("{c}", .{match_word});
                if (Self.match_word_right(index, match_word)) {
                    result += 1;
                }
            }
        }

        return result;
    }

    fn match_word_right(Self: Grid, index: usize, word: *const [4:0]u8) bool {
        return std.mem.eql(u8, Self.items[index .. index + word.len], word);
    }
};

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();
    const grid = try Grid.create_from_u8(&list, buffer);
    return try grid.find_xmas();
}

pub fn solve_part_two(allocator: std.mem.Allocator, path: []u8) !u32 {
    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    return 0;
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
    try expect(result == 11);
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
    try expect(result == 31);
}
