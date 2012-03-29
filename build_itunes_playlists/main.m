//
//  main.m
//  build_itunes_playlists
//
//  Created by Jacob Vosmaer on 22-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

#define IMPORT_FOLDER_PREFIX @"Imported"
#define M3U_EXTENSION @"m3u"
#define M3U_COMMENT_PREFIX @"#"
#define ITUNES_USER_PLAYLIST_SCRIPTINGCLASS @"user playlist"
#define ITUNES_FOLDER_PLAYLIST_SCRIPTINGCLASS @"folder playlist"
#define ITUNES_PLAYLIST_NAME_PROPERTY @"name"

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        if (!(argc == 2)) {
            printf("Usage: %s /path/to/folder\n", argv[0]);
            return 1;
        }
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSString *rootDirectoryPath = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSURL *rootDirectory;
        BOOL isDirectory;
        if (([filemanager fileExistsAtPath:rootDirectoryPath isDirectory:&isDirectory] && isDirectory)) {
            rootDirectory = [[NSURL fileURLWithPath:rootDirectoryPath isDirectory:YES] URLByResolvingSymlinksInPath];
        } else {
            printf("first argument: %s\nis not a directory\n", [rootDirectoryPath fileSystemRepresentation]);
            return 1;
        }
        
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if (![iTunes isRunning]) {
            printf("iTunes is not running!\n");
            return 1;
        }
        
        SBElementArray *userPlaylists = [[[iTunes sources] objectAtIndex:0] userPlaylists];
        
        NSString *rootFolderPlaylistName = [NSString stringWithFormat:@"%@ %@ UTC", IMPORT_FOLDER_PREFIX, [[NSDate date] description]];
        iTunesFolderPlaylist *rootFolderPlaylist = [[[iTunes classForScriptingClass:ITUNES_FOLDER_PLAYLIST_SCRIPTINGCLASS] alloc] initWithProperties:[NSDictionary dictionaryWithObject:rootFolderPlaylistName forKey:ITUNES_PLAYLIST_NAME_PROPERTY]];
        [userPlaylists addObject:rootFolderPlaylist];        
        NSMutableDictionary *iTunesPath = [NSMutableDictionary dictionaryWithObjectsAndKeys:rootFolderPlaylist, rootDirectory, nil];
        
        NSDirectoryEnumerator *directorEnumerator = [filemanager enumeratorAtURL:rootDirectory includingPropertiesForKeys:[NSArray arrayWithObject: NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        for (NSURL *theURL in directorEnumerator) {
            iTunesFolderPlaylist *parentFolderPlaylist = [iTunesPath objectForKey:[theURL URLByDeletingLastPathComponent]];
            if (!parentFolderPlaylist) {
                parentFolderPlaylist = rootFolderPlaylist;
            }
            
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            if ([isDirectory boolValue] && ![iTunesPath objectForKey:theURL]) {
                
                iTunesFolderPlaylist *newFolderPlaylist = [[[iTunes classForScriptingClass:ITUNES_FOLDER_PLAYLIST_SCRIPTINGCLASS] alloc] initWithProperties:[NSDictionary dictionaryWithObject:[theURL lastPathComponent] forKey:ITUNES_PLAYLIST_NAME_PROPERTY]];
                [userPlaylists addObject:newFolderPlaylist];
                [newFolderPlaylist moveTo:parentFolderPlaylist];
                [iTunesPath setObject:newFolderPlaylist forKey:theURL];
                
            } else if (![isDirectory boolValue] && [[theURL pathExtension] isEqualToString:M3U_EXTENSION]) {
                
                iTunesUserPlaylist *newPlaylist = [[[iTunes classForScriptingClass:ITUNES_USER_PLAYLIST_SCRIPTINGCLASS] alloc] initWithProperties:[NSDictionary dictionaryWithObject:[[theURL lastPathComponent] stringByDeletingPathExtension] forKey:ITUNES_PLAYLIST_NAME_PROPERTY]];
                [userPlaylists addObject:newPlaylist];
                [newPlaylist moveTo:parentFolderPlaylist];
                
                NSArray *linesInM3UFile = [[NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:@"\n"];
                NSMutableArray *listOfNewURLs = [NSMutableArray array];
                for (NSString *filePath in linesInM3UFile) {
                    // validate line in m3u file
                    if ([filePath length] && ![filePath hasPrefix:M3U_COMMENT_PREFIX] && [filemanager fileExistsAtPath:filePath]) {
                        [listOfNewURLs addObject:[[[NSURL alloc] initFileURLWithPath:filePath] absoluteURL]];
                    }
                }
                
                [iTunes add:listOfNewURLs to:newPlaylist];
                
            }
        }
    }
    return 0;
}

