const app = @import("app");

pub fn main() anyerror!void {
    try app.init();
    defer app.deinit();

    while (true) {
        var success = try app.update();
        if (!success) {
            break;
        }
    }
}
