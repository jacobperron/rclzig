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
const std_msgs = @import("std_msgs");

pub fn main() anyerror!void {
    std.log.info("Start rclzig talker\n", .{});

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
    var publisher_options = rcl.PublisherOptions.init(rcl_allocator);
    var publisher = try rcl.Publisher(std_msgs.msg.String).init(node, "chatter", publisher_options);
    defer publisher.deinit(&node);

    // Create a message to publish
    var message = try std_msgs.msg.String.init(allocator);
    defer message.deinit();
    try message.setData("Hello world");

    // Start publishing
    var timer = try std.time.Timer.start();
    const publish_period: u64 = 1e9;
    while (true) {
        const time_since_publish: u64 = timer.read();
        if (time_since_publish >= publish_period) {
            std.log.info("Publishing message\n", .{});
            publisher.publish(message);
            timer.reset();
            continue;
        }
        std.time.sleep(publish_period - time_since_publish);
    }

    // Shutdown Context
    try context.shutdown();
}
