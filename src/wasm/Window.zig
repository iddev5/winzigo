const Window = @This();
const Core = @import("Core.zig");
const types = @import("../main.zig");
const js = @import("js_interop.zig");
const std = @import("std");

id: js.CanvasId,
selector_id: []const u8,
core: *Core,

pub fn init(core: *Core, info: types.WindowInfo) !*Window {
    const window = try core.allocator.create(Window);
    var name = [1]u8{0} ** 18;
    window.* = Window{
        .id = js.wzCanvasInit(info.width, info.height, &name[0]),
        .core = core,
        .selector_id = try core.allocator.dupe(u8, name[0 .. name.len - @as(u32, if (name[name.len - 1] == 0) 1 else 0)]),
    };
    if (info.title) |t| window.setTitle(t);

    return window;
}

pub fn deinit(window: *Window) void {
    js.wzCanvasDeinit(window.id);
    window.core.allocator.free(window.selector_id);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    js.wzCanvasSetTitle(window.id, title.ptr, title.len);
}

pub fn setSize(window: *Window, width: u32, height: u32) void {
    js.wzCanvasSetSize(window.id, width, height);
}

pub fn getSize(window: *Window) types.Dim {
    return .{
        .width = @intCast(u16, js.wzCanvasGetWidth(window.id)),
        .height = @intCast(u16, js.wzCanvasGetHeight(window.id)),
    };
}
