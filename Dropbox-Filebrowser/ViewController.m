//
//  ViewController.m
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import "Common.h"
#import "ViewController.h"
#import "DropboxFolderController.h"

@interface ViewController ()
@property(nonatomic, strong) UIPopoverController *popover;
@end

@implementation ViewController

@synthesize popover;

- (void)viewDidLoad
{
    self.popover = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:@"dropboxLinked" object:nil];
    
    if([DROPBOX_APP_KEY length] == 0 || [DROPBOX_APP_SECRET length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error."
                                                        message:@"You must specify your Dropbox API Key and secret in Common.h!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [super viewDidLoad];
        return;
    }
    
    //Initialize the Dropbox session.
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
    
    //Wait a few seconds, and display the Dropbox authentication dialog.
    [self performSelector:@selector(authenticateWithDropbox) withObject:nil afterDelay:3];
    
    [super viewDidLoad];
}

-(void) authenticateWithDropbox
{
    if(![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
    } else
    {
        [self showDropboxFileNavigation];
    }
}

//Wait a few seconds, and display the Dropbox authentication dialog.
- (void) dropboxLinked:(id)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSNumber *linkedNum = [[notification userInfo] objectForKey:@"linked"];
    
    if(![linkedNum boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error."
                                                        message:@"Failed to login to Dropbox."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else
    {
        [self showDropboxFileNavigation];
    }
}

-(void) showDropboxFileNavigation
{
    DropboxFolderController *dfc = [[DropboxFolderController alloc] initWithStyle:UITableViewStylePlain searchPath:@"/"];
    UINavigationController *navigationContainer = [[UINavigationController alloc] initWithRootViewController:dfc];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *dbPopover = [[UIPopoverController alloc] initWithContentViewController:navigationContainer];
        navigationContainer.title = @"Dropbox";
        self.popover = dbPopover;
        dfc.popover = dbPopover;
        [dbPopover presentPopoverFromRect:CGRectMake(512, 400, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else
    {
        [self presentViewController:navigationContainer animated:YES completion:^{ }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
