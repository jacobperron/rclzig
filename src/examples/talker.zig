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

const rcl = @import("rclzig");

pub fn main() anyerror!void {
    std.log.info("Start rclzig talker", .{});

    // Initialize zig allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    // Initialize rcl allocator (using zig allocator)
    var rcl_allocator = try rcl.RclAllocator.init(allocator);
    defer rcl_allocator.deinit();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    // Initialize Context
    var context_options = try rcl.ContextOptions.init(rcl_allocator);
    defer context_options.deinit();
    var context = try rcl.Context.init(argv, context_options);
    defer context.deinit();

    // Initialize Node
    var node_options = rcl.NodeOptions.init(rcl_allocator);
    defer node_options.deinit();
    var node = try rcl.Node.init("talker", "", &context, node_options);
    defer node.deinit();

    // Create publisher
    // TODO

    // Start publishing
    // TODO

    // Shutdown Context
    try context.shutdown();
}
