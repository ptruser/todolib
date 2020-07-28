package scripts

import ray "shared:odin-raylib"
import "core:math"
import "core:fmt"

Cursor :: struct {
	y: int,
	lerp_y: f32,
	frames_up: int,
	frames_down: int,
}

cursor_update :: proc(using cursor: ^Cursor, current: ^Insertion) {
    using ray;
    
    // frames for up / down
    frames_up = is_key_down(.UP) ? frames_up + 1 : 0;
    frames_down = is_key_down(.DOWN) ? frames_down + 1 : 0;
    ctrl := is_key_down(.LEFT_CONTROL);
    shift := is_key_down(.LEFT_SHIFT);
    
    // ctrl / shift / normal movement
    if ctrl {
        if frames_up == 1 {
            for i: int = y - 1; i >= 0; i -= 1 {
                if current.list[i].checked == !current.checked {
                    y = i;
                    break;
                }
            }
        }
        
        if frames_down == 1 {
            for i: int = y + 1; i < len(current.list); i += 1 {
                if current.list[i].checked == !current.checked {
                    y = i;
                    break;
                }
            }
        }
    } else if shift {
        if frames_up == 1 {
            for i: int = y - 1; i >= 0; i -= 1 {
                if len(current.list[i].list) != 0 {
                    y = i;
                    break;
                }
            }
        }
        
        if frames_down == 1 {
            for i: int = y + 1; i < len(current.list); i += 1 {
                if len(current.list[i].list) != 0 {
                    y = i;
                    break;
                }
            }
        }
    } else {
        if (frames_up == 1 || frames_up > HOLD_MAX) && y > 0 {
            y -= 1;
        }
        if (frames_down == 1 || frames_down > HOLD_MAX) && len(current.list) - 1 > y {
            y += 1;
        }
    }
}

cursor_draw :: proc(using cursor: ^Cursor, width: f32, y_offset: f32) {
    fast := frames_up > HOLD_MAX || frames_down > HOLD_MAX;
    lerp_y = math.lerp(lerp_y, f32(y) * LAYOUT_INNER, fast ? f32(0.2) : f32(0.1));
    line_width : f32 : 2;
    draw_rect_lines({ line_width, LAYOUT_OUTER + lerp_y + y_offset + line_width, width - line_width * 2, LAYOUT_INNER - line_width * 2 }, colorscheme(.CursorLight), cast(i32) line_width);
    draw_rect_lines({ 0, LAYOUT_OUTER + lerp_y + y_offset, width, LAYOUT_INNER }, colorscheme(.CursorDark), cast(i32) line_width);
}