const Core = @This();
const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const types = @import("../main.zig");
pub const Window = @import("Window.zig");

pad0: u8,

const EventQueue = std.TailQueue(types.Event);
const EventNode = EventQueue.Node;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var event_queue: EventQueue = .{};
var has_core = false;

const js = struct {
    const CanvasId = u32;
};

pub fn init() !Core {
    if (has_core) @panic("only one Core allowed for wasm backend");
    has_core = true;

    return Core{
        .pad0 = 1,
    };
}

pub fn deinit(core: *Core) void {
    _ = core;
    has_core = false;
    arena.deinit();
}

pub fn createWindow(core: *Core, info: types.WindowInfo) Window {
    return Window.init(core, info);
}

pub fn pollEvent(core: *Core) ?types.Event {
    _ = core;
    if (event_queue.popFirst()) |n| return n.data;
    return null;
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
    return types.Window.initFromInternal(.{ .core = undefined, .id = canvas });
}

fn pushEvent(event: types.Event) void {
    const node = arena.allocator().create(EventNode) catch @panic("out of memory");

    node.* = .{
        .data = event,
    };
    event_queue.append(node);
}

export fn wasmMouseUp(canvas: js.CanvasId, _: i16, _: i16, button: u8) void {
    pushEvent(.{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{ .button_release = .{
            .button = wasmTranslateButton(@intCast(u2, button)),
        } },
    });
}

export fn wasmMouseDown(canvas: js.CanvasId, _: i16, _: i16, button: u8) void {
    pushEvent(.{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{ .button_press = .{
            .button = wasmTranslateButton(@intCast(u2, button)),
        } },
    });
}

export fn wasmMouseMotion(canvas: js.CanvasId, x: i16, y: i16) void {
    const event = types.Event{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{ .mouse_motion = .{ .x = x, .y = y } },
    };

    pushEvent(event);
}

export fn wasmMouseEnter(canvas: js.CanvasId, x: i16, y: i16) void {
    pushEvent(.{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{
            .mouse_enter = .{ .x = x, .y = y },
        },
    });
}

export fn wasmMouseLeave(canvas: js.CanvasId, x: i16, y: i16) void {
    pushEvent(.{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{
            .mouse_leave = .{ .x = x, .y = y },
        },
    });
}

fn signum(n: i16) i2 {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    }
    return 0;
}

export fn wasmMouseWheel(canvas: js.CanvasId, scroll_x: i16, scroll_y: i16) void {
    const event = types.Event{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{
            .mouse_scroll = .{
                .scroll_x = signum(scroll_x),
                .scroll_y = signum(scroll_y),
            },
        },
    };

    pushEvent(event);
}

export fn wasmKeyDown(canvas: js.CanvasId, key: u32) void {
    std.log.info("keycode: {}", .{key});

    const event = types.Event{
        .window = wasmCanvasToWindow(canvas),
        .ev = .{
            .key_press = .{ .key = @intToEnum(types.Key, key) },
        },
    };

    pushEvent(event);
}
