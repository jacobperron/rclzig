const std = @import("std");
const c = @import("c.zig");
const std_msgs = @import("std_msgs.zig");
const rcl = @import("rclzig");

test {
    _ = c;
    // _ = std_msgs.msg.String;
}

// test "create a string publisher" {
//     var rcl_allocator = try rcl.RclAllocator.init(std.testing.allocator);
//     defer rcl_allocator.deinit();
//
//     // Initialize Context
//     const argv = [_][]const u8{};
//     var context_options = try rcl.ContextOptions.init(rcl_allocator);
//     defer context_options.deinit();
//     var context = try rcl.Context.init(&argv, context_options);
//     defer context.deinit();
//
//     // Initialize Node
//     var node_options = rcl.NodeOptions.init(rcl_allocator);
//     defer node_options.deinit();
//     var node_name: []const u8 = "bar";
//     var node_namespace: []const u8 = "foo";
//     var node = try rcl.Node.init(node_name, node_namespace, &context, node_options);
//     defer node.deinit();
//
//     // Initialize Publisher
//     var publisher_options = rcl.PublisherOptions.init(rcl_allocator);
//     defer publisher_options.deinit();
//     const String = std_msgs.msg.String;
//     var topic_name: []const u8 = "chatter";
//     var publisher = try rcl.Publisher(String).init(node, topic_name, publisher_options);
//     defer publisher.deinit(node);
//
//     // Shutdown Context
//     try context.shutdown();
// }
