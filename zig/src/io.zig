const std = @import("std");

pub fn read_file(allocator: std.mem.Allocator, path: []u8) ![]u8 {
    const f = try std.fs.cwd().openFile(path, .{});
    defer f.close();

    const stat = try f.stat();
    const buffer = try f.readToEndAlloc(allocator, stat.size);
    return buffer;
}
