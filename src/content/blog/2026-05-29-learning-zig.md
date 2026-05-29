---
title: 'Learning Zig'
description: 'Learning how to use zig'
pubDate: 2026-05-29 11:08:00 +0200
categories: MacOS VM, UVSCode Server, Remote SSH
slug: astro/2026-05-29-learning-zig.html
heroImage: '/zig-header.svg'
---

I have been leaning zig over the last year or so, and I have been using it for some smaller and larger projects. And i must say I'm quite impressed with the language. It's a very well designed language and it has a lot of features that make it a pleasure to use. It's one of the first languages I have used where the full standard library is available even on embedded targets and where it very easy to write cross platform code.

Here a some notes I have taken while learning zig, and some of the things I have learned along the way.

### Import

In zig when you create a new file it's "wrapped" in a struct:

MyType.zig:

```zig
const MyType = @This(); // References to the struct of MyType.zig
field1 = "Hello World";

fn doStuff(self: MyType): []u8 {
    return self.field1;
}
```

main.zig:

```zig
const MyType = @import("MyType.zig");
std.debug.print(MyType.field1);
const my_namespace = @import("my_namespace.zig");
```

### String types:

- `[:0]const`: Pointer to zero terminated string and a length. (zig "string").
- `[*:0]const u8`: Pointer to a zero terminated string (fx. what std.os.args returns an array of).
- `[]const u8`: Pointer and a length (zig slice).

```zig
const str: [:0]const u8 = "Hello World";
const strPtr: [*:0]const u8 = str.ptr;
const strSlice: []const u8 = str[0..str.len];
const strPtrToSlice: []const u8 = std.mem.span(strPtr);

// To convert from a non-zero terminated string we need to allocate so we can add the zero
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
defer _ = gpa.deinit();
const sliceToZeroTerminatedStr = try allocator.dupeZ(u8, strSlice);
```

Links:

- https://zig.guide/language-basics/sentinel-termination/
