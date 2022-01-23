pub const c = @cImport({
    @cInclude("std_msgs/msg/string.h");
});

pub const String = struct {
    rcl_type_support: *const c.rosidl_message_type_support_t,

    pub fn init() String {
        return .{
            // We can't call ROSIDL_GET_MSG_TYPE_SUPPORT because zig cannot translate the macro
            .rcl_type_support = c.rosidl_typesupport_c__get_message_type_support_handle__std_msgs__msg__String(),
        };
    }
};

test "init" {
    var my_msg: String = String.init();
    _ = my_msg;
}
