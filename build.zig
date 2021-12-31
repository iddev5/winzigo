const std = @import("std");

const examples = .{
    "events",
    "window",
    "input",
    "wasm",
};

pub fn createApplication(b: *std.build.Builder, name: []const u8, path: []const u8, target: std.zig.CrossTarget) *std.build.LibExeObjStep {
    const lib = std.build.Pkg{
        .name = "winzigo",
        .path = .{ .path = "src/main.zig" },
    };

    if (target.toTarget().cpu.arch == .wasm32) {
        const application = b.addSharedLibrary(name, "src/mains/wasm.zig/", .unversioned);
        application.setTarget(target);
        application.addPackage(.{
            .name = "app",
            .path = .{ .path = path },
            .dependencies = &.{lib},
        });
        application.install();

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
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    inline for (examples) |eg| {
        const example = createApplication(b, eg, "examples/" ++ eg ++ ".zig", target);
        example.setBuildMode(mode);

        const make_step = b.step("make-" ++ eg, "Build the " ++ eg ++ " example");
        make_step.dependOn(&example.install_step.?.step);

        if (target.toTarget().cpu.arch != .wasm32) {
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
