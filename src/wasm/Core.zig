const Core = @This();
const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const types = @import("../main.zig");
pub const Window = @import("Window.zig");

pad0: u8,

const EventNode = std.TailQueue(types.Event).Node;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var event_queue: std.TailQueue(types.Event) = .{};
var has_core = false;

const js = struct {
    const CanvasId = u32;

    extern fn wzLog(str: [*]const u8, len: u32) void;
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
    _ = core;
    return null;
}

fn log(str: []const u8) void {
    js.wzLog(str.ptr, str.len);
}

fn wasmTranslateButton(button: u2) types.Button {
    return switch (button) {
        0 => .left,
        1 => .middle,
        2 => .right,
        else => unreachable,
    };
}

export fn wasmMouseDown(canvas: js.CanvasId, x: u32, y: u32, button: u8) void {
    _ = x;
    _ = y;
    _ = canvas;

    const event = types.Event{ .window = undefined, .ev = .{ .button_press = .{
        .button = wasmTranslateButton(@intCast(u2, button)),
    } } };

    const node = arena.allocator().create(EventNode) catch @panic("out of memory");

    node.* = .{
        .data = event,
    };
    event_queue.append(node);
}
