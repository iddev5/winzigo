const app = @import("app");

export fn wasm_init() void {
    app.init() catch |err| @panic(@errorName(err));
}

export fn wasm_update() bool {
    return app.update() catch |err| @panic(@errorName(err));
}

export fn wasm_deinit() void {
    app.deinit();
}
