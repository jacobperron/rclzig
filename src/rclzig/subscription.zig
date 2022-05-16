// Copyright 2022 Jacob Perron
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

pub const MessageInfo = struct {
    rmw_message_info: rcl.rmw_message_info_t,

    pub fn init() MessageInfo {
        return MessageInfo{
            .rmw_message_info = rcl.rmw_get_zero_initialized_message_info(),
        };
    }
};

pub const SubscriptionOptions = struct {
    rcl_options: rcl.rcl_subscription_options_t,
    rcl_allocator: *RclAllocator,

    pub fn init(allocator: *RclAllocator) SubscriptionOptions {
        var subscription_options = SubscriptionOptions{
            .rcl_options = rcl.rcl_subscription_get_default_options(),
            .rcl_allocator = allocator,
        };
        subscription_options.rcl_options.allocator = allocator.c_allocator;

        return subscription_options;
    }
};

pub fn Subscription(comptime MsgType: type) type {
    return struct {
        rcl_subscription: rcl.rcl_subscription_t,
        type_support: MsgType,
        options: SubscriptionOptions,

        const Self = @This();

        pub fn init(node: Node, topic_name: []const u8, options: SubscriptionOptions) !Self {
            var subscription = Self{
                .rcl_subscription = rcl.rcl_get_zero_initialized_subscription(),
                .type_support = try MsgType.init(options.rcl_allocator.zig_allocator),
                .options = options,
            };
            const init_ret = rcl.rcl_subscription_init(&subscription.rcl_subscription, &node.rcl_node, @ptrToInt(subscription.type_support.rcl_type_support), @ptrToInt(topic_name.ptr), &options.rcl_options);
            if (init_ret != rcl.RCL_RET_OK) {
                return fromRclError(init_ret);
            }
            return subscription;
        }

        pub fn deinit(self: *Self, node: *Node) void {
            self.type_support.deinit();
            const fini_ret = rcl.rcl_subscription_fini(&self.rcl_subscription, &node.rcl_node);
            if (fini_ret != rcl.RCL_RET_OK) {
                std.log.err("failed to finalize rcl_subscription_t ({})\n", .{fini_ret});
            }
        }

        pub fn take(self: *Self, message_info: *MessageInfo) !?MsgType {
            var message: MsgType = try MsgType.init(self.options.rcl_allocator.zig_allocator);
            const ret = rcl.rcl_take(&self.rcl_subscription, message.rcl_message, &message_info.rmw_message_info, 0);

            if (ret == rcl.RCL_RET_SUBSCRIPTION_TAKE_FAILED) {
                message.deinit();
                return null;
            }
            if (ret != rcl.RCL_RET_OK) {
                message.deinit();
                return fromRclError(ret);
            }

            return message;
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

    // Initialize Subscription
    var subscription_options = SubscriptionOptions.init(rcl_allocator);
    var subscription = try Subscription(std_msgs.msg.String).init(node, "chatter", subscription_options);
    defer subscription.deinit(&node);

    // Take
    var msg_info = MessageInfo.init();
    var msg_opt: ?std_msgs.msg.String = try subscription.take(&msg_info);
    try std.testing.expectEqual(msg_opt, null);

    // Shutdown Context
    try context.shutdown();
}
