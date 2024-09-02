/*
    Copyright © 2022, Inochi2D Project
    Copyright © 2024, nijigenerate Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module nijiui.widgets.menu;
import bindbc.imgui;
import std.string;

/**
    Begins a menu bar
*/
bool uiImBeginMainMenuBar() {
    return igBeginMainMenuBar();
}

/**
    Ends a main menu bar
*/
void uiImEndMainMenuBar() {
    igEndMainMenuBar();
}

/**
    Begin menu bar
*/
bool uiImBeginMenuBar() {
    return igBeginMenuBar();
}

/**
    End menu bar
*/
void uiImEndMenuBar() {
    igEndMenuBar();
}

/**
    Begins a menu
*/
bool uiImBeginMenu(const(char)* label, bool enabled = true) {
    return igBeginMenu(label, enabled);
}

/**
    Ends a menu
*/
void uiImEndMenu() {
    igEndMenu();
}

/**
    Menu item
*/
bool uiImMenuItem(const(char)* label, const(char)* shortcut = "", bool selected = false, bool enabled = true) {
    return igMenuItem(label, shortcut, selected, enabled);
}
