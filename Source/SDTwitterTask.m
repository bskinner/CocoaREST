//
//  SDTwitterTask.m
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDTwitterTask.h"

#import "SDTwitterTaskManager.h"

#import "SDNetTask+Subclassing.h"

@interface SDTwitterTask (Private)
@end


@implementation SDTwitterTask

@synthesize count;
@synthesize page;
@synthesize rpp;
@synthesize text;
@synthesize format;
@synthesize q;
@synthesize callback;
@synthesize gcontext;
@synthesize langpair;
@synthesize key;
@synthesize v;
@synthesize ands;
@synthesize phrase;
@synthesize ors;
@synthesize nots;
@synthesize from;
@synthesize to;
@synthesize tude;
@synthesize since_id;
@synthesize olderThanStatusID;
@synthesize newerThanStatusID;
@synthesize inReplyToStatusID;
@synthesize firstUsersID;
@synthesize secondUsersID;
@synthesize statusID;
@synthesize userID;
@synthesize screenName;
@synthesize screenNameOrUserID;
@synthesize enableDeviceNotificationsAlso;
@synthesize deviceType;
@synthesize profileName;
@synthesize profileEmail;
@synthesize profileWebsite;
@synthesize profileLocation;
@synthesize profileDescription;
@synthesize profileBackgroundColor;
@synthesize profileTextColor;
@synthesize profileLinkColor;
@synthesize profileSidebarFillColor;
@synthesize profileSidebarBorderColor;
@synthesize shouldTileBackgroundImage;
@synthesize imageToUpload;

- (id) initWithManager:(SDTwitterTaskManager*)newManager {
	if (self = [super initWithManager:newManager]) {
		twitterManager = newManager;
		
		type = SDTwitterTaskDoNothing;
		errorCode = SDNetTaskErrorNone;
		deviceType = SDTwitterDeviceTypeNotYetSet;
		
		page = 1;
		count = 0;
	}
	return self;
}

- (void) dealloc {
	[q release], q = nil;
	[text release], text = nil;
	[format release], format = nil;
	[since_id release], since_id = nil;
	
	[olderThanStatusID release], olderThanStatusID = nil;
	[newerThanStatusID release], newerThanStatusID = nil;
	[inReplyToStatusID release], inReplyToStatusID = nil;
	
	[firstUsersID release], firstUsersID = nil;
	[secondUsersID release], secondUsersID = nil;
	
	[statusID release], statusID = nil;
	[userID release], userID = nil;
	[screenName release], screenName = nil;
	[screenNameOrUserID release], screenNameOrUserID = nil;
	
	[profileName release], profileName = nil;
	[profileEmail release], profileEmail = nil;
	[profileWebsite release], profileWebsite = nil;
	[profileLocation release], profileLocation = nil;
	[profileDescription release], profileDescription = nil;
	
	[profileBackgroundColor release], profileBackgroundColor = nil;
	[profileTextColor release], profileTextColor = nil;
	[profileLinkColor release], profileLinkColor = nil;
	[profileSidebarFillColor release], profileSidebarFillColor = nil;
	[profileSidebarBorderColor release], profileSidebarBorderColor = nil;
	
	[imageToUpload release], imageToUpload = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone {
	SDTwitterTask *task = [super copyWithZone:zone];
	
	task.count = self.count;
	task.page = self.page;
	task.rpp = self.rpp;
	task.text = self.text;
	task.q = self.q;
	task.callback = self.callback;
	task.gcontext = self.gcontext;
	task.langpair = self.langpair;
	task.key = self.key;
	task.v = self.v;
	task.format = self.format;
	task.since_id = self.since_id;
	task.olderThanStatusID = self.olderThanStatusID;
	task.newerThanStatusID = self.newerThanStatusID;
	task.inReplyToStatusID = self.inReplyToStatusID;
	task.firstUsersID = self.firstUsersID;
	task.secondUsersID = self.secondUsersID;
	task.statusID = self.statusID;
	task.userID = self.userID;
	task.screenName = self.screenName;
	task.profileName = self.profileName;
	task.profileEmail = self.profileEmail;
	task.profileWebsite = self.profileWebsite;
	task.profileLocation = self.profileLocation;
	task.profileDescription = self.profileDescription;
	task.profileBackgroundColor = self.profileBackgroundColor;
	task.profileTextColor = self.profileTextColor;
	task.profileLinkColor = self.profileLinkColor;
	task.profileSidebarFillColor = self.profileSidebarFillColor;
	task.profileSidebarBorderColor = self.profileSidebarBorderColor;
	task.enableDeviceNotificationsAlso = self.enableDeviceNotificationsAlso;
	task.deviceType = self.deviceType;
	task.shouldTileBackgroundImage = self.shouldTileBackgroundImage;
	task.imageToUpload = self.imageToUpload;
	
	return task;
}

- (id) copyWithNextPage {
	SDTwitterTask *task = [self copy];
	task.page++;
	return task;
}

- (BOOL) shouldUseBasicHTTPAuthentication {
	return YES;
}

// MARK: -
// MARK: Before-response Methods

- (BOOL) validateType {
	return (type > SDTwitterTaskDoNothing && type < SDTwitterTaskMAX);
}

- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request {
	[request setValue:twitterManager.appName forHTTPHeaderField:@"X-Twitter-Client"];
	[request setValue:twitterManager.appVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
	[request setValue:twitterManager.appWebsite forHTTPHeaderField:@"X-Twitter-Client-URL"];
}

- (BOOL) isMultiPartDataBasedOnTaskType {
	BOOL multiPartData = NO;
	switch (type) {
		case SDTwitterTaskUpdateProfileImage:
		case SDTwitterTaskUpdateProfileBackgroundImage:
			multiPartData = YES;
			break;
	}
	return multiPartData;
}

- (SDHTTPMethod) methodBasedOnTaskType {
	SDHTTPMethod method = SDHTTPMethodGet;
	switch (type) {
		case SDTwitterTaskCreateStatus:
		case SDTwitterTaskDeleteStatus:
		case SDTwitterTaskCreateDirectMessage:
		case SDTwitterTaskDeleteDirectMessage:
		case SDTwitterTaskFollowUser:
		case SDTwitterTaskUnfollowUser:
		case SDTwitterTaskUpdateDeliveryDevice:
		case SDTwitterTaskUpdateProfileColors:
		case SDTwitterTaskUpdateProfileImage:
		case SDTwitterTaskUpdateProfileBackgroundImage:
		case SDTwitterTaskUpdateProfile:
		case SDTwitterTaskFavorStatus:
		case SDTwitterTaskUnavorStatus:
		case SDTwitterTaskEnableDeviceNotificationsFromUser:
		case SDTwitterTaskDisableDeviceNotificationsFromUser:
		case SDTwitterTaskBlockUser:
		case SDTwitterTaskUnblockUser:
			method = SDHTTPMethodPost;
			break;
	}
	return method;
}

- (NSString*) URLStringBasedOnTaskType {
	NSString *URLStrings[SDTwitterTaskMAX]; // is this a bad convention? no seriously, i dont know...
	
	URLStrings[SDTwitterTaskGetPublicTimeline] = @"http://twitter.com/statuses/public_timeline.json";
	URLStrings[SDTwitterTaskGetPersonalTimeline] = @"http://twitter.com/statuses/friends_timeline.json";
	URLStrings[SDTwitterTaskGetUsersTimeline] = @"http://twitter.com/statuses/user_timeline.json";
	URLStrings[SDTwitterTaskGetMentions] = @"http://twitter.com/statuses/mentions.json";
	
	URLStrings[SDTwitterTaskGetStatus] = @"http://twitter.com/statuses/show.json";
	URLStrings[SDTwitterTaskCreateStatus] = @"http://twitter.com/statuses/update.json";
	URLStrings[SDTwitterTaskDeleteStatus] = @"http://twitter.com/statuses/destroy.json";
	
	URLStrings[SDTwitterTaskGetUserInfo] = @"http://twitter.com/users/show.json";
	URLStrings[SDTwitterTaskGetUsersFriends] = @"http://twitter.com/statuses/friends.json";
	URLStrings[SDTwitterTaskGetUsersFollowers] = @"http://twitter.com/statuses/followers.json";
	
	URLStrings[SDTwitterTaskGetReceivedDirectMessages] = @"http://twitter.com/direct_messages.json";
	URLStrings[SDTwitterTaskGetSentDirectMessages] = @"http://twitter.com/direct_messages/sent.json";
	URLStrings[SDTwitterTaskCreateDirectMessage] = @"http://twitter.com/direct_messages/new.json";
	URLStrings[SDTwitterTaskDeleteDirectMessage] = @"http://twitter.com/direct_messages/destroy.json";
	
	URLStrings[SDTwitterTaskFollowUser] = @"http://twitter.com/friendships/create.json";
	URLStrings[SDTwitterTaskUnfollowUser] = @"http://twitter.com/friendships/destroy.json";
	URLStrings[SDTwitterTaskCheckIfUserFollowsUser] = @"http://twitter.com/friendships/exists.json";
	
	URLStrings[SDTwitterTaskGetIDsOfFriends] = @"http://twitter.com/friends/ids.json";
	URLStrings[SDTwitterTaskGetIDsOfFollowers] = @"http://twitter.com/followers/ids.json";
	
	URLStrings[SDTwitterTaskVerifyCredentials] = @"http://twitter.com/account/verify_credentials.json";
	URLStrings[SDTwitterTaskUpdateDeliveryDevice] = @"http://twitter.com/account/update_delivery_device.json";
	URLStrings[SDTwitterTaskUpdateProfileColors] = @"http://twitter.com/account/update_profile_colors.json";
	URLStrings[SDTwitterTaskUpdateProfileImage] = @"http://twitter.com/account/update_profile_image.json";
	URLStrings[SDTwitterTaskUpdateProfileBackgroundImage] = @"http://twitter.com/account/update_profile_background_image.json";
	URLStrings[SDTwitterTaskUpdateProfile] = @"http://twitter.com/account/update_profile.json";
	
	URLStrings[SDTwitterTaskGetFavoriteStatuses] = @"http://twitter.com/favorites.json";
	URLStrings[SDTwitterTaskFavorStatus] = @"http://twitter.com/favorites/create.json";
	URLStrings[SDTwitterTaskUnavorStatus] = @"http://twitter.com/favorites/destroy.json";
	
	URLStrings[SDTwitterTaskEnableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/follow.json";
	URLStrings[SDTwitterTaskDisableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/leave.json";
	
	URLStrings[SDTwitterTaskBlockUser] = @"http://twitter.com/blocks/create.json";
	URLStrings[SDTwitterTaskUnblockUser] = @"http://twitter.com/blocks/destroy.json";
	URLStrings[SDTwitterTaskCheckIfBlockingUser] = @"http://twitter.com/blocks/exists.json";
	URLStrings[SDTwitterTaskGetBlockedUsers] = @"http://twitter.com/blocks/blocking.json";
	URLStrings[SDTwitterTaskGetBlockedUserIDs] = @"http://twitter.com/blocks/blocking/ids.json";
	
	URLStrings[SDTwitterTaskSearch] = @"http://search.twitter.com/search.json";
	URLStrings[SDTwitterTaskTrends] = @"http://search.twitter.com/trends.json";
	URLStrings[SDTwitterTaskGetRateLimitStatus] = @"http://twitter.com/account/rate_limit_status.json";
	URLStrings[SDTwitterTaskGetUserInfoUsingYQL] = @"http://query.yahooapis.com/v1/public/yql";
	
	return URLStrings[type];
}

- (SDParseFormat) parseFormatBasedOnTaskType {
	// there may be some calls which return just a single string, without JSON formatting
	// if so, then we need to make this method conditional
	return SDParseFormatJSON;
}

- (void) addParametersToDictionary:(NSMutableDictionary*)parameters {
	if (count > 0)
		[parameters setObject:[NSString stringWithFormat:@"%d", (count)] forKey:@"count"];
	
	if (page > 1)
		[parameters setObject:[NSString stringWithFormat:@"%d", (page)] forKey:@"page"];
	
	if (text) {
		if (type == SDTwitterTaskCreateStatus)
			[parameters setObject:text forKey:@"status"];
		else if (type == SDTwitterTaskCreateDirectMessage)
			[parameters setObject:text forKey:@"text"];
	}
	
	if(q)
		[parameters setObject:q forKey:@"q"];
	
	if(callback)
		[parameters setObject:callback forKey:@"callback"];
	if(gcontext)
		[parameters setObject:gcontext forKey:@"context"];
	if(langpair)
		[parameters setObject:langpair forKey:@"langpair"];
	if(key)
		[parameters setObject:key forKey:@"key"];
	if(v)
		[parameters setObject:v forKey:@"v"];	
	
	if(ands)
		[parameters setObject:ands forKey:@"ands"];

	if(phrase)
		[parameters setObject:phrase forKey:@"phrase"];

	if(ors)
		[parameters setObject:ors forKey:@"ors"];

	if(nots)
		[parameters setObject:nots forKey:@"nots"];

	if(from)
		[parameters setObject:from forKey:@"from"];

	if(to)
		[parameters setObject:to forKey:@"to"];

	if(tude)
		[parameters setObject:tude forKey:@"tude"];
	
	if(rpp)
		[parameters setObject:[NSString stringWithFormat:@"%d", (rpp)] forKey:@"rpp"];

	if(format)
		[parameters setObject:format forKey:@"format"];

	if (newerThanStatusID)
		[parameters setObject:newerThanStatusID forKey:@"since_id"];
	
	if (since_id)
		[parameters setObject:since_id forKey:@"since_id"];
	
	if (olderThanStatusID)
		[parameters setObject:olderThanStatusID forKey:@"max_id"];
	
	if (userID)
		[parameters setObject:userID forKey:@"user_id"];
	
	if (screenName)
		[parameters setObject:screenName forKey:@"screen_name"];
	
	if (screenNameOrUserID)
		[parameters setObject:screenNameOrUserID forKey:@"id"];
	
	if (statusID)
		[parameters setObject:statusID forKey:@"id"];
	
	if (imageToUpload)
		[parameters setObject:imageToUpload forKey:@"image"];
	
	if (enableDeviceNotificationsAlso)
		[parameters setObject:@"true" forKey:@"follow"];
	
	if (firstUsersID)
		[parameters setObject:firstUsersID forKey:@"user_a"];
	
	if (secondUsersID)
		[parameters setObject:secondUsersID forKey:@"user_b"];
	
	if (profileName)
		[parameters setObject:profileName forKey:@"name"];
	
	if (profileEmail)
		[parameters setObject:profileEmail forKey:@"email"];
	
	if (profileWebsite)
		[parameters setObject:profileWebsite forKey:@"url"];
	
	if (profileLocation)
		[parameters setObject:profileLocation forKey:@"location"];
	
	if (profileDescription)
		[parameters setObject:profileDescription forKey:@"description"];
	
	if (deviceType != SDTwitterDeviceTypeNotYetSet) {
		NSString *deviceTypeString = @"none";
		if (deviceType == SDTwitterDeviceTypeInstantMessage)
			deviceTypeString = @"im";
		else if (deviceType == SDTwitterDeviceTypeSMS)
			deviceTypeString = @"sms";
		[parameters setObject:deviceTypeString forKey:@"device"];
	}
	
	if (profileBackgroundColor)
		[parameters setObject:[profileBackgroundColor hexValue] forKey:@"profile_background_color"];
	
	if (profileTextColor)
		[parameters setObject:[profileTextColor hexValue] forKey:@"profile_text_color"];
	
	if (profileLinkColor)
		[parameters setObject:[profileLinkColor hexValue] forKey:@"profile_link_color"];
	
	if (profileSidebarFillColor)
		[parameters setObject:[profileSidebarFillColor hexValue] forKey:@"profile_sidebar_fill_color"];
	
	if (profileSidebarBorderColor)
		[parameters setObject:[profileSidebarBorderColor hexValue] forKey:@"profile_sidebar_border_color"];
	
	if (shouldTileBackgroundImage)
		[parameters setObject:@"true" forKey:@"tile"];
	
	if (type == SDTwitterTaskCreateStatus)
		[parameters setObject:twitterManager.appName forKey:@"source"];
}

// MARK: -
// MARK: After-response Methods

- (void) handleHTTPResponse:(NSHTTPURLResponse*)response {
	if (response == nil)
		return;
	
	NSString *limitMaxAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Limit"];
	NSString *limitRemainingAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Remaining"];
	NSString *limitResetEpochTime = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Reset"];
	
	twitterManager.limitMaxAmount = [limitMaxAmount intValue];
	twitterManager.limitRemainingAmount = [limitRemainingAmount intValue];
	twitterManager.limitResetEpochDate = [limitResetEpochTime doubleValue];
}

- (void) sendResultsToDelegate {
	if ([results isKindOfClass:[NSDictionary class]] && [[results allKeys] containsObject:@"error"]) {
		error = [NSError errorWithDomain:@"SDNetDomain" code:SDNetTaskErrorServiceDefinedError userInfo:nil];
		[self sendErrorToDelegate];
	}
	else
		[super sendResultsToDelegate];
}

//- (void) sendErrorToDelegate {
//}

@end
