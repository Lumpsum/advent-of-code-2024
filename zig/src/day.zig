const std = @import("std");
const location_list = @import("location_list.zig");
const debug = std.debug.print;

const data_folder = "../data/";

const ConfigError = error{
    MissingDay,
    MissingPart,
    InvalidPart,
};

pub const DayConfig = struct {
    day: u8,
    part: u8,

    pub fn init(day: u8, part: u8) DayConfig {
        return DayConfig{ .day = day, .part = part };
    }

    pub fn info(self: DayConfig) !void {
        const outw = std.io.getStdOut().writer();
        try outw.print("running day {} part {}\n", .{ self.day, self.part });
    }
};

pub fn solve(day_config: DayConfig) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();
    const file_path = try std.fmt.allocPrint(allocator, "{s}day{d}/part{d}.txt", .{ data_folder, day_config.day, day_config.part });
    defer allocator.free(file_path);

    switch (day_config.day) {
        1 => {
            const r = try switch (day_config.part) {
                1 => location_list.solve_part_one(allocator, file_path),
                2 => location_list.solve_part_two(allocator, file_path),
                else => return ConfigError.InvalidPart,
            };
            try print_result(r);
        },
        else => return ConfigError.MissingDay,
    }
}

fn print_result(result: u32) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result: {d}", .{result});

    try bw.flush();
}
