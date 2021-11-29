const std = @import("std");

pub const c = @cImport({
    @cInclude("std_msgs/msg/string.h");
    @cInclude("rosidl_runtime_c/string_functions.h");
});

pub const String = struct {
    rcl_type_support: *const c.rosidl_message_type_support_t,
    rcl_message: *c.std_msgs__msg__String,

    pub fn init(allocator: *std.mem.Allocator) !String {
        // TODO(jacobperron): Use allocator to initialize message when it is available
        //                    https://github.com/ros2/rosidl/issues/306
        _ = allocator;
        var rcl_message = c.std_msgs__msg__String__create();
        var message: String = .{
            // We can't call ROSIDL_GET_MSG_TYPE_SUPPORT because zig cannot translate the macro
            .rcl_type_support = c.rosidl_typesupport_c__get_message_type_support_handle__std_msgs__msg__String(),
            .rcl_message = rcl_message,
        };
        return message;
    }

    pub fn deinit(self: *String) void {
        c.std_msgs__msg__String__destroy(self.rcl_message);
    }

    pub fn setData(self: *String, data: []const u8) !void {
        const success = c.rosidl_runtime_c__String__assign(&self.rcl_message.data, @ptrToInt(data.ptr));
        if (!success) {
            // TODO(jacobperron): return error
        }
    }

    pub fn getData(self: String) []const u8 {
        return self.rcl_message.data.data[0..self.rcl_message.data.size];
    }
};

test "init/deinit" {
    var my_msg: String = try String.init(std.testing.allocator);
    defer my_msg.deinit();
    _ = my_msg;
}

test "set/get" {
    var my_msg: String = try String.init(std.testing.allocator);
    defer my_msg.deinit();

    try my_msg.setData("foobar");
    var data: []const u8 = my_msg.getData();
    try std.testing.expectEqualStrings(data, "foobar");

    try my_msg.setData("Hello World: 42");
    data = my_msg.getData();
    try std.testing.expectEqualStrings(data, "Hello World: 42");

    try my_msg.setData("");
    data = my_msg.getData();
    try std.testing.expectEqualStrings(data, "");
}
