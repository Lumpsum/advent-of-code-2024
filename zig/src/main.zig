const std = @import("std");
const clap = @import("clap");
const d = @import("day.zig");

// pub fn main() !void {
//     // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
//     std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
//
//     // stdout is for the actual output of your application, for example if you
//     // are implementing gzip, then only the compressed bytes should be sent to
//     // stdout, not any debugging messages.
//     const stdout_file = std.io.getStdOut().writer();
//     var bw = std.io.bufferedWriter(stdout_file);
//     const stdout = bw.writer();
//
//     try stdout.print("Run `zig build test` to run the tests.\n", .{});
//
//     try bw.flush(); // don't forget to flush!
// }

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-d, --day <u8> day to run
        \\-p, --part <u8> part of the day to run
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{ .diagnostic = &diag, .allocator = gpa.allocator() }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const day = res.args.day orelse @panic("missing argument day");
    const part = res.args.part orelse @panic("missing argument part");

    const dayConfig = d.DayConfig.init(day, part);
    try dayConfig.info();

    try d.solve(dayConfig);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
