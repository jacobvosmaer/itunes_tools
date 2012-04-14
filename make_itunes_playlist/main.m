//
//  main.m
//  make_itunes_playlist
//
//  Created by Jacob Vosmaer on 22-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

#define ITUNES_USER_PLAYLIST_SCRIPTINGCLASS @"user playlist"
#define ITUNES_PLAYLIST_NAME_PROPERTY @"name"

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        if ((argc < 2)) {
            printf("Usage: %s playlist_name file1 file2 ...\n", argv[0]);
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
        
        NSMutableArray *listOfTracks = [NSMutableArray arrayWithCapacity:argc];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSUInteger i;
        for (i=2; i<argc; i++) {
            NSString *currentArgument = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
            if ([filemanager fileExistsAtPath:currentArgument]) {
                [listOfTracks addObject:[NSURL fileURLWithPath:currentArgument]];
            }
        }
        [iTunes add:listOfTracks to:thePlaylist];
    }
    return 0;
}

