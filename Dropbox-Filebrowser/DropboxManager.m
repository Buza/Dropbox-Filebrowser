//
//  DropboxManager.m
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import "DropboxManager.h"

@interface DropboxManager()
@property(nonatomic, strong) DBRestClient *restClient;
@end

@implementation DropboxManager

@synthesize restClient;
@synthesize documentsDirectory;

+(DropboxManager*) dbManager
{
    static dispatch_once_t once;
    static DropboxManager *_dbMan;
    dispatch_once(&once, ^ { _dbMan = [[self alloc] init];});
    return _dbMan;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    }
    return self;
}

- (DBRestClient*)restClient
{
    if (!restClient)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return restClient;
}

@end
