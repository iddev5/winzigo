const Core = @This();
const types = @import("../main.zig");
pub const Window = @import("Window.zig");

pad0: u8,

pub fn init() !Core {
    return Core{ .pad0 = 1 };
}

pub fn deinit(core: *Core) void {
    _ = core;
}

pub fn createWindow(core: *Core, info: types.WindowInfo) Window {
    return Window.init(core, info);
}

pub fn pollEvent(core: *Core) ?types.Event {
    _ = core;
    return null;
}

pub fn waitEvent(core: *Core) ?types.Event {
    _ = core;
    return null;
}
