package scripts

// layouting
FONT_SIZE :: 20.0;
HOLD_MAX :: 15;
LAYOUT_INNER :: 50.0;
LAYOUT_OUTER :: 100.0;
CHECKED_SPEED :: 0.1;
SLIDE_SPEED :: 0.1;
WINDOW_SPEED : f32 : 0.20;
TOP_SPEED :: 0.05;

// colors
C_BLACK :: V4 { 0, 0, 0, 255 };
C_WHITE :: V4 { 255, 255, 255, 255 };

// style
Elements :: enum {
	Background,
	Done,
	MotherFront,
	MotherBack,
	CursorLight,
	CursorDark,
}

a_colorscheme := [Elements]V4 {
	.MotherFront = { 30, 34, 32, 255 },
	.MotherBack = { 30, 34, 32, 120 },
	.Done = { 69, 147, 202, 255 },
	.Background = { 125, 124, 130, 255 },
	.CursorLight = { 212, 132, 27, 255 },
	.CursorDark = { 151, 85, 0, 255 },
};

b_colorscheme := [Elements]V4 {
	.Background = { 124, 234, 156, 255 },
	.Done = { 85, 214, 190, 255 },
	.MotherFront = { 91, 78, 119, 255 },
	.MotherBack = { 89, 57, 89, 255 },
	.CursorLight = { 61, 126, 229, 255 },
	.CursorDark = { 46, 94, 170, 255 },
};

c_colorscheme := [Elements]V4 {
	.Background = { 181, 214, 214, 255 },
	.Done = { 206, 181, 183, 255 },
	.MotherBack = { 230, 149, 151, 255 },
	.MotherFront = { 255, 116, 119, 255 },
	.CursorLight = { 156, 246, 246, 255 },
	.CursorDark = { 156, 246, 246, 255 },
};

// greenish
d_colorscheme := [Elements]V4 {
	.MotherFront = { 73, 145, 103, 255 },
	.MotherBack = { 95, 221, 157, 255 },
	.Done = { 118, 247, 191, 255 },
	.Background = { 145, 249, 229, 255 },
	.CursorLight = { 63, 69, 49, 255 },
	.CursorDark = { 63, 69, 49, 255 },
};

// brown / red / white / green
e_colorscheme := [Elements]V4 {
	.MotherFront = { 179, 57, 81, 255 },
	.MotherBack = { 84, 73, 75, 255 },
	.Done = { 145, 199, 177, 255 },
	.Background = { 241, 247, 237, 255 },
	.CursorLight = { 227, 208, 129, 255 },
	.CursorDark = { 84, 73, 75, 255 },
};

f_colorscheme := [Elements]V4 {
	.MotherFront = { 239, 202, 8, 255 },
	.MotherBack = { 240, 135, 0, 255 },
	.Done = { 0, 166, 166, 255 },
	.Background = { 187, 222, 240, 255 },
	.CursorLight = { 0, 166, 166, 255 },
	.CursorDark = { 240, 135, 0, 255 },
};

colorscheme_index := 0;
all_colorschemes := [?][Elements]V4 {
    a_colorscheme,
    b_colorscheme,
    c_colorscheme,
    d_colorscheme,
    e_colorscheme,
    f_colorscheme,
};

colorscheme :: proc(element: Elements) -> V4 {
    return all_colorschemes[colorscheme_index][element];
}

// changes the alpha part of a color 0-255
alpha :: proc(element: Elements, value: f32) -> (color: V4) {
	color = colorscheme(element);
	color.a = value;
	return;
}
