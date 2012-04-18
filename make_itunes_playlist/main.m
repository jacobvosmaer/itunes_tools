//
//  main.m
//  make_itunes_playlist
//
//  Created by Jacob Vosmaer on 22-03-12.
//  Copyright (c) 2012 Jacob Vosmaer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

#define ITUNES_USER_PLAYLIST_SCRIPTINGCLASS @"user playlist"
#define ITUNES_PLAYLIST_NAME_PROPERTY @"name"

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        if ((argc < 2)) {
            printf("Usage: %s playlist_name (file1 [file2 ...] | - )\n", argv[0]);
            return 2;
        }
        
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if (![iTunes isRunning]) {
            printf("iTunes is not running!\n");
            return 1;
        }
        
        SBElementArray *userPlaylists = [[[iTunes sources] objectAtIndex:0] userPlaylists];
        NSString *playlistName = [[NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding] stringByAppendingFormat:@" (%@)", [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]];
        iTunesUserPlaylist *thePlaylist =[[[iTunes classForScriptingClass:ITUNES_USER_PLAYLIST_SCRIPTINGCLASS] alloc] initWithProperties:[NSDictionary dictionaryWithObject:playlistName forKey:ITUNES_PLAYLIST_NAME_PROPERTY]];
        [userPlaylists addObject:thePlaylist];

        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:argc];
        for (NSUInteger i=2; i<argc; i++) {
            [arguments addObject: [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
        }
        
        NSArray *listOfPaths;
        if ([arguments count] == 1 && ([[arguments objectAtIndex:0] isEqualToString:@"-"])) {
            NSString *inputString = [[[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            listOfPaths = [inputString componentsSeparatedByString:@"\n"];
        } else {
            listOfPaths = arguments;
        }
        
        NSMutableArray *listOfTracks = [[NSMutableArray alloc] init];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        for (NSString *path in listOfPaths) {
            if ([filemanager fileExistsAtPath:path]) {
                [listOfTracks addObject:[NSURL fileURLWithPath:path]];
            }
        }
        [iTunes add:listOfTracks to:thePlaylist];
    }
    return 0;
}

