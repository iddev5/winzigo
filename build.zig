const std = @import("std");
const builtin = @import("builtin");

const examples = .{
    "events",
    "window",
    "input",
    "wasm",
};

const web_install_dir = std.build.InstallDir{ .custom = "www" };

fn getRoot() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub fn createApplication(b: *std.build.Builder, name: []const u8, path: []const u8, target: std.zig.CrossTarget) *std.build.LibExeObjStep {
    const lib = std.build.Pkg{
        .name = "winzigo",
        .path = .{ .path = "src/main.zig" },
    };

    if (target.toTarget().cpu.arch == .wasm32) {
        const application = b.addSharedLibrary("application", "src/mains/wasm.zig/", .unversioned);
        application.setTarget(target);
        application.addPackage(.{
            .name = "app",
            .path = .{ .path = path },
            .dependencies = &.{lib},
        });
        application.install();
        application.install_step.?.dest_dir = web_install_dir;

        const install_winzigo_js = b.addInstallFileWithDir(
            .{ .path = getRoot() ++ "/src/wasm/winzigo.js" },
            web_install_dir,
            "winzigo.js",
        );
        application.install_step.?.step.dependOn(&install_winzigo_js.step);

        const install_template_html = b.addInstallFileWithDir(
            .{ .path = getRoot() ++ "/www/template.html" },
            web_install_dir,
            "application.html",
        );
        application.install_step.?.step.dependOn(&install_template_html.step);

        return application;
    } else {
        const application = b.addExecutable(name, "src/mains/native.zig");
        application.setTarget(target);
        application.linkLibC();
        application.linkSystemLibrary("xcb");
        application.addPackage(.{
            .name = "app",
            .path = .{ .path = path },
            .dependencies = &.{lib},
        });
        application.install();

        return application;
    }
}

pub fn build(b: *std.build.Builder) void {
    const is_wasm = b.option(bool, "wasm", "Equivalent to -Dtarget=wasm32-freestanding-none") orelse false;

    const target = if (is_wasm) std.zig.CrossTarget{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .abi = .none,
    } else b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const no_serve = b.option(bool, "no-serve", "Do not serve with http server (WASM-only)") orelse false;
    const no_launch = b.option(bool, "no-launch", "Do not launch the browser (WASM-only)") orelse false;

    inline for (examples) |eg| {
        const example = createApplication(b, eg, "examples/" ++ eg ++ ".zig", target);
        example.setBuildMode(mode);

        const make_step = b.step("make-" ++ eg, "Build the " ++ eg ++ " example");
        make_step.dependOn(&example.install_step.?.step);

        if (target.toTarget().cpu.arch == .wasm32) {
            const http_server = b.addExecutable("http-server", "tools/http-server.zig");
            http_server.addPackage(.{
                .name = "apple_pie",
                .path = .{ .path = "deps/apple_pie/src/apple_pie.zig" },
            });

            const launch = b.addSystemCommand(&.{
                switch (builtin.os.tag) {
                    .macos, .windows => "open",
                    else => "xdg-open", // Assume linux-like
                },
                "http://127.0.0.1:8000/application.html",
            });
            launch.step.dependOn(&example.install_step.?.step);

            const serve = http_server.run();
            serve.addArg("application");
            if (no_launch) {
                serve.step.dependOn(&example.install_step.?.step);
            } else {
                serve.step.dependOn(&launch.step);
            }
            serve.cwd = b.getInstallPath(web_install_dir, "");

            const run_step = b.step("run-" ++ eg, "Run the " ++ eg ++ "example");
            if (no_serve) {
                run_step.dependOn(&example.install_step.?.step);
            } else {
                run_step.dependOn(&serve.step);
            }
        } else {
            const run_cmd = example.run();
            run_cmd.step.dependOn(&example.install_step.?.step);
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_step = b.step("run-" ++ eg, "Run the " ++ eg ++ " example");
            run_step.dependOn(&run_cmd.step);
        }
    }
}
