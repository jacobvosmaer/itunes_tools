//
//  main.m
//  itunes_selection
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
        
        NSArray *theSelection;
        id rawSelection = [iTunes.selection get];
        if ([rawSelection isKindOfClass:[NSArray class]]) {
            theSelection = rawSelection;
        }
        
        iTunesFileTrack *theTrack;
        for (id rawTrack in theSelection) {
            theTrack = [rawTrack get];
            if ([theTrack respondsToSelector:@selector(location)]){
                printf("%s\n", [[[theTrack location] path] UTF8String]);
            }
        }
    }
    return 0;
}
