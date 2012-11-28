//
//  DropboxFolderController.h
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxFolderController : UITableViewController <DBRestClientDelegate>

@property(nonatomic, weak) UIPopoverController *popover;

- (id)initWithStyle:(UITableViewStyle)style searchPath:(NSString*)searchPath;

@end
