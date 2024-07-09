const std = @import("std");
const builtin = @import("builtin");

pub const Mode = enum { app, direct };

const Example = struct {
    name: []const u8,
    mode: Mode = .app,
};

const examples = &[_]Example{
    .{ .name = "events" },
    .{ .name = "window" },
    .{ .name = "input", .mode = .direct },
};

const web_install_dir = std.build.InstallDir{ .custom = "www" };

fn getRoot() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub fn createApplication(b: *std.Build, name: []const u8, path: []const u8, mode: Mode, target: std.Build.ResolvedTarget) *std.Build.Step.Compile {
    const lib = b.addModule("winzigo", .{
        .root_source_file = b.path("src/main.zig"),
    });

    if (mode == .direct) {
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(path),
            .target = target,
        });

        exe.linkLibC();
        exe.root_module.addImport("winzigo", lib);
        b.installArtifact(exe);

        return exe;
    }

    const app = b.addModule("app", .{
        .root_source_file = b.path(path),
    });
    app.addImport("winzigo", lib);

    const application = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path("src/mains/native.zig"),
        .target = target,
    });

    application.linkLibC();
    application.root_module.addImport("app", app);
    b.installArtifact(application);

    return application;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    inline for (examples) |eg| {
        const example = createApplication(b, eg.name, "examples/" ++ eg.name ++ ".zig", eg.mode, target);

        const make_step = b.step("make-" ++ eg.name, "Build the " ++ eg.name ++ " example");
        make_step.dependOn(b.getInstallStep());

        const run_cmd = b.addRunArtifact(example);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run-" ++ eg.name, "Run the " ++ eg.name ++ " example");
        run_step.dependOn(&run_cmd.step);
    }
}
