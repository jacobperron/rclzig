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

const Node = @import("node.zig").Node;
const RclAllocator = @import("allocator.zig").RclAllocator;
const fromRclError = @import("errors.zig").fromRclError;

pub const PublisherOptions = struct {
    rcl_options: rcl.rcl_publisher_options_t,

    pub fn init(allocator: *RclAllocator) PublisherOptions {
        var publisher_options = PublisherOptions{
            .rcl_options = rcl.rcl_publisher_get_default_options(),
        };
        publisher_options.rcl_options.allocator = allocator.c_allocator;

        return publisher_options;
    }
};

pub fn Publisher(comptime MsgType: type) type {
    return struct {
        rcl_publisher: rcl.rcl_publisher_t,
        type_support: MsgType,

        const Self = @This();

        pub fn init(node: Node, topic_name: []const u8, options: PublisherOptions) !Self {
            var publisher = Self{
                .rcl_publisher = rcl.rcl_get_zero_initialized_publisher(),
                .type_support = MsgType.init(),
            };
            const init_ret = rcl.rcl_publisher_init(&publisher.rcl_publisher, &node.rcl_node, @ptrToInt(publisher.type_support.rcl_type_support), @ptrToInt(topic_name.ptr), &options.rcl_options);
            if (init_ret != rcl.RCL_RET_OK) {
                return fromRclError(init_ret);
            }
            return publisher;
        }

        pub fn deinit(self: *Self, node: *Node) void {
            const fini_ret = rcl.rcl_publisher_fini(&self.rcl_publisher, &node.rcl_node);
            if (fini_ret != rcl.RCL_RET_OK) {
                std.log.err("failed to finalize rcl_publisher_t ({})\n", .{fini_ret});
            }
        }
    };
}

// Imports for testing
const Context = @import("context.zig").Context;
const ContextOptions = @import("context.zig").ContextOptions;
const NodeOptions = @import("node.zig").NodeOptions;
const std_msgs = @import("std_msgs");

test "check for memory leaks" {
    var rcl_allocator = try RclAllocator.init(std.testing.allocator);
    defer rcl_allocator.deinit();

    // Initialize Context
    const argv = [_][]const u8{};
    var context_options = try ContextOptions.init(rcl_allocator);
    defer context_options.deinit();
    var context = try Context.init(&argv, context_options);
    defer context.deinit();

    // Initialize Node
    var node_options = NodeOptions.init(rcl_allocator);
    defer node_options.deinit();
    var node_name: []const u8 = "bar";
    var node_namespace: []const u8 = "foo";
    var node = try Node.init(node_name, node_namespace, &context, node_options);
    defer node.deinit();

    // Initialize Publisher
    var publisher_options = PublisherOptions.init(rcl_allocator);
    var publisher = try Publisher(std_msgs.msg.String).init(node, "chatter", publisher_options);
    defer publisher.deinit(&node);

    // Shutdown Context
    try context.shutdown();
}
