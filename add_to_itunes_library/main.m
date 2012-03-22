//
//  main.m
//  add_to_itunes_library
//
//  Created by Jacob Vosmaer on 22-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if (![iTunes isRunning]) {
            printf("iTunes is not running!\n");
            return 1;
        }
        iTunesLibraryPlaylist *libraryPlaylist = [[[[iTunes sources] objectAtIndex:0] libraryPlaylists] objectAtIndex:0];

        NSString *inputString = [[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]encoding:NSUTF8StringEncoding];
        NSArray *inputItems = [inputString componentsSeparatedByString:@"\n"];
        NSMutableArray *newURLS = [[NSMutableArray alloc] init];
        for (NSString *aString in inputItems) {
            NSURL *theURL = [NSURL fileURLWithPath:aString];
            if (theURL) {
                [newURLS addObject:theURL];
            }
        }
        
        [iTunes add:newURLS to:libraryPlaylist];
    }
    return 0;
}

