package main

import "core:fmt"
import ray "shared:odin-raylib"
import "core:math/linalg"
import "core:math/rand"
import "core:math"
import "scripts"
import "core:strings"
import "core:strconv"
import "core:os"

V2 :: linalg.Vector2;
V4 :: linalg.Vector4;

main :: proc() {
	using ray;
	using scripts;
	using strings;
    
	set_config_flags(.WINDOW_UNDECORATED);// | .WINDOW_RESIZABLE);
    set_trace_log_level(.WARNING);
	init_window(960, cast(i32) LAYOUT_OUTER / 2, "todo");
    monitor_width := get_monitor_width(0);
	set_window_position(get_monitor_width(0) / 2, 0);
	defer close_window();
    set_target_fps(60);
    
	global_font = load_font_ex("font.ttf", FONT_SIZE, nil, 250);
	defer unload_font(global_font);
    
	input_builder := make_builder();
	lerp_input: f32 = 0;
	root := Insertion {
		name = "home",
	};
	defer insertion_destroy(&root);
	frames_backspace := 0;
	cursor: Cursor;
	slide := false;
	slide_amount: f32 = 0;
	slide_ease: f32 = 0;
	slide_direction: int = 1;
	slide_insertion: ^Insertion = nil;
    top_ease: f32 = 0;
    top_height: f32 = 0;
    
    window_height: f32 = LAYOUT_OUTER / 2;
    
    editing := false;
	current := &root;
    
    // autoload and autosave
    insertion_load("save.txt", &root);
    defer insertion_save("save.txt", &root, false);
    
    for !window_should_close() {
		width := cast(f32) get_screen_width();
        height := cast(f32) get_screen_height();
        
        // calculate new height of window
        new_height := cast(f32) len(current.list) * LAYOUT_INNER + LAYOUT_OUTER / 2 + top_height;
        if height != new_height {
            window_height = math.lerp(window_height, new_height, WINDOW_SPEED);
            set_window_size(cast(i32) width, cast(i32) window_height);
        }
        
        // update code
        {
            insertion_update(&root, width);
            
            key := get_key_pressed();
            ctrl := is_key_down(.LEFT_CONTROL);
            alt := is_key_down(.LEFT_ALT);
            
            // ease top bar
            if builder_len(input_builder) != 0 {
                if top_height < LAYOUT_OUTER / 2 {
                    top_ease += TOP_SPEED;
                    top_height = ease_out_cubic(top_ease) * LAYOUT_OUTER / 2;
                } else {
                    top_height = LAYOUT_OUTER / 2;
                    top_ease = 0;
                }
            } else {
                if top_height > 0 {
                    top_ease += TOP_SPEED;
                    top_height = (1 - ease_out_cubic(top_ease)) * LAYOUT_OUTER / 2;
                } else {
                    top_height = 0;
                    top_ease = 0;
                }
            }
            
            // write any key
            if key != 0 {
                write_byte(&input_builder, u8(key));
            }
            
            if ctrl && is_key_pressed(.E) {
                reset_builder(&input_builder);
                write_string(&input_builder, clone(current.list[cursor.y].name));
                
                editing = true;
                fmt.println("editing");
            }
            
            // invert text colors, will be saved automatically on exit
            if ctrl && is_key_pressed(.I) {
                inverted_text_colors = !inverted_text_colors;
            }
            
            // enter key to input
            if is_key_pressed(.ENTER) {
                if builder_len(input_builder) != 0 {
                    if !editing {
                        // TODO(Skytrias): disallow 3 runes?
                        append(&current.list, Insertion {
                                   name = clone(to_string(input_builder)),
                                   checked = ctrl,
                               });
                    } else {
                        current.list[cursor.y].name = clone(to_string(input_builder));
                        editing = false;
                    }
                    
                    reset_builder(&input_builder);
                }
            }
            
            // only allow tab if cursor list has nothing
            if is_key_pressed(.TAB) && len(current.list) != 0 && len(current.list[cursor.y].list) == 0 {
                if current.list[cursor.y].checked {
                    current.list[cursor.y].checked = false;
                    current.list[cursor.y].hide_checked = true;
                } else {
                    current.list[cursor.y].checked = true;
                }
                current.list[cursor.y].ease_checked = 0;
            }
            
            // remove and clamp
            if ctrl && is_key_pressed(.D) && len(current.list) != 0 {
                ordered_remove(&current.list, cursor.y);
                cursor.y = clamp(cursor.y, 0, max(0, len(current.list) - 1));
            }
            
            // remove from input based on backspace
            frames_backspace = is_key_down(.BACKSPACE) ? frames_backspace + 1 : 0;
            if ctrl {
                if frames_backspace == 1 {
                    reset_builder(&input_builder);
                }
            } else {
                if frames_backspace == 1 || frames_backspace > HOLD_MAX {
                    pop_rune(&input_builder);
                }
            }
            
            // save the root node, done automatically at end
            if ctrl && is_key_pressed(.S) {
                insertion_save("save.txt", &root, false);
            }
            
            // load the root node, done automatically at start
            if ctrl && is_key_pressed(.O) {
                insertion_clear(&root);
                insertion_load("save.txt", &root);
            }
            
            if !editing {
                cursor_update(&cursor, current);
            }
            
            // move right or change colorscheme
            if !editing {
                if is_key_pressed(.RIGHT) {
                    if alt {
                        if colorscheme_index < len(all_colorschemes) - 1 {
                            colorscheme_index += 1;
                        }
                    } else if len(current.list) != 0 {
                        current.list[cursor.y].back = current;
                        current.entrance_y = cursor.y;
                        current = &current.list[cursor.y];
                        cursor.y = current.entrance_y;
                        //cursor.y = clamp(cursor.y, 0, max(0, len(current.list) - 1));
                        slide_direction = 1;
                        slide_ease = 0;
                        slide_amount = 0;
                        slide = true;
                    }
                }
                
                // move left or change colorscheme
                if is_key_pressed(.LEFT) {
                    if alt {
                        if colorscheme_index > 0 {
                            colorscheme_index -= 1;
                        }
                    } else if current.back != nil {
                        slide_insertion = current;
                        current.entrance_y = cursor.y;
                        current = current.back;
                        cursor.y = current.entrance_y;
                        slide_direction = -1;
                        slide_amount = 0;
                        slide_ease = 0;
                        slide = true;
                    }
                }
            }
        }
        
        // draw code
        {
            begin_drawing();
            defer end_drawing();
            
            clear_background(to_color(colorscheme(.Background)));
            
            // draw top
            {
                if builder_len(input_builder) != 0 {
                    input := to_string(input_builder);
                    x := x_center(input, width);
                    lerp_input = math.lerp(lerp_input, x, f32(0.15));
                    
                    // highlight editing bar
                    if editing {
                        draw_rect({ 0, LAYOUT_OUTER / 2, width, LAYOUT_INNER }, { 255, 0, 0, 255 });
                    }
                    
                    draw_string_fancy({ lerp_input, LAYOUT_OUTER * 3 / 4 - FONT_SIZE / 2 }, input);
                }
                
                insertion_draw_progress(current, {}, width);
                draw_string_fancy({ 10, LAYOUT_INNER / 2 - FONT_SIZE / 2 }, current.name);
            }
            
            // update slide easing
            if slide {
                slide_amount = ease_out_exponential(slide_ease);
                
                if slide_ease <= 1.0 {
                    slide_ease += SLIDE_SPEED;
                } else {
                    slide = false;
                    slide_ease = 0;
                    slide_amount = 0;
                }
            }
            
            // draw current with slide animation
            y_offset := (top_height - LAYOUT_OUTER / 2);
            for sub, i in &current.list {
                x: f32 = 0;
                
                if slide {
                    if slide_direction == -1 {
                        x = (1 - slide_amount) * -width;
                    } else {
                        x = (1 - slide_amount) * width;
                    }
                }
                
                insertion_draw(&sub, i, width, { x, y_offset });
            }
            
            // draw history one when sliding
            if slide {
                if slide_direction == 1 {
                    if current.back != nil {
                        for sub, i in &current.back.list {
                            insertion_draw(&sub, i, width, { slide_amount * -width, y_offset });
                        }
                    }
                } else {
                    for sub, i in &slide_insertion.list {
                        insertion_draw(&sub, i, width, { slide_amount * width, y_offset });
                    }
                }
            }
            
            cursor_draw(&cursor, width, y_offset);
        }
    }
}
