package scripts

import "core:math"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import ray "shared:odin-raylib"

Insertion :: struct {
	name: string,
	list: [dynamic]Insertion,
	checked: bool,
	entrance_y: int,
	back: ^Insertion,
	ease_checked: f32,
	hide_checked: bool,
	lerp_done: f32,
}

// clears all results in the insertion recursivally
insertion_clear :: proc(insertion: ^Insertion) {
    for sub in &insertion.list {
		insertion_destroy(&sub);
	}
    
	clear(&insertion.list);
}

// destroy all memory in the insertion recursivally
insertion_destroy :: proc(insertion: ^Insertion) {
	for sub in &insertion.list {
		insertion_destroy(&sub);
	}
    
	delete(insertion.list);
}

// draws fancy bars per insetion
insertion_draw_progress :: proc(using insertion: ^Insertion, pos: V2, width: f32) {
	using ray;
	
	rect := V4 {
		pos.x,
		pos.y,
		width,
		LAYOUT_INNER
	};
    
	if len(list) != 0 {
		// only draw alpha background when not filled
		draw_rect(rect, colorscheme(.MotherBack));
		draw_rect({
                      rect.x,
                      rect.y,
                      lerp_done,
                      LAYOUT_INNER,
                  },
                  colorscheme(.MotherFront)
                  );
    }
    
	// only when 0 children
	else {
		// appear animation
		if checked {
			amt: f32 = 1.0;
            
			if ease_checked <= 1.0 {
				amt = ease_out_cubic(ease_checked);
				ease_checked += CHECKED_SPEED;
			}
            
			draw_rect(rect, alpha(.Done, amt * 255));
		}
        
		// hide animation
		if hide_checked {
			amt := ease_out_cubic(ease_checked);
            
			if ease_checked <= 1.0 {
				ease_checked += CHECKED_SPEED;
			} else {
				hide_checked = false;
			}
            
			draw_rect(rect, alpha(.Done, (1 - amt) * 255));
		}
	}
}

// draws text and fancy bar
insertion_draw :: proc(insertion: ^Insertion, i: int, width: f32, offset: V2) {
	using ray;
	
	pos := V2 { 0, LAYOUT_OUTER + LAYOUT_INNER * f32(i) } + offset;
	insertion_draw_progress(insertion, pos, width);
	draw_string_fancy(pos + { 10,  LAYOUT_INNER / 2 - FONT_SIZE / 2 }, insertion.name);
}

// gets the len of the insertion and its inner insertions
insertion_recursive_len :: proc(using insertion: ^Insertion) -> (result: int) {
    for sub in &list {
        if len(sub.list) == 0 {
            result += 1;
        }
    }
    
    for sub in &list {
        result += insertion_recursive_len(&sub);
	}
    
	return;
}

// gets the done amount and its inner insertion done amount
insertion_recursive_done :: proc(using insertion: ^Insertion) -> (done: int) {
	if len(list) == 0 {
		return int(checked);
	}
    
	for sub in &list {
		done += insertion_recursive_done(&sub);
	}
    
	return done;
}

// updates lerp data, also recursively
insertion_update :: proc(using insertion: ^Insertion, width: f32) {
	if len(list) != 0 {
		done := insertion_recursive_done(insertion);
        all_len := insertion_recursive_len(insertion);
        
		lerp_done = math.lerp(
                              lerp_done,
                              width * (cast(f32) done / cast(f32) all_len),
                              f32(0.1)
                              );
	}
    
	for sub in &list {
		insertion_update(&sub, width);
	}
}

// writes all info of a single insertion into a builder
@(private)
insertion_write :: proc(using insertion: ^Insertion, builder: ^strings.Builder, indent: int = 0, pretty: bool = false) {
    using strings;
    
    if pretty {
        for i in 0..<indent {
            write_byte(builder, '\t');
        }
    }
    write_string(builder, name);
    write_byte(builder, '_');
    write_string(builder, fmt.tprintf("%v", checked));
    
    if len(list) != 0 {
        write_string(builder, "_{");
    }
    
    for sub in &list {
        write_byte(builder, '\n');
        insertion_write(&sub, builder, indent + 1);
    }
    
    if len(list) != 0 {
        if pretty {
            for i in 0..<indent {
                write_byte(builder, '\t');
            }
        }
        write_string(builder, "\n}");
    }
    
    // pretty space things apart
    if indent == 0 do write_string(builder, "\n\n");
}

// saves all data of all insertions recursively
insertion_save :: proc(file_name: string, insertion: ^Insertion, pretty: bool = false) {
    using strings;
    builder := make_builder();
    
    write_string(&builder, fmt.tprintf("colorscheme_%v \n", colorscheme_index));
    write_string(&builder, fmt.tprintf("inverted text colors_%v \n", inverted_text_colors));
    write_byte(&builder, '\n');
    
    for sub in &insertion.list {
        insertion_write(&sub, &builder, 0, pretty);
    }
    
    //fmt.println(to_string(builder));
    ok := os.write_entire_file(file_name, builder.buf[:]);
}

// loads all data from a string / file into the insertion
insertion_load :: proc(file_name: string, insertion: ^Insertion) {
    using strings;
    
    file, ok := os.read_entire_file(file_name);
    if !ok do return;
    
    line_splits := split(string(file), "\n");
    
    colorscheme_index = strconv.atoi(split(line_splits[0], "_")[1]);
    res := trim_right_space(split(line_splits[1], "_")[1]);
    inverted_text_colors = res == "true" ? true : false;
    
    head := insertion;
    for i in 2..<len(line_splits) {
        if line_splits[i] == "" {
            continue;
        }
        
        splits := split(line_splits[i], "_");
        
        if len(splits) == 1 {
            head = head.back;
            continue;
        }
        
        if len(splits) == 3 {
            if splits[2] == "{" {
                append(&head.list, Insertion { back = head });
                head = &head.list[len(head.list) - 1];
                head.name = splits[0];
            }
        } else {
            append(&head.list, Insertion { back = head });
            edit := &head.list[len(head.list) - 1];
            if splits[1] == "true" do edit.checked = true;
            if splits[1] == "false" do edit.checked = false;
            edit.name = splits[0];
        }
    }
}
