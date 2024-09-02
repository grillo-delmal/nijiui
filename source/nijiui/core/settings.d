/*
    Copyright © 2022, Inochi2D Project
    Copyright © 2024, nijigenerate Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module nijiui.core.settings;
import std.file;
import std.path : buildPath;
import nijiui.core.path;
import fghj;
import nijiui.utils.serialize;

private {
    FghjNode settings;
}

/**
    Gets settings path
*/
string inSettingsPath() {
    return buildPath(inGetAppConfigPath(), "settings.json");
}

/**
    Load settings from settings file
*/
void inSettingsLoad() {
    settings = FghjNode.init;
    if (exists(inSettingsPath())) {
        settings = FghjNode(parseJson(readText(inSettingsPath())));
    }
}

/**
    Saves settings from settings store
*/
void inSettingsSave() {
    import mir.conv : to;
    write(inSettingsPath(), (cast(Fghj)settings).to!string);
}

/**
    Gets a value from the settings store
*/
T inSettingsGet(T)(string name, T default_ = T.init) if (__traits(hasMember, T, "deserializeFromFghj")) {
    if (!inSettingsCanGet(name)) return default_;
    
    T ot = default_;
    ot.deserializeFromFghj((cast(Fghj)settings)[name]);
    return ot;
}

/**
    Gets a value from the settings store
*/
T inSettingsGet(T)(string name, T default_ = T.init) if (!__traits(hasMember, T, "deserializeFromFghj")) {
    if (!inSettingsCanGet(name)) return default_;
    
    T ot = default_;
    (cast(Fghj)settings)[name].deserializeValue!T(ot);
    return ot;
}

/**
    Sets a setting
*/
void inSettingsSet(T)(string name, T value) {
    settings[name] = FghjNode(serializeToFghj(value));
}

/**
    Gets whether a setting is obtainable
*/
bool inSettingsCanGet(string name) {
    return (name in settings.children) !is null;
}
