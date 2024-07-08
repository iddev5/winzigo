const EGL = @import("xcb/egl_bindings.zig");

pub const GLContext = struct {
    egl: EGL,
    display: EGL.Display,
    surface: EGL.Surface,
    context: EGL.Context,

    pub fn swapBuffers(gl: *GLContext) !void {
        try gl.egl.swapBuffers(gl.display, gl.surface);
    }
};
