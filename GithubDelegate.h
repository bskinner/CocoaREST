//
//  GithubDelegate.h
//  CocoaREST
//
//  Created by Clint Shryock on 3/6/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDGithubTaskManager.h"

@interface GithubDelegate : NSObject {

	SDGithubTaskManager *manager;
	
	BOOL isWaiting;
	NSArray *repositories;
    NSArray *forks;
    NSDictionary *user;
    NSArray *issues;
    
	IBOutlet NSTableView *repositoriesView;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *userLabel;
	IBOutlet NSTextField *apiTokenField;
	IBOutlet NSPopUpButton *taskTypeButton;
	IBOutlet NSImageView *profileImageView;
}

@property BOOL isWaiting;
@property (copy) NSArray *repositories;
@property (copy) NSArray *issues;
@property (copy) NSArray *forks;
@property (copy) NSDictionary *user;

- (IBAction) runTask:(id)sender;

@end
