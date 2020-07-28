# Todolib
Todo library app made with [odin](https://github.com/odin-lang/Odin) / [raylib](https://github.com/raysan5/raylib) made because I wanted a simple and efficient way to organize todo lists - infinitely and focused

# Preview
[youtube](https://www.youtube.com/watch?v=FZac4pGxHeY)
![gif](https://github.com/Skytrias/todolib/blob/master/preview.gif)

# Features
* Infinite Todo lists
* Fast movement
* Fast editing
* Autosave / Autoload todo file
* Colorschemes

# Custom Font
place a `.tff` file next to the `.exe` application and rename the `.ttf` file to `font.ttf`

# Keyboard control
* Basics:
    * UP = move up list
    * DOWN = move down list
    * RIGHT = move right inside insertion
    * LEFT = move back to previous insertion (root)
    * ENTER = send written text to list
    * TAB = toggle insertion (true / false)
    * any character key = write text

* Advanced
    * CTRL + S = save to file
    * CTRL + O = load file
    * CTRL + E = edit insertion text
    * CTRL + D = delete insertion from list which is currently selected
    * CTRL + (UP / DOWN) = move to nearest completed insertion
    * SHIFT + (UP / DOWN) = move to nearest insertion with list
    * CTRL + I = invert text color *(will be saved)*
    * ALT + RIGHT = next colorscheme *(will be saved)*
    * ALT + LEFT = previous colorscheme *(will be saved)*

# Release.bat
run this to create a non-console app with optimizations on, used when shipping the app