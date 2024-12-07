const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const io = @import("io.zig");

const QueueErrror = error{
    InvalidCharacter,
};

fn create_rules(allocator: Allocator, hm: *std.AutoHashMap(u32, std.ArrayList(u32)), buffer: []const u8) !void {
    var lines = std.mem.splitAny(u8, buffer, "\n|");
    while (lines.next()) |line| {
        const first_digit = line;
        const second_digit = try std.fmt.parseInt(u32, lines.next() orelse unreachable, 10);

        const value = try hm.getOrPut(second_digit);
        if (!value.found_existing) {
            var l = ArrayList(u32).init(allocator);
            try l.append(try std.fmt.parseInt(u32, first_digit, 10));
            value.value_ptr.* = l;
        } else {
            try value.value_ptr.*.append(try std.fmt.parseInt(u32, first_digit, 10));
        }
    }
}

fn get_instructions(allocator: Allocator, instructions: []const u8) !ArrayList(u32) {
    var l = ArrayList(u32).init(allocator);
    var instruction_list = std.mem.splitScalar(u8, instructions, ',');
    while (instruction_list.next()) |instruction| {
        if (std.mem.eql(u8, instruction, "")) {
            return QueueErrror.InvalidCharacter;
        }
        try l.append(try std.fmt.parseInt(u32, instruction, 10));
    }

    return l;
}

fn valid_instruction(allocator: Allocator, instructions: []const u8, hm: std.AutoHashMap(u32, ArrayList(u32))) !?u32 {
    var l = get_instructions(allocator, instructions) catch return null;
    defer l.deinit();

    const u32_instructions = l.items;
    for (u32_instructions, 0..) |item, i| {
        const v = hm.getPtr(item) orelse continue;
        for (i + 1..u32_instructions.len) |j| {
            if (std.mem.containsAtLeast(u32, v.items, 1, u32_instructions[j .. j + 1])) {
                return null;
            }
        }
    }

    const middle_item: f32 = @floatFromInt(u32_instructions.len);
    return u32_instructions[@intFromFloat(middle_item / 2 - 0.5)];
}

pub fn solve_part_one(allocator: std.mem.Allocator, path: []u8) !u32 {
    var result: u32 = 0;
    result += 0;

    const buffer = try io.read_file(allocator, path);
    defer allocator.free(buffer);

    var lines = std.mem.splitSequence(u8, buffer, "\n\n");

    var hm = std.AutoHashMap(u32, ArrayList(u32)).init(allocator);
    defer {
        var it = hm.valueIterator();
        while (it.next()) |value_ptr| {
            value_ptr.deinit();
        }
        hm.deinit();
    }
    const rules = lines.next() orelse unreachable;
    try create_rules(allocator, &hm, rules);

    const instructions = lines.next() orelse unreachable;
    var instruction_list = std.mem.splitAny(u8, instructions, "\n|");
    while (instruction_list.next()) |instruction| {
        result += try valid_instruction(allocator, instruction, hm) orelse continue;
    }

    return result;
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
