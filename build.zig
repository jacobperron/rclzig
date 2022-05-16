const std = @import("std");

/// Link a single ament C package.
fn amentTargetCDependencies(allocator: *std.mem.Allocator, exe: *std.build.LibExeObjStep, package_names: []const []const u8) void {
    _ = allocator;

    const ament_env = std.os.getenv("AMENT_PREFIX_PATH");
    if (ament_env) |ament_prefix| {
        var ament_prefix_iterator = std.mem.tokenize(u8, ament_prefix, ":");
        while (ament_prefix_iterator.next()) |prefix| {
            // TODO(jacobperron): This assumption is wrong if packages install their headers to a subdirectory
            const include_dir = std.fmt.allocPrint(allocator, "{s}/include", .{prefix}) catch |err| {
                std.log.err("{e}\n", .{err});
                return;
            };
            defer allocator.free(include_dir);
            exe.addIncludeDir(include_dir);

            const lib_dir = std.fmt.allocPrint(allocator, "{s}/lib", .{prefix}) catch |err| {
                std.log.err("{e}\n", .{err});
                return;
            };
            defer allocator.free(lib_dir);
            exe.addLibPath(lib_dir);
        }
    } else {
        std.log.warn("AMENT_PREFIX_PATH is not set\n", .{});
    }

    exe.linkSystemLibrary("c");

    for (package_names) |package_name| {
        exe.linkSystemLibraryName(package_name);
    }
}

pub fn build(b: *std.build.Builder) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const rcl_dependencies = [_][]const u8{
        "rcl",
        "rcutils",
        "rmw",
    };
    const std_msgs_dependencies = [_][]const u8{
        "std_msgs__rosidl_typesupport_c",
        "std_msgs__rosidl_generator_c",
        "rosidl_runtime_c",
    };

    const rclzig_pkg = std.build.Pkg{
        .name = "rclzig",
        .path = .{ .path = "./src/rclzig/rclzig.zig" },
    };
    const std_msgs_pkg = std.build.Pkg{
        .name = "std_msgs",
        .path = .{ .path = "./src/std_msgs/std_msgs.zig" },
    };

    const std_msgs_lib = b.addStaticLibrary("std_msgs", "src/std_msgs/std_msgs.zig");
    std_msgs_lib.setBuildMode(mode);
    std_msgs_lib.setTarget(target);
    amentTargetCDependencies(allocator, std_msgs_lib, &std_msgs_dependencies);
    std_msgs_lib.addPackage(rclzig_pkg);
    std_msgs_lib.install();

    const std_msgs_tests = b.addTest("src/std_msgs/std_msgs.zig");
    std_msgs_tests.setBuildMode(mode);
    amentTargetCDependencies(allocator, std_msgs_tests, &std_msgs_dependencies);

    const rclzig_lib = b.addStaticLibrary("rclzig", "src/rclzig/rclzig.zig");
    rclzig_lib.setBuildMode(mode);
    rclzig_lib.setTarget(target);
    amentTargetCDependencies(allocator, rclzig_lib, &rcl_dependencies);
    rclzig_lib.install();

    const rclzig_tests = b.addTest("src/rclzig/rclzig.zig");
    rclzig_tests.setBuildMode(mode);
    amentTargetCDependencies(allocator, rclzig_tests, &rcl_dependencies);
    amentTargetCDependencies(allocator, rclzig_tests, &std_msgs_dependencies);
    rclzig_tests.addPackage(std_msgs_pkg);

    const talker_exe = b.addExecutable("talker", "src/examples/talker.zig");
    talker_exe.setTarget(target);
    talker_exe.setBuildMode(mode);
    talker_exe.addPackage(rclzig_pkg);
    talker_exe.addPackage(std_msgs_pkg);

    amentTargetCDependencies(allocator, talker_exe, &rcl_dependencies);
    amentTargetCDependencies(allocator, talker_exe, &std_msgs_dependencies);
    talker_exe.install();
    const talker_cmd = talker_exe.run();
    talker_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        talker_cmd.addArgs(args);
    }
    const talker_step = b.step("talker", "Run the talker example");
    talker_step.dependOn(&talker_cmd.step);

    const listener_exe = b.addExecutable("listener", "src/examples/listener.zig");
    listener_exe.setTarget(target);
    listener_exe.setBuildMode(mode);
    listener_exe.addPackage(rclzig_pkg);
    listener_exe.addPackage(std_msgs_pkg);
    amentTargetCDependencies(allocator, listener_exe, &rcl_dependencies);
    amentTargetCDependencies(allocator, listener_exe, &std_msgs_dependencies);
    listener_exe.install();
    const listener_cmd = listener_exe.run();
    listener_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        listener_cmd.addArgs(args);
    }
    const listener_step = b.step("listener", "Run the listener example");
    listener_step.dependOn(&listener_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&rclzig_tests.step);
    test_step.dependOn(&std_msgs_tests.step);
}
