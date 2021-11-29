const c = @import("c.zig");

pub const String = struct {
    rcl_type_support: *c.rosidl_message_type_support_t,

    pub fn init() String {
        return .{
            .rcl_type_support = c.ROSIDL_GET_MSG_TYPE_SUPPORT("std_msgs", "msg", "String"),
        };
    }
};
