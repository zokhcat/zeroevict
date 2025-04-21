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

### Usage

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