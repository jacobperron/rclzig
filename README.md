# rclzig

A [ROS 2](https://docs.ros.org/en/rolling/index.html) client library in the [Zig programming language](https://ziglang.org/).

## Features

* TODO 

## Why?

This project was created as a personal way to learn Zig.
I was intrigued by the features Zig has to offer (e.g. simple, zero-dependency drop-in replacement for C/C++, cross-compilation out-of-the-box).
As an exercise, I challenged myself to integrate the language with ROS 2 and this is the result.

## Should I use this in production?

No, probably not.

Zig is a very young language (still pre-1.0 release) and not stable.
The same applies for rclzig.

## Okay, how can I use rclzig?

### Install dependencies

* [Install ROS 2](https://docs.ros.org/en/rolling/Installation.html).
* [Install Zig](https://ziglang.org/download/)

### Build

1. Clone this repository

        git clone https://github.com/jacobperron/rclzig.git

1. Source your ROS 2 installation, e.g. ROS Galactic:

        source /opt/ros/galactic/setup.bash

1. Build:

        cd rclzig
        zig build

1. Optionally, run tests:

        zig build test

### Try the examples

Run the talker:

    zig build talker

In a second shell, run the listener:

    zig build listener

### Build your own package

TODO

## Excellent! How can I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md).

## References

Here are some nice resource for learning Zig:

* [ziglearn.org](https://ziglearn.org/) is a good starting place.
* [Zig's "In-depth overview"](https://ziglang.org/learn/overview/) supplements ziglearn.org very well.
* [Zig API reference](https://ziglang.org/documentation/master)
* These ["zig build explained"](https://zig.news/xq/zig-build-explained-part-1-59lf) blog posts provide good info about the build system.
  Part 2 demonstrates how to build C/C++ code from zig.
* Jumping straight into the [source code for Zig](https://github.com/ziglang/zig) can also be enlightening.
