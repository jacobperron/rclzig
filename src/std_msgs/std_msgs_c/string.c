#include "include/std_msgs_c/string.h"

rosidl_message_type_support_t *
rosidl_get_msg_type_support(
    const char * pkg_name,
    const char * subdir,
    const char * msg_name)
{
  return ROSIDL_GET_MSG_TYPE_SUPPORT(pkg_name, sudir, msg_name);
}

