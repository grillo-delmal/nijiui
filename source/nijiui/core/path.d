/*
    Copyright © 2022, Inochi2D Project
    Copyright © 2024, nijigenerate Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module nijiui.core.path;
import nijiui.core.app;
import std.path;
import std.process;
import std.file : getcwd, mkdirRecurse, exists;

private {
    string cachedConfigDir;
    string cachedImguiFileDir;
    string cachedFontDir;
    string cachedLocaleDir;
    string inForcedConfigDir;
}


/**
    Name of environment variable to force a configuration path
*/
enum ENV_CONFIG_PATH = "IN_CONFIG_PATH";

/**
    Returns the app configuration directory for the platform
*/
string inGetAppConfigPath() {
    if (cachedConfigDir) return cachedConfigDir;
    if (inForcedConfigDir) return inForcedConfigDir;
    string appDataDir;

    // Once this function has completed cache the result.
    scope(success) {
        
        if (inForcedConfigDir) {
            
            // Also make sure the folder exists
            if (!exists(inForcedConfigDir)) {
                mkdirRecurse(inForcedConfigDir);
            }
        } else {
            cachedConfigDir = appDataDir;

            // Also make sure the folder exists
            if (!exists(cachedConfigDir)) {
                mkdirRecurse(cachedConfigDir);
            }
        }
    }

    // On Windows %AppData% is used.
    // Example: C:/Users/USERNAME/AppData/Roaming/.nijigenerateS
    version(Windows) {
        appDataDir = environment.get("AppData");
    }

    // On Linux the app data dir is in $XDG_CONFIG_DIR, $HOME/.config or $HOME
    // Example: /home/USERNAME/.nijigenerate
    // NOTE: on flatpak XDG_CONFIG_HOME is ~/.var/app/
    else version(linux) {
        appDataDir = environment.get("XDG_CONFIG_HOME");
        if (!appDataDir) appDataDir = buildPath(environment.get("HOME"), ".config");
    }

    // On macOS things are thrown in to $HOME/Library/Application Support
    // Example: /home/USERNAME/Library/Application Support/.nijigenerate
    else version(OSX) {
        appDataDir = environment.get("HOME");
        if (appDataDir) appDataDir = buildPath(appDataDir, "Library", "Application Support");
    }

    // On other POSIX platforms just assume $HOME exists.
    // Example: /home/USERNAME/.nijigenerate
    else version(posix) {
        appDataDir = environment.get("HOME");
    }

    // Allow packagers, etc. to specify a forced config directory.
    inForcedConfigDir = environment.get(ENV_CONFIG_PATH);
    if (inForcedConfigDir) return inForcedConfigDir;
    

    if (!appDataDir) appDataDir = getcwd();

    version(linux) {

        // On linux we're using standard XDG dirs, prior we
        // used .nijigenerate there, but that's not correct
        // This code will ensure we still use old config if it's there.
        // Otherwise we create config for the *correct* path
        string fdir = buildPath(appDataDir, "."~inGetApplication().configDirName);
        if (!exists(fdir)) fdir = buildPath(appDataDir, inGetApplication().configDirName);
        appDataDir = fdir;
        return appDataDir;
    } else {

        // On other platforms we go for .(app name)
        appDataDir = buildPath(appDataDir, "."~inGetApplication().configDirName);
        return appDataDir;
    }
}

/**
    Gets the directory for an imgui config file.
*/
string inGetAppImguiConfigFile() {
    if (cachedImguiFileDir) return cachedImguiFileDir;
    cachedImguiFileDir = buildPath(inGetAppConfigPath(), "imgui.ini");
    return cachedImguiFileDir;
}

/**
    Gets directory for custom fonts
*/
string inGetAppFontsPath() {
    if (cachedFontDir) return cachedFontDir;
    cachedFontDir = buildPath(inGetAppConfigPath(), "fonts");
    if (!exists(cachedFontDir)) {
        
        // Create our font directory
        mkdirRecurse(cachedFontDir);

    }
    return cachedFontDir;
}

/**
    Gets directory for custom fonts
*/
string inGetAppLocalePath() {
    if (cachedLocaleDir) return cachedLocaleDir;
    cachedLocaleDir = buildPath(inGetAppConfigPath(), "i18n");
    if (!exists(cachedLocaleDir)) {
        
        // Create our font directory
        mkdirRecurse(cachedLocaleDir);
    }
    return cachedLocaleDir;
}

string inGetAppCustomPath(string name) {    
    string path = buildPath(inGetAppConfigPath(), name);

    // Create our directory
    if (!exists(path)) mkdirRecurse(path);
    return path;
}
