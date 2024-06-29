/*
    Copyright © 2022, nijigenerate Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module nijiui.widgets;
import inmath;
import bindbc.imgui;

public import nijiui.widgets.dummy;
public import nijiui.widgets.image;
public import nijiui.widgets.input;
public import nijiui.widgets.menu;
public import nijiui.widgets.label;
public import nijiui.widgets.dialog;
public import nijiui.widgets.progress;
public import nijiui.widgets.popup;
public import nijiui.widgets.category;

void uiImPush(int id) {
    igPushID(id);
}

void uiImPush(string id) {
    igPushID(id.ptr, id.ptr+id.length);
}

void uiImPush(T)(T* id) {
    igPushID(id);
}

void uiImPop() {
    igPopID();
}

void uiImIndent(float indentW = 0f) {
    igIndent(indentW);
}

void uiImUnindent() {
    igUnindent();
}

void uiImSeperator() {
    igPushStyleColor(ImGuiCol.Separator, igGetStyle().Colors[ImGuiCol.TextDisabled]);
        igSeparator();
    igPopStyleColor();
}

void uiImNewLine() {
    igNewLine();
}

bool uiImHeader(const(char)* label, bool defaultOpen=false) {
    return igCollapsingHeader(label, defaultOpen ? ImGuiTreeNodeFlags.DefaultOpen : ImGuiTreeNodeFlags.None);
}

bool uiImBeginChild(string id, vec2 size = vec2(0), bool border=false) {
    return igBeginChild(igGetID(id.ptr, id.ptr+id.length), ImVec2(size.x, size.y), border);
}

void uiImEndChild() {
    igEndChild();
}