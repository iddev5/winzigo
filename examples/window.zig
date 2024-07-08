const std = @import("std");
const winzigo = @import("winzigo");

var core: winzigo = undefined;
var window: winzigo.Window = undefined;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn init() !void {
    const allocator = gpa.allocator();

    core = try winzigo.init(allocator);
    errdefer core.deinit();

    window = try core.createWindow(.{});
    errdefer window.deinit();

    window.setTitle("Hello");
    window.setSize(640, 480);
}

pub fn update() !bool {
    while (core.pollEvent()) |event| {
        switch (event.ev) {
            .quit => |_| {
                std.log.info("quit", .{});
                return false;
            },
            else => {},
        }
    }
    return true;
}

pub fn deinit() void {
    window.deinit();
    core.deinit();
    _ = gpa.deinit();

    std.log.info("All your window decorations are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
