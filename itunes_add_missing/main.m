//
//  main.m
//  itunes_add_missing
//
//  Created by Jacob Vosmaer on 22-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

NSString *hashForPath(NSString *path, NSFileManager *fM);

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
        NSMutableArray *iTunesHashes = [[NSMutableArray alloc] initWithCapacity:numberOfItunesTracks];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSURL *anURL in iTunesFileTrackURLs) {
            NSString *hash = hashForPath([anURL path], fileManager);
            if (hash) {
                [iTunesHashes addObject:hash];
            }
        }
        
        NSString *inputString = [[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]encoding:NSUTF8StringEncoding];
        NSArray *inputItems = [inputString componentsSeparatedByString:@"\n"];
        NSMutableArray *newURLs = [[NSMutableArray alloc] init];
        for (NSString *aString in inputItems) {
            NSString *hash = hashForPath(aString, fileManager);
            if (![iTunesHashes containsObject:hash]) {
                [newURLs addObject:[[NSURL alloc] initFileURLWithPath:aString]];
            }
        }
        printf("Adding %lu new items to iTunes library.\n", (unsigned long int)[newURLs count]);
        [iTunes add:newURLs to:libraryPlaylist];
    }
    return 0;
}

NSString *hashForPath(NSString *path, NSFileManager *fM)
{
    @autoreleasepool {
        NSString *result = nil;
        NSDictionary *fileProperties = [fM attributesOfItemAtPath:path error:nil];
        NSNumber *inode = [fileProperties valueForKey:NSFileSystemFileNumber];
        NSNumber *devNumber = [fileProperties valueForKey:NSFileSystemNumber];
        if (devNumber && inode) {
            result = [[NSString alloc] initWithFormat:@"%d+%d", devNumber,inode];
        }
        return result;
    }
}
