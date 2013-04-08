//
// BhCrashlytics.mm
// Crash Reporting helper plugin for Gideros Studio (IOS Only)
//
// MIT License
// Copyright (C) 2013. Andy Bower, Bowerhaus LLP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#include "gideros.h"
#import <Crashlytics/Crashlytics.h>

static NSString* getDocPathTo(NSString* filename) {
    // Answer a full path to (filename) in the Documents directory.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath=[paths objectAtIndex:0];
    return [docPath stringByAppendingPathComponent: filename];
}

static NSString* distillLuaStackTrace(NSString* trace) {
    // Given a Gideros stack trace (and possibly other guff) in (trace) we attempt to remove superfluous stuff so that it can be
    // more easily stored into and read from a Crashlytics report.
    //
    NSMutableString* luaStack=[NSMutableString string];
    
    // First retain only the lines that mention Lua files
    NSRegularExpression* regex=[NSRegularExpression regularExpressionWithPattern:@"(^.*\\.lua.*$)" options:NSRegularExpressionAnchorsMatchLines |NSRegularExpressionUseUnixLineSeparators error: NULL];
    NSArray *matches = [regex matchesInString:trace options:0 range:NSMakeRange(0, [trace length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *substringForMatch = [trace substringWithRange:matchRange];
        
        // Now remove any excessive path information. I'm pretty hopeless at RegeEx so here I'm assuming that all path componemts are composed of
        // word characters (\w). If anyone ants to provide a more complete solutiopn, please do so.
        //
        NSRegularExpression* regex2=[NSRegularExpression regularExpressionWithPattern:@"/(\\w*/)*" options:NSRegularExpressionAnchorsMatchLines |NSRegularExpressionUseUnixLineSeparators error: NULL];
        substringForMatch=[regex2 stringByReplacingMatchesInString: substringForMatch options:0 range:NSMakeRange(0, [substringForMatch length]) withTemplate:@""];
        
        // Crashlytics doesn't display newlines so mark the beginning of each line so it is easily visible in the crash report
        [luaStack appendString:@"*** "];
        [luaStack appendString:substringForMatch];
        [luaStack appendString:@"\r\n"];
    }
    return luaStack;
}

void exit(int status)
{
    // We replace the standard C exit that Gideros calls when it finds a Lua stack error.]
    // First close the stdout file to flush it and the all important stack trace.
    //
    fclose(stdout);
  
    NSString* stdoutString=[NSString stringWithContentsOfFile: getDocPathTo(@"/stdout.txt") encoding:NSUTF8StringEncoding error: NULL];
    NSString* luaStack=distillLuaStackTrace(stdoutString);
    
    // Assign this as a custom key for Crashlytics
    [Crashlytics setObjectValue: luaStack forKey: @"LUASTACK"];
    
    // Now force a crash
    [[Crashlytics sharedInstance] crash];
    
    // We'll never reach here - this is just to avoid a compiler warning
    for (;;);
}

static int installCrashReporting(lua_State *L) {
    // Install the CrashLytics handler and the redirection of stdout to a file. This will capture any Lua stack trace that is created
    // so that it can be uploaded with a Crashlyticscrash report.
    //
    if (!isatty(STDOUT_FILENO)) {
        // We only need to to this if we are not running under the debugger.
        // If stdout is going to a console then assume XCode is present.
             
        freopen([getDocPathTo(@"/stdout.txt") UTF8String], "w", stdout);
        
        // Ideally we don't want to fill the log with superfluous Gideros FPS messages.
        glog_setLevel(GLOG_INFO);
    }
    NSString* apiKey=[NSString stringWithUTF8String: lua_tostring(L, -1)];
    [Crashlytics startWithAPIKey: apiKey];
    
    return 0;
}

static int leaveBreadcrumb(lua_State *L) {
    NSString* text=[NSString stringWithUTF8String: lua_tostring(L, -1)];
    CLSNSLog(text);
    
    return 0;
}


static int loader(lua_State *L)
{
    //This is a list of functions that can be called from Lua
    const luaL_Reg functionlist[] = {
        {"installCrashReporting", installCrashReporting},
        {"leaveBreadcrumb", leaveBreadcrumb},
        {NULL, NULL},
    };
    luaL_register(L, "BhCrashlytics", functionlist);
    
    //return the pointer to the plugin
    return 1;
}

static void g_initializePlugin(lua_State* L)
{

    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    
    lua_pushcfunction(L, loader);
    lua_setfield(L, -2, "BhCrashlytics");
      
    lua_pop(L, 2);
}

static void g_deinitializePlugin(lua_State * L) {
}

REGISTER_PLUGIN("BhCrashlytics", "1.0")