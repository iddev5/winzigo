const std = @import("std");

const examples = .{
    "events",
    "window",
    "input",
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = std.build.Pkg{
        .name = "winzigo",
        .path = .{ .path = "src/main.zig" },
    };

    inline for (examples) |eg| {
        const example = b.addExecutable(eg, "examples/" ++ eg ++ ".zig");
        example.setTarget(target);
        example.setBuildMode(mode);
        example.linkLibC();
        example.linkSystemLibrary("xcb");
        example.addPackage(lib);
        example.install();

        const make_step = b.step("make-" ++ eg, "Build the " ++ eg ++ " example");
        make_step.dependOn(&example.install_step.?.step);

        const run_cmd = example.run();
        run_cmd.step.dependOn(&example.install_step.?.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run-" ++ eg, "Run the " ++ eg ++ " example");
        run_step.dependOn(&run_cmd.step);
    }
}
