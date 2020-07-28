package scripts

import "core:fmt"
import "core:math/linalg"
import "core:strings"
import "core:math"
import ray "shared:odin-raylib"
@(private)
V2 :: linalg.Vector2;
@(private)
V4 :: linalg.Vector4;

// BLACK ::
global_font: ray.Font;

// centers text based on rune count and width
x_center :: proc(text: string, w: f32) -> f32 {
	return w / 2 - cast(f32) strings.rune_count(text) / 2 * FONT_SIZE / 2;
}

inverted_text_colors := false;
draw_string_fancy :: proc(pos: V2, text: string) {
    if !inverted_text_colors {
        draw_string(pos + { 1, 1 }, FONT_SIZE, C_BLACK, text);
    }
    
	draw_string(pos, FONT_SIZE, inverted_text_colors ? C_BLACK : C_WHITE, text);
}

ease_out_cubic :: proc(p: f32) -> f32 {
	f: f32 = (p - 1);
	return f * f * f + 1;
}

ease_out_exponential :: proc(p: f32) -> f32 {
	return (p == 1.0) ? p : 1 - math.pow(2, -10 * p);
}


draw_string :: proc(position: V2, size: i32, color: V4, format: string, args: ..any) {
	text := fmt.tprintf(format, ..args);
    
    ray.draw_text_ex(
                     global_font,
                     strings.clone_to_cstring(text),
                     cast(ray.Vector2) position,
                     f32(size),
                     0,
                     to_color(color),
                     );
}

to_color :: proc(color: V4) -> ray.Color {
	return ray.Color {
		u8(color.x),
		u8(color.y),
		u8(color.z),
		u8(color.w),
	};
}

draw_rect :: proc(rect: V4, color: V4) {
	ray.draw_rectangle(
                       i32(rect.x),
                       i32(rect.y),
                       i32(rect.z),
                       i32(rect.w),
                       to_color(color)
                       );
}

draw_rect_lines :: proc(rect: V4, color: V4, thickness: i32 = 1) {
	ray.draw_rectangle_lines_ex(
                                transmute(ray.Rectangle) rect,
                                thickness,
                                to_color(color)
                                );
}
