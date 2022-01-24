const std = @import("std");

pub const c = @cImport({
    @cInclude("std_msgs/msg/string.h");
});

pub const String = struct {
    rcl_type_support: *const c.rosidl_message_type_support_t,
    rcl_message: *c.std_msgs__msg__String,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) !String {
        var message: String = .{
            // We can't call ROSIDL_GET_MSG_TYPE_SUPPORT because zig cannot translate the macro
            .rcl_type_support = c.rosidl_typesupport_c__get_message_type_support_handle__std_msgs__msg__String(),
            .rcl_message = try allocator.create(c.std_msgs__msg__String),
            .allocator = allocator,
        };
        // Avoiding std_msgs__msg__String__init since it allocates memory with 'malloc'
        message.rcl_message.data.data = (try allocator.alloc(u8, 1)).ptr;
        message.rcl_message.data.data[0] = 0;
        message.rcl_message.data.size = 0;
        message.rcl_message.data.capacity = 1;
        return message;
    }

    pub fn deinit(self: *String) void {
        var zig_pointer = @ptrCast([*]u8, self.rcl_message.data.data);
        const capacity = self.rcl_message.data.capacity;
        self.allocator.free(zig_pointer[0..capacity]);
        self.allocator.destroy(self.rcl_message);
    }

    pub fn setData(self: *String, data: []const u8) !void {
        const capacity = self.rcl_message.data.capacity;
        if (data.len >= capacity) {
            var zig_pointer = @ptrCast([*]u8, self.rcl_message.data.data);
            var new_ptr = try self.allocator.realloc(zig_pointer[0..capacity], data.len + 1);
            self.rcl_message.data.data = new_ptr.ptr;
            self.rcl_message.data.capacity = data.len + 1;
        }
        std.mem.copy(u8, self.rcl_message.data.data[0..data.len], data);
        self.rcl_message.data.size = data.len;
        self.rcl_message.data.data[data.len] = 0;
    }

    pub fn getData(self: *String) []const u8 {
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

    try my_msg.setData("");
    data = my_msg.getData();
    try std.testing.expectEqualStrings(data, "");
}
