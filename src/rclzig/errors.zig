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

const rcl = @import("rcl.zig").rcl;

// Possible rcl error codes
// Defined here: https://github.com/ros2/rcl/blob/master/rcl/include/rcl/types.h
pub const RclzigError = RmwError || RclError || NodeError || PublisherError || SubscriptionError || ClientError || ServiceError || TimerError || WaitSetError || ArgumentError || EventError || LifecycleStateError;

pub const RmwError = error{
    Unspecified,
    Timeout,
    BadAlloc,
    ArgumentInvalid,
    Unsupported,
};

pub const RclError = error{
    AlreadyInit,
    NotInit,
    MismatchedRmwId,
    TopicNameInvalid,
    ServiceNameInvalid,
    UnknownSubstitution,
    AlreadyShutdown,
};

pub const NodeError = error{
    NodeInvalid,
    NodeNameInvalid,
    NodeNamespaceInvalid,
    NodeNameNonExistent,
};

pub const PublisherError = error{
    PublisherInvalid,
};

pub const SubscriptionError = error{
    SubscriptionInvalid,
    SubscriptionTakeFailed,
};

pub const ClientError = error{
    ClientInvalid,
    ClientTakeFailed,
};

pub const ServiceError = error{
    ServiceInvalid,
    ServiceTakeFailed,
};

pub const TimerError = error{
    TimerInvalid,
    TimerCanceled,
};

pub const WaitSetError = error{
    WaitSetInvalid,
    WaitSetEmpty,
    WaitSetFull,
};

pub const ArgumentError = error{
    RemapRuleInvalid,
    WrongLexeme,
    RosArgumentInvalid,
    ParamRuleInvalid,
    LogLevelRuleInvalid,
};

pub const EventError = error{
    EventInvalid,
    EventTakeFailed,
};

pub const LifecycleStateError = error{
    LifecycleStateRegistered,
    LifecycleStateNotRegistered,
};

pub fn fromRclError(rcl_ret: i32) RclzigError {
    return switch (rcl_ret) {
        rcl.RCL_RET_TIMEOUT => RclzigError.Timeout,
        rcl.RCL_RET_BAD_ALLOC => RclzigError.BadAlloc,
        rcl.RCL_RET_INVALID_ARGUMENT => RclzigError.ArgumentInvalid,
        rcl.RCL_RET_UNSUPPORTED => RclzigError.Unsupported,
        rcl.RCL_RET_ALREADY_INIT => RclzigError.AlreadyInit,
        rcl.RCL_RET_NOT_INIT => RclzigError.NotInit,
        rcl.RCL_RET_MISMATCHED_RMW_ID => RclzigError.MismatchedRmwId,
        rcl.RCL_RET_TOPIC_NAME_INVALID => RclzigError.TopicNameInvalid,
        rcl.RCL_RET_SERVICE_NAME_INVALID => RclzigError.ServiceNameInvalid,
        rcl.RCL_RET_UNKNOWN_SUBSTITUTION => RclzigError.UnknownSubstitution,
        rcl.RCL_RET_ALREADY_SHUTDOWN => RclzigError.AlreadyShutdown,
        rcl.RCL_RET_NODE_INVALID => RclzigError.NodeInvalid,
        rcl.RCL_RET_NODE_INVALID_NAME => RclzigError.NodeNameInvalid,
        rcl.RCL_RET_NODE_INVALID_NAMESPACE => RclzigError.NodeNamespaceInvalid,
        rcl.RCL_RET_NODE_NAME_NON_EXISTENT => RclzigError.NodeNameNonExistent,
        rcl.RCL_RET_PUBLISHER_INVALID => RclzigError.PublisherInvalid,
        rcl.RCL_RET_SUBSCRIPTION_INVALID => RclzigError.SubscriptionInvalid,
        rcl.RCL_RET_SUBSCRIPTION_TAKE_FAILED => RclzigError.SubscriptionTakeFailed,
        rcl.RCL_RET_CLIENT_INVALID => RclzigError.ClientInvalid,
        rcl.RCL_RET_CLIENT_TAKE_FAILED => RclzigError.ClientTakeFailed,
        rcl.RCL_RET_SERVICE_INVALID => RclzigError.ServiceInvalid,
        rcl.RCL_RET_SERVICE_TAKE_FAILED => RclzigError.ServiceTakeFailed,
        rcl.RCL_RET_TIMER_INVALID => RclzigError.TimerInvalid,
        rcl.RCL_RET_TIMER_CANCELED => RclzigError.TimerCanceled,
        rcl.RCL_RET_WAIT_SET_INVALID => RclzigError.WaitSetInvalid,
        rcl.RCL_RET_WAIT_SET_EMPTY => RclzigError.WaitSetEmpty,
        rcl.RCL_RET_WAIT_SET_FULL => RclzigError.WaitSetFull,
        rcl.RCL_RET_INVALID_REMAP_RULE => RclzigError.RemapRuleInvalid,
        rcl.RCL_RET_WRONG_LEXEME => RclzigError.WrongLexeme,
        rcl.RCL_RET_INVALID_ROS_ARGS => RclzigError.RosArgumentInvalid,
        rcl.RCL_RET_INVALID_PARAM_RULE => RclzigError.ParamRuleInvalid,
        rcl.RCL_RET_INVALID_LOG_LEVEL_RULE => RclzigError.LogLevelRuleInvalid,
        rcl.RCL_RET_EVENT_INVALID => RclzigError.EventInvalid,
        rcl.RCL_RET_EVENT_TAKE_FAILED => RclzigError.EventTakeFailed,
        // rcl.RCL_RET_LIFECYCLE_STATE_REGISTERED => RclzigError.LifecycleStateRegistered,
        // rcl.RCL_RET_LIFECYCLE_STATE_NOT_REGISTERED => RclzigError.LifecycleStateNotRegistered,
        rcl.RCL_RET_ERROR => RclzigError.Unspecified,
        else => RclzigError.Unspecified,
    };
}
