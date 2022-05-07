const Window = @This();

const std = @import("std");
const xcb = @import("bindings.zig");
const Core = @import("Core.zig");
const types = @import("../main.zig");

core: *Core,
window: u32 = undefined,
width: u16,
height: u16,

pub fn init(core: *Core, info: types.WindowInfo) Window {
    var self: Window = undefined;
    self.core = core;
    self.window = xcb.generateId(core.connection);
    _ = xcb.createWindow(
        core.connection,
        0,
        self.window,
        core.screen.root,
        0,
        0,
        info.width,
        info.height,
        0,
        xcb.WindowClass.InputOutput,
        core.screen.root_visual,
        0,
        null,
    );

    var value = @enumToInt(xcb.EventMask.KeyPress);
    value |= @enumToInt(xcb.EventMask.KeyRelease);
    value |= @enumToInt(xcb.EventMask.ButtonPress);
    value |= @enumToInt(xcb.EventMask.ButtonRelease);
    value |= @enumToInt(xcb.EventMask.PointerMotion);
    value |= @enumToInt(xcb.EventMask.FocusChange);
    value |= @enumToInt(xcb.EventMask.EnterWindow);
    value |= @enumToInt(xcb.EventMask.LeaveWindow);
    value |= @enumToInt(xcb.EventMask.StructureNotify);

    _ = xcb.changeWindowAttributes(
        core.connection,
        self.window,
        @enumToInt(xcb.Cw.EventMask),
        &[_]u32{value},
    );

    _ = xcb.mapWindow(core.connection, self.window);

    if (info.title) |t| self.setTitle(t);

    return self;
}

pub fn deinit(window: *Window) void {
    xcb.destroyWindow(window.core.connection, window.window);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    _ = xcb.changeProperty(
        window.core.connection,
        .Replace,
        window.window,
        @enumToInt(xcb.Defines.Atom.WmName),
        @enumToInt(xcb.Defines.Atom.String),
        @bitSizeOf(u8),
        @intCast(u32, title.len),
        @ptrCast(*const anyopaque, title),
    );
}

pub fn setSize(window: *Window, width: u16, height: u16) void {
    const values: []u16 = &.{ width, height };
    _ = xcb.configureWindow(
        window.core.connection,
        window.window,
        @enumToInt(xcb.Defines.Config.WindowWidth) | @enumToInt(xcb.Defines.Config.WindowHeight),
        @ptrCast(*anyopaque, values),
    );
    window.width = width;
    window.height = height;
}

pub fn getSize(window: *Window) types.Dim {
    return .{ .width = window.width, .height = window.height };
}
