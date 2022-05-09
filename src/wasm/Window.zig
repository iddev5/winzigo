const Window = @This();
const Core = @import("Core.zig");
const types = @import("../main.zig");

id: js.CanvasId,
core: *Core,

const js = struct {
    const CanvasId = u32;

    extern fn wzCanvasInit(width: u32, height: u32) CanvasId;
    extern fn wzCanvasDeinit(canvas: CanvasId) void;
    extern fn wzCanvasSetTitle(canvas: CanvasId, title: [*]const u8, len: usize) void;
    extern fn wzCanvasSetSize(canvas: CanvasId, width: u32, height: u32) void;
};

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
