//
//  main.m
//  itunes_add_missing
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
        
        NSArray *iTunesFileTrackURLs = [[libraryPlaylist fileTracks] arrayByApplyingSelector:@selector(location)];
        NSUInteger numberOfItunesTracks = [iTunesFileTrackURLs count];
        NSMutableArray *iTunesInodes = [[NSMutableArray alloc] initWithCapacity:numberOfItunesTracks];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSURL *anURL in iTunesFileTrackURLs) {
            NSDictionary *fileProperties = [fileManager attributesOfItemAtPath:[anURL path] error:nil];
            NSNumber *inode = [fileProperties valueForKey:NSFileSystemFileNumber];
            NSNumber *devNumber = [fileProperties valueForKey:NSFileSystemNumber];
            if (devNumber && inode) {
                [iTunesInodes addObject:[NSString stringWithFormat:@"%d+%d", devNumber,inode]];
            }
        }
        
        NSString *inputString = [[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]encoding:NSUTF8StringEncoding];
        NSArray *inputItems = [inputString componentsSeparatedByString:@"\n"];
        NSMutableArray *newURLS = [[NSMutableArray alloc] init];
        for (NSString *aString in inputItems) {
            NSDictionary *fileProperties = [fileManager attributesOfItemAtPath:aString error:nil];
            NSNumber *inode = [fileProperties valueForKey:NSFileSystemFileNumber];
            NSNumber *devNumber = [fileProperties valueForKey:NSFileSystemNumber];
            if (inode && ![iTunesInodes containsObject:[NSString stringWithFormat:@"%d+%d", devNumber,inode]]) {
                [newURLS addObject:[[NSURL alloc] initFileURLWithPath:aString]];
            }
        }
        printf("Adding %lu new items to iTunes library.\n", (unsigned long int)[newURLS count]);
        [iTunes add:newURLS to:libraryPlaylist];
    }
    return 0;
}

