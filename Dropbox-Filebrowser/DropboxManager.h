//
//  DropboxManager.h
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <DropboxSDK/DropboxSDK.h>

@interface DropboxManager : NSObject <DBRestClientDelegate>

@property(nonatomic, strong) NSString *documentsDirectory;

+ (DropboxManager*) dbManager;
- (DBRestClient*) restClient;

@end
