//
//  DropboxPhotoPreviewController.h
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxPhotoPreviewController : UIViewController <DBRestClientDelegate>

@property(nonatomic, weak) UIPopoverController *popover;

- (id)initWithPath:(NSString*)_path title:(NSString*)tit;

@end
