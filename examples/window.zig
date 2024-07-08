const std = @import("std");
const winzigo = @import("winzigo");

var core: winzigo = undefined;
var window: winzigo.Window = undefined;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var gl_context: winzigo.egl.GLContext = undefined;
var gl: gl_lib = undefined;

const gl_lib = struct {
    glViewport: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) void,
    glClearColor: *const fn (r: f32, g: f32, b: f32, a: f32) void,
    glClear: *const fn (bit: c_int) void,
};

pub fn init() !void {
    const allocator = gpa.allocator();

    core = try winzigo.init(allocator);
    errdefer core.deinit();

    window = try core.createWindow(.{});
    errdefer window.deinit();

    window.setTitle("Hello");
    window.setSize(640, 480);

    gl_context = try window.createGLContext();
    {
        var lib = try std.DynLib.open("libGL.so");
        inline for (@typeInfo(gl_lib).Struct.fields) |field| {
            @field(gl, field.name) = lib.lookup(field.type, field.name) orelse return error.SymbolNotFound;
        }
    }

    gl.glViewport(0, 0, 640, 480);
}

pub fn update() !bool {
    while (core.pollEvent()) |event| {
        switch (event.ev) {
            .quit => |_| {
                std.log.info("quit", .{});
                return false;
            },
            else => {},
        }
    }

    gl.glClearColor(1.0, 0.0, 0.0, 1.0);
    gl.glClear(0x00004000);

    try gl_context.swapBuffers();

    return true;
}

pub fn deinit() void {
    window.deinit();
    core.deinit();
    _ = gpa.deinit();

    std.log.info("All your window decorations are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
