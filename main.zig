const std = @import("std");

const screen_width = 160;
const screen_height = 44;
const buffer_size = screen_width * screen_height;

var A: f32 = 0;
var B: f32 = 0;
var C: f32 = 0;

var zBuffer: [buffer_size]f32 = undefined;
var buffer: [buffer_size]u8 = undefined;

const distance_from_cam = 100.0;
const K1: f32 = 40.0;
const cube_width: f32 = 20.0;
const increment_speed: f32 = 0.4;

fn calculateX(i: f32, j: f32, k: f32) f32 {
    return j * @sin(A) * @sin(B) * @cos(C) - k * @cos(A) * @sin(B) * @cos(C) + j * @cos(A) * @sin(C) + k * @sin(A) * @sin(C) + i * @cos(B) * @cos(C);
}

fn calculateY(i: f32, j: f32, k: f32) f32 {
    return j * @cos(A) * @cos(C) + k * @sin(A) * @cos(C) - j * @sin(A) * @sin(B) * @sin(C) + k * @cos(A) * @sin(B) * @sin(C) - i * @cos(B) * @sin(C);
}

fn calculateZ(i: f32, j: f32, k: f32) f32 {
    return k * @cos(A) * @cos(B) - j * @sin(A) * @cos(B) + i * @sin(B);
}

fn plot(i: f32, j: f32, k: f32, ch: u8) void {
    const x = calculateX(i, j, k);
    const y = calculateY(i, j, k);
    const z = calculateZ(i, j, k) + distance_from_cam;

    const ooz = 1 / z;

    const xp: usize = @intFromFloat(@floor(screen_width / 2 + K1 * ooz * x * 2));
    const yp: usize = @intFromFloat(@floor(screen_height / 2 + K1 * ooz * y));

    const idx = xp + yp * screen_width;

    if (xp < screen_width and yp < screen_height and idx < buffer_size) {
        if (ooz > zBuffer[idx]) {
            zBuffer[idx] = ooz;
            buffer[idx] = ch;
        }
    }
}

fn putchar(c: u8) !void {
    const stdout = std.fs.File.stdin().deprecatedWriter();
    try stdout.writeByte(c);
}

pub fn main() !void {
    const stdout = std.fs.File.stdin().deprecatedWriter();
    try stdout.writeAll("\x1b[J");
    try stdout.writeAll("\x1b[?25l");
    while (true) {
        for (&buffer) |*b| b.* = ' ';
        for (&zBuffer) |*z| z.* = 0;
        var cubeX: f32 = -cube_width;
        while (cubeX < cube_width) : (cubeX += increment_speed) {
            var cubeY: f32 = -cube_width;
            while (cubeY < cube_width) : (cubeY += increment_speed) {
                plot(cubeX, cubeY, -cube_width, '@');
                plot(cube_width, cubeY, cubeX, '$');
                plot(-cube_width, cubeY, -cubeX, '~');
                plot(-cubeX, cubeY, cube_width, '#');
                plot(cubeX, -cube_width, -cubeY, ';');
                plot(cubeX, cube_width, cubeY, '+');
            }
        }

        try stdout.writeAll("\x1b[H");
        for (buffer, 0..) |ch, i| {
            if (i % screen_width == 0 and i != 0)
                try putchar('\n');
            try putchar(ch);
        }

        A += 0.04;
        B += 0.02;
        C += 0.01;
        std.Thread.sleep(16000);
    }
}
