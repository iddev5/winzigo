const Window = @This();
const Core = @import("Core.zig");
const types = @import("../main.zig");
const js = @import("js_interop.zig");

id: js.CanvasId,
core: *Core,

pub fn init(core: *Core, info: types.WindowInfo) !*Window {
    const window = try core.allocator.create(Window);
    window.* = Window{
        .id = js.wzCanvasInit(info.width, info.height),
        .core = core,
    };
    if (info.title) |t| window.setTitle(t);
    return window;
}

pub fn deinit(window: *Window) void {
    js.wzCanvasDeinit(window.id);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    js.wzCanvasSetTitle(window.id, title.ptr, title.len);
}

pub fn setSize(window: *Window, width: u32, height: u32) void {
    js.wzCanvasSetSize(window.id, width, height);
}

pub fn getSize(_: *Window) types.Dim {
    return .{ 0, 0 };
}
