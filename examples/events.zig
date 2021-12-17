const std = @import("std");
const winzigo = @import("winzigo");

pub fn main() anyerror!void {
    var core = try winzigo.init();
    defer core.deinit();

    var window = core.createWindow(.{});
    defer window.deinit();

    var is_running: bool = true;
    while (is_running) {
        if (core.pollEvent()) |event| {
            switch (event.ev) {
                .key_press => |ev| {
                    std.log.info("key pressed {}", .{ev.scancode});
                },
                .key_release => |ev| {
                    std.log.info("key released {}", .{ev.scancode});
                },
                .button_press => |ev| {
                    std.log.info("button pressed {s}", .{@tagName(ev.button)});
                },
                .button_release => |ev| {
                    std.log.info("button released {s}", .{@tagName(ev.button)});
                },
                .mouse_scroll => |ev| {
                    std.log.info("mouse scroll {s}", .{@tagName(ev.scroll_dir)});
                },
                .mouse_motion => |ev| {
                    std.log.info("mouse pos x: {} y: {}", .{ ev.x, ev.y });
                },
                .quit => |_| {
                    std.log.info("quit", .{});
                    is_running = false;
                },
            }
        }
    }
    std.log.info("All your queued events are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
