const Core = @This();
const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const types = @import("../main.zig");
pub const Window = @import("Window.zig");

allocator: std.mem.Allocator,
window: *Window = undefined,

var global_core: ?*Core = null;

const js = struct {
    const CanvasId = u32;

    extern fn wzEventShift() c_int;
};

pub fn init(allocator: std.mem.Allocator) !*Core {
    if (global_core != null) @panic("only one Core allowed for wasm backend");

    global_core = try allocator.create(Core);
    global_core.?.* = Core{
        .allocator = allocator,
    };

    return global_core.?;
}

pub fn deinit(core: *Core) void {
    core.allocator.destroy(core);
    global_core = null;
}

pub fn createWindow(core: *Core, info: types.WindowInfo) !*Window {
    global_core.?.window = try Window.init(core, info);
    return global_core.?.window;
}

pub fn pollEvent(_: *Core) ?types.Event {
    const ev_type = js.wzEventShift();
    if (ev_type == 0)
        return null;

    const window = wasmCanvasToWindow(@intCast(u32, js.wzEventShift()));

    return switch (ev_type) {
        // Key Press
        // ISSUE: it currently spams keydown when a key is already down,
        // like how a key state work, i.e key repeat handling is needed.
        1 => types.Event{
            .window = window,
            .ev = .{
                .key_press = .{
                    .key = @intToEnum(types.Key, js.wzEventShift()),
                },
            },
        },
        // Key Release
        2 => types.Event{
            .window = window,
            .ev = .{
                .key_release = .{
                    .key = @intToEnum(types.Key, js.wzEventShift()),
                },
            },
        },
        // Mouse Down
        3 => types.Event{
            .window = window,
            .ev = .{
                .button_press = .{
                    .button = wasmTranslateButton(@intCast(u2, js.wzEventShift())),
                },
            },
        },
        // Mouse Up
        4 => types.Event{
            .window = window,
            .ev = .{
                .button_release = .{ .button = wasmTranslateButton(
                    @intCast(u2, js.wzEventShift()),
                ) },
            },
        },
        // Mouse Motion
        5 => types.Event{
            .window = window,
            .ev = .{
                .mouse_motion = .{
                    .x = @intCast(i16, js.wzEventShift()),
                    .y = @intCast(i16, js.wzEventShift()),
                },
            },
        },
        // Mouse Enter
        6 => types.Event{
            .window = window,
            .ev = .{
                .mouse_enter = .{
                    .x = @intCast(i16, js.wzEventShift()),
                    .y = @intCast(i16, js.wzEventShift()),
                },
            },
        },
        // Mouse Leave
        7 => types.Event{
            .window = window,
            .ev = .{
                .mouse_leave = .{
                    .x = @intCast(i16, js.wzEventShift()),
                    .y = @intCast(i16, js.wzEventShift()),
                },
            },
        },
        // Mouse Scroll
        8 => types.Event{
            .window = window,
            .ev = .{
                .mouse_scroll = .{
                    .scroll_x = signum(@intCast(i16, js.wzEventShift())),
                    .scroll_y = signum(@intCast(i16, js.wzEventShift())),
                },
            },
        },
        else => unreachable,
    };
}

pub fn waitEvent(core: *Core) ?types.Event {
    // We cannot wait/halt in wasm, so its no different
    return core.pollEvent();
}

fn wasmTranslateButton(button: u2) types.Button {
    return switch (button) {
        0 => .left,
        1 => .middle,
        2 => .right,
        else => unreachable,
    };
}

fn wasmCanvasToWindow(canvas: js.CanvasId) types.Window {
    _ = canvas;
    return types.Window.initFromInternal(global_core.?.window);
}

fn signum(n: i16) i2 {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    }
    return 0;
}
