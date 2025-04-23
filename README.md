# Zeroevict

An implementation of LFU Cache in O(1) for get, put, evict. This is inspired from the paper: [An O(1) algorithm for implementing the LFU cache eviction scheme](https://arxiv.org/abs/2110.11602#)

Implementation:
- [x] Setup data structures
- [x] Setup CLI
- [x] Setup the functions
    - [x] get method
    - [x] put method
    - [x] increase frequency method
    - [x] evict method
- [ ] Persist the cache data in disk or somewhere because data is lost after the program terminates
- [ ] Add tests

### Features

- O(1) time complexity for get and put.
- Evicts the least frequently used item when the cache is full.
- Implements LFU using a doubly linked list and hash map.

### Installation
```sh
zig fetch --save git+https://github.com/zokhcat/zeroevict
```
build.zig
```
    const zeroevict = b.dependency("zeroevict", .{
        .target = target,
        .optimize = optimize,
    });
 
    exe.root_module.addImport("zeroevict", clap.module("zeroevict"));
```
build.zig.zon
```
.dependencies = .{
        .@"zeroevict" = .{
            // zig fetch --save git+https://github.com/zokhcat/zeroevict
            .url = "https://github.com/zokhcat/zeroevict/archive/refs/tags/0.0.1.tar.gz",
            .hash = "122088ae1fc585b9f617c5fe9545acae35bce6c43e1eb7cd83172628804dca519753",
        },
    },
```

### Usage

```zig
const std = @import("std");
const zeroevict = @import("zeroevict");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Create an LFU cache with capacity 2
    var cache = try zeroevict.LFUCache([]const u8, []const u8).init(allocator, 2);

    try cache.put("a", "apple");
    try cache.put("b", "banana");

    const val1 = try cache.get("a");
    std.debug.print("Get a: {}\n", .{val1});

    try cache.put("c", "cherry"); // This will evict "b" as it's least frequently used

    if (cache.get("b")) |_| {
        std.debug.print("Should not reach here\n", .{});
    } else {
        std.debug.print("Key 'b' was evicted\n", .{});
    }

    const val2 = try cache.get("c");
    std.debug.print("Get c: {}\n", .{val2});
}
```
#### CLI

To run the LFU cache with the CLI:

```sh
zig run main.zig -- <command> <args>
```
#### Available Commands

-   cache

    - put: Put key-value pair in the cache.

    - get: Get value for a given key.

-   Examples

- Put value:
```sh
zig run main.zig -- put key1 value1
```
- Get value:
```sh
zig run main.zig --  get key1
```