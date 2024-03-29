const std = @import("std");

const writer = std.io.getStdOut().writer();

const WIDTH = 50;
const HEIGHT = 25;
const ROAD = 0;
const WALL = 1;

var map: [WIDTH][HEIGHT]u32 = undefined;

const dir = struct {
    x: i32,
    y: i32,
};

const UP: dir = .{ .x = 0, .y = -1 };
const DOWN: dir = .{ .x = 0, .y = 1 };
const LEFT: dir = .{ .x = -1, .y = 0 };
const RIGHT: dir = .{ .x = 1, .y = 0 };

const dirs = [_]dir{ UP, DOWN, LEFT, RIGHT };

fn rand_i32() !i32 {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    const a = rand.int(i32);

    return a;
}

fn rand_odd(mod: i32) !i32 {
    const rand = try rand_i32();
    var r: i32 = 1 + @mod(rand, mod);
    if (@mod(r, 2) == 0) {
        r += 1;
    }
    if (r > mod) {
        r -= 2;
    }
    return r;
}

fn make_maze(x: i32, y: i32) !void {
    const rand = try rand_i32();
    var d: usize = @intCast(@mod(rand, 4));
    var dd: usize = d;
    while (true) {
        const px = x + dirs[dd].x * 2;
        const py = y + dirs[dd].y * 2;

        if (px < 0 or px >= WIDTH or py < 0 or py >= HEIGHT or map[@intCast(px)][@intCast(py)] != WALL) {
            d += 1;
            if (d == 4) {
                d = 0;
            }
            if (d == dd) {
                return;
            }
            continue;
        }
        map[@intCast(x + dirs[d].x)][@intCast(y + dirs[d].y)] = ROAD;
        map[@intCast(px)][@intCast(py)] = ROAD;
        try make_maze(px, py);
        const randi = try rand_i32();
        d = @intCast(@mod(randi, 4));
        dd = d;
    }
}

fn maze() !void {
    const x: i32 = try rand_odd(WIDTH - 2);
    const y: i32 = try rand_odd(HEIGHT - 2);

    try writer.print("({d}, {d})\n", .{ x, y });

    try make_maze(x, y);
}

fn print() !void {
    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            var char: u8 = undefined;
            if (map[x][y] == WALL) {
                char = '#';
            } else {
                char = ' ';
            }
            try writer.print("{c}", .{(char)});
        }
        try writer.print("\n", .{});
    }
}

fn maze_init() void {
    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            map[x][y] = WALL;
        }
    }
}

pub fn main() !void {
    maze_init();
    try maze();
    try print();
}
