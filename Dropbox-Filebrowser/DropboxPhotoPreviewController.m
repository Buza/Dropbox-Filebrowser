//
//  DropboxPhotoPreviewController.m
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import "DropboxPhotoPreviewController.h"
#import "DropboxManager.h"

@interface DropboxPhotoPreviewController ()
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *fileTitle;
@property(nonatomic, copy) NSString *imagePath;
@property(nonatomic, copy) NSString *localPath;
@property(nonatomic, weak) UIActivityIndicatorView *loadSpinner;
@end

@implementation DropboxPhotoPreviewController

@synthesize path;
@synthesize popover;
@synthesize localPath;
@synthesize imagePath;
@synthesize fileTitle;
@synthesize loadSpinner;

- (id)initWithPath:(NSString*)myPath title:(NSString*)myTitle
{
    self = [super init];
    if (self)
    {
        self.loadSpinner = nil;
        self.localPath = nil;
        self.fileTitle = myTitle;
        self.path = myPath;
        self.imagePath = nil;
        self.popover = nil;
        
        NSArray *pcs = [path componentsSeparatedByString:@"/"];
        if([pcs count] > 0)
        {
            self.title = [pcs lastObject];
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated
{
    DropboxManager *dbManager = [DropboxManager dbManager];
    
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *imgDir = [[NSString alloc] initWithFormat:@"%@/dropboximages", dbManager.documentsDirectory];
    if(![fm fileExistsAtPath:imgDir isDirectory:&isDir])
    {
        NSError *err = nil;
        [fm createDirectoryAtPath:imgDir withIntermediateDirectories:YES attributes:nil error:&err];
    }
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                                    UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleLeftMargin;
    
    if([[self.path componentsSeparatedByString:@"/"] count] > 0)
    {
        const NSInteger spinnerSize = 100;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadSpinner = spinner;
        
        loadSpinner.frame = CGRectMake(self.view.frame.size.width/2-spinnerSize/2,
                                       self.view.frame.size.height/2-spinnerSize/2,
                                       spinnerSize,
                                       spinnerSize);
        [self.view addSubview:self.loadSpinner];
        [loadSpinner startAnimating];
        
        NSString *cleanFilename = [[self.path componentsSeparatedByString:@"/"] lastObject];
        cleanFilename = [cleanFilename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        imgDir = [imgDir stringByAppendingFormat:@"/%@", cleanFilename];
        
        self.imagePath = imgDir;
        [dbManager restClient].delegate = self;
        [[dbManager restClient] loadFile:self.fileTitle intoPath:imgDir];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    DropboxManager *dbManager = [DropboxManager dbManager];
    [[dbManager restClient] cancelAllRequests];
}

-(void) dealloc
{
}

-(CGSize) getBoundedSize:(CGSize)originalSize forWidth:(NSInteger)width height:(NSInteger)height
{
    CGFloat desiredWidth;
    CGFloat desiredHeight;
    
    if(originalSize.width > originalSize.height)
    {
        desiredWidth = width;
        desiredHeight = 1./(originalSize.width/desiredWidth) * originalSize.height;
        
    } else if(originalSize.width < originalSize.height)
    {
        desiredHeight = height;
        desiredWidth = 1./(originalSize.height/desiredHeight) * originalSize.width;
    } else
    {
        desiredWidth = width;
        desiredHeight = height;
    }
    
    return CGSizeMake(desiredWidth, desiredHeight);
}

- (void) restClient:(DBRestClient*)client loadedFile:(NSString*)locPath
{
    [self.loadSpinner removeFromSuperview];
    
    UIImage *photo = [UIImage imageWithContentsOfFile:self.imagePath];
    
    UIImageView *photoView = [[UIImageView alloc] initWithImage:photo];
    [self.view addSubview:photoView];

    CGSize desiredSize = [self getBoundedSize:photoView.frame.size forWidth:self.view.frame.size.width height:self.view.frame.size.height];

    photoView.frame = CGRectMake(ceil(self.view.frame.size.width/2 - (desiredSize.width-10)/2),
                                  5 + ceil(self.view.frame.size.height/2-desiredSize.height/2),
                                  desiredSize.width-10,
                                  desiredSize.height-10);

    self.localPath = locPath;
    photoView.autoresizingMask = self.view.autoresizingMask;
    photoView.layer.opacity = 0;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         photoView.layer.opacity = 1;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The photo you selected could not be found."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
