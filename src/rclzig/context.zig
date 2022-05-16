// Copyright 2021 Jacob Perron
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");

const rcl = @import("rcl.zig").rcl;

const RclAllocator = @import("allocator.zig").RclAllocator;
const fromRclError = @import("errors.zig").fromRclError;

pub const ContextOptions = struct {
    rcl_options: rcl.rcl_init_options_t,

    pub fn init(allocator: *RclAllocator) !ContextOptions {
        var context_options = ContextOptions{
            .rcl_options = rcl.rcl_get_zero_initialized_init_options(),
        };
        const init_ret = rcl.rcl_init_options_init(&context_options.rcl_options, allocator.c_allocator);

        if (init_ret != rcl.RCL_RET_OK) {
            std.log.err("failed to initialize options\n", .{});
            return fromRclError(init_ret);
        }
        return context_options;
    }

    pub fn deinit(self: *ContextOptions) void {
        const fini_ret = rcl.rcl_init_options_fini(&self.rcl_options);
        if (fini_ret != rcl.RCL_RET_OK) {
            std.log.err("failed to finalize rcl_init_options_t ({})\n", .{fini_ret});
        }
    }
};

pub const Context = struct {
    rcl_context: rcl.rcl_context_t,

    pub fn init(argv: []const []const u8, options: ContextOptions) !Context {
        var context = Context{
            .rcl_context = rcl.rcl_get_zero_initialized_context(),
        };
        const rcl_ret = rcl.rcl_init(@intCast(c_int, argv.len), @ptrToInt(argv.ptr), &options.rcl_options, &context.rcl_context);
        if (rcl_ret != rcl.RCL_RET_OK) {
            return fromRclError(rcl_ret);
        }
        return context;
    }

    pub fn deinit(self: *Context) void {
        if (self.ok()) {
            self.shutdown() catch |err| {
                std.log.err("failed to shutdown context in deinit: {}\n", .{err});
            };
        }
        const fini_ret = rcl.rcl_context_fini(&self.rcl_context);
        if (fini_ret != rcl.RCL_RET_OK) {
            // Should not happen unless there's a bug in rcl
            std.log.err("failed to finalize rcl_context_t ({})\n", .{fini_ret});
        }
    }

    pub fn shutdown(self: *Context) !void {
        const rcl_ret = rcl.rcl_shutdown(&self.rcl_context);
        if (rcl_ret != rcl.RCL_RET_OK) {
            return fromRclError(rcl_ret);
        }
    }

    pub fn ok(self: *Context) bool {
        return rcl.rcl_context_is_valid(&self.rcl_context);
    }
};

test "check for memory leaks" {
    var rcl_allocator = try RclAllocator.init(std.testing.allocator);
    defer rcl_allocator.deinit();

    const argv = [_][]const u8{};
    var context_options = try ContextOptions.init(rcl_allocator);
    defer context_options.deinit();
    var context = try Context.init(&argv, context_options);

    // implicit shutdown expected
    context.deinit();
    try std.testing.expect(!context.ok());
}

test "init shutdown cycle" {
    var rcl_allocator = try RclAllocator.init(std.testing.allocator);
    defer rcl_allocator.deinit();

    const argv = [_][]const u8{};
    var context_options = try ContextOptions.init(rcl_allocator);
    defer context_options.deinit();
    var context = try Context.init(&argv, context_options);
    defer context.deinit();

    try std.testing.expect(context.ok());
    try context.shutdown();
    try std.testing.expect(!context.ok());
}
