/*
    Copyright © 2022, nijigenerate Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module nijiui.widgets.dialog;
import nijiui.widgets.dummy;
import nijiui.widgets.label;
import nijiui.core.font;
import bindbc.imgui;
import nijilive;
import i18n;

enum DialogLevel : size_t {
    Info = 0,
    Warning = 1,
    Error = 2
}

enum DialogButtons {
    NONE = 0,
    OK = 1,
    Cancel = 2,
    Yes = 4,
    No = 8
}

void uiImInitDialogs() {
    // Only load Ada in official builds
    version(InBranding) {
        auto infoTex = ShallowTexture(cast(ubyte[])import("ui/ui-info.png"));
        inTexPremultiply(infoTex.data);
        auto warnTex = ShallowTexture(cast(ubyte[])import("ui/ui-warning.png"));
        inTexPremultiply(warnTex.data);
        auto errTex = ShallowTexture(cast(ubyte[])import("ui/ui-error.png"));
        inTexPremultiply(errTex.data);

        adaTextures = [
            new Texture(infoTex),
            new Texture(warnTex),
            new Texture(errTex),
        ];
    }
}

/**
    Render dialogs
*/
void uiImRenderDialogs() {
    if (entries.length > 0) {
        auto entry = &entries[0];

        if (!igIsPopupOpen(entry.title)) {
            igOpenPopup(entry.title);
        }

        auto flags = 
            ImGuiWindowFlags.NoSavedSettings | 
            ImGuiWindowFlags.NoResize | 
            ImGuiWindowFlags.AlwaysAutoResize;
        if (igBeginPopupModal(entry.title, null, flags)) {
            float uiScale = inGetUIScale();
            float errImgScale = 112*uiScale;
            float msgEndPadding = 4*uiScale;


            igBeginGroup();

                if (igBeginChild("ErrorMainBoxLogo", ImVec2(errImgScale, errImgScale))) {
                    version (InBranding) {
                        igImage(cast(void*)adaTextures[cast(size_t)entry.level].getTextureId(), ImVec2(errImgScale, errImgScale));
                    }
                }
                igEndChild();

                igSameLine(0, 0);
                igPushTextWrapPos(512*uiScale);
                    uiImLabel(entry.text);
                igPopTextWrapPos();

                igSameLine(0, 0);
                uiImDummy(vec2(msgEndPadding, 1));
            igEndGroup();


            //
            // BUTTONS
            //
            auto avail = uiImAvailableSpace();
            float btnHeight = 24*uiScale;
            float btnSize = 80*uiScale;
            float totalBtnSize = btnSize*entry.btncount;
            float msgAreaWidth = errImgScale+uiImMeasureString(entry.text).x+msgEndPadding;
            float requestedMinimumSize = 256*uiScale;

            if ((msgAreaWidth < requestedMinimumSize) && totalBtnSize < requestedMinimumSize) {

                // Handle very short dialog messages.
                igDummy(ImVec2(requestedMinimumSize-(totalBtnSize+1), btnHeight));
                igSameLine(0, 0);
            } else if (avail.x > totalBtnSize) {
                
                // Add pre-padding to buttons
                igDummy(ImVec2(avail.x-(totalBtnSize+1), btnHeight));
                igSameLine(0, 0);
            }
            
            if ((entry.btns & DialogButtons.Cancel) == 2) {
                if (igButton(__("Cancel"), ImVec2(btnSize, btnHeight))) {
                    entry.selected = DialogButtons.Cancel;
                    igCloseCurrentPopup();
                }
                igSameLine(0, 0);
            }

            if ((entry.btns & DialogButtons.OK) == 1) {
                if (igButton(__("OK"), ImVec2(btnSize, btnHeight))) {
                    entry.selected = DialogButtons.OK;
                    igCloseCurrentPopup();
                }
                igSameLine(0, 0);
            }
            
            if ((entry.btns & DialogButtons.No) == 8) {
                if (igButton(__("No"), ImVec2(btnSize, btnHeight))) {
                    entry.selected = DialogButtons.No;
                    igCloseCurrentPopup();
                }
                igSameLine(0, 0);
            }
            
            if ((entry.btns & DialogButtons.Yes) == 4) {
                if (igButton(__("Yes"), ImVec2(btnSize, btnHeight))) {
                    entry.selected = DialogButtons.Yes;
                    igCloseCurrentPopup();
                }
            }

            igEndPopup();
        }
    }
}

/**
    Clean up dialogs
*/
void uiImCleanupDialogs() {
    if (entries.length > 0 && entries[0].selected > 0) {
        entries = entries[1..$];
    }
}

/**
    Creates a dialog with the tag set to the title

    Only use this if you don't need to query the exit state of the dialog
*/
void uiImDialog(const(char)* title, string body_, DialogLevel level = DialogLevel.Error, DialogButtons btns = DialogButtons.OK, void* userData = null) {
    uiImDialog(title, title, body_, level, btns, userData);
}

/**
    Creates a dialog
*/
void uiImDialog(const(char)* tag, const(char)* title, string body_, DialogLevel level = DialogLevel.Error, DialogButtons btns = DialogButtons.OK, void* userData = null) {
    import std.string : toStringz;
    int btncount = 0;
    if ((btns & DialogButtons.OK) == 1) btncount++;
    if ((btns & DialogButtons.Cancel) == 2) btncount++;
    if ((btns & DialogButtons.Yes) == 4) btncount++;
    if ((btns & DialogButtons.No) == 8) btncount++;

    entries ~= DialogEntry(
        tag,
        title,
        body_,
        level,
        btns,
        DialogButtons.NONE,
        btncount,
        userData
    );
}

/**
    Gets which button the user selected in the last dialog box with the selected tag.
    Returns NONE if the last dialog was *not* the looked for tag or if there's no dialogs open
*/
DialogButtons uiImDialogButtonSelected(const(char)* tag) {
    if (entries.length == 0) return DialogButtons.NONE;
    if (entries[0].tag != tag) return DialogButtons.NONE;
    return entries[0].selected;
}

/**
    Returns the user data bound to the dialog
*/
void* uiImDialogButtonUserData(const(char)* tag) {
    if (entries.length == 0) return null;
    if (entries[0].tag != tag) return null;
    return entries[0].userData;
}

private {
    Texture[] adaTextures;

    DialogEntry[] entries;

    DialogEntry* findDialogEntry(const(char)* tag) {
        foreach(i; 0..entries.length) {
            if (entries[i].tag == tag) return &entries[i];
        }
        return null;
    }

    struct DialogEntry {
        const(char)* tag;
        const(char)* title;
        string text;
        DialogLevel level;
        DialogButtons btns;
        DialogButtons selected;
        int btncount;
        void* userData;
    }
}