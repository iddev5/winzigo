const Window = @This();

const std = @import("std");
const xcb = @import("bindings.zig");
const Core = @import("Core.zig");
const types = @import("../main.zig");

core: *Core,
window: u32 = undefined,
width: u16,
height: u16,

pub fn init(core: *Core, info: types.WindowInfo) !*Window {
    var self = try core.allocator.create(Window);
    errdefer core.allocator.destroy(self);

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

    var value = @intFromEnum(xcb.EventMask.KeyPress);
    value |= @intFromEnum(xcb.EventMask.KeyRelease);
    value |= @intFromEnum(xcb.EventMask.ButtonPress);
    value |= @intFromEnum(xcb.EventMask.ButtonRelease);
    value |= @intFromEnum(xcb.EventMask.PointerMotion);
    value |= @intFromEnum(xcb.EventMask.FocusChange);
    value |= @intFromEnum(xcb.EventMask.EnterWindow);
    value |= @intFromEnum(xcb.EventMask.LeaveWindow);
    value |= @intFromEnum(xcb.EventMask.StructureNotify);

    _ = xcb.changeWindowAttributes(
        core.connection,
        self.window,
        @intFromEnum(xcb.Cw.EventMask),
        &[_]u32{value},
    );

    _ = xcb.mapWindow(core.connection, self.window);

    if (info.title) |t| self.setTitle(t);

    return self;
}

pub fn deinit(window: *Window) void {
    xcb.destroyWindow(window.core.connection, window.window);
    window.core.allocator.destroy(window);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    _ = xcb.changeProperty(
        window.core.connection,
        .Replace,
        window.window,
        @intFromEnum(xcb.Defines.Atom.WmName),
        @intFromEnum(xcb.Defines.Atom.String),
        @bitSizeOf(u8),
        @as(u32, @intCast(title.len)),
        @as(*const anyopaque, @ptrCast(title)),
    );
}

pub fn setSize(window: *Window, width: u16, height: u16) void {
    const pair: [2]c_int = .{ width, height };
    _ = xcb.configureWindow(
        window.core.connection,
        window.window,
        @intFromEnum(xcb.Defines.Config.WindowWidth) | @intFromEnum(xcb.Defines.Config.WindowHeight),
        @as(*anyopaque, @ptrCast(@constCast(&pair))),
    );
    window.width = width;
    window.height = height;
}

pub fn getSize(window: *Window) types.Dim {
    const cookie = xcb.getGeometry(window.core.connection, window.window);
    const reply = xcb.getGeometryReply(window.core.connection, cookie, null);
    defer std.c.free(reply);

    return .{ .width = reply.width, .height = reply.height };
}
