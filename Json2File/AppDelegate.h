//
//  AppDelegate.h
//  Json2File
//
//  Created by NguyenTheQuan on 2014/05/14.
//  Copyright (c) 2014年. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField *_fileName;
    IBOutlet NSTextView *_jsonCodeTextView;
    
    NSMutableArray *_classHeaderArray;
    NSMutableArray *_classImpleArray;
    NSString *_mainClassName;
}

@property (assign) IBOutlet NSWindow *window;

@end
