//
//  DropboxFolderController.m
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import "DropboxManager.h"
#import "DropboxFolderController.h"
#import "DropboxPhotoPreviewController.h"

#import "DropboxCell.h"

@interface DropboxBundle : NSObject
@property(readwrite) BOOL loaded;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *size;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *modified;
@end

@implementation DropboxBundle

-(id) init
{
    self = [super init];
    if(self)
    {
        self.loaded = NO;
        self.title = nil;
        self.path = nil;
        self.modified = nil;
        self.size = nil;
    }
    return self;
}

@end

@interface DropboxFolderController ()
{
    NSMutableArray *bundles;
}

@property(nonatomic, copy) NSString *curPath;

@end

@implementation DropboxFolderController

@synthesize curPath;

- (id)initWithStyle:(UITableViewStyle)style searchPath:(NSString*)searchPath
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.popover = nil;
        self.curPath = searchPath;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        bundles = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [bundles removeAllObjects];
}

-(void) viewDidAppear:(BOOL)animated
{
    if([self.curPath isEqualToString:@"/"])
    {
        self.title = @"Dropbox";
    } else
    {
        if([[self.curPath componentsSeparatedByString:@"/"] count] > 0)
        {
            NSString *shortFile = [[self.curPath componentsSeparatedByString:@"/"] lastObject];
            self.title = shortFile;
        } else
            self.title = self.curPath;
    }
    
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = self;
    [[dbManager restClient] loadMetadata:self.curPath withHash:@""];
}

-(void) viewWillDisappear:(BOOL)animated
{
    DropboxManager *dbManager = [DropboxManager dbManager];
    [dbManager restClient].delegate = nil;
    [[dbManager restClient] cancelAllRequests];
}

-(void) searchPath:(NSString*)searchPath
{
    self.curPath = searchPath;
}

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"gif", @"png", nil];
    for (DBMetadata *child in metadata.contents)
    {
        if([child isDirectory])
        {
            DropboxBundle *bun = [DropboxBundle new];
            bun.path = [child path];
            [bundles addObject:bun];
        } else
        {
            NSString *extension = [[child.path pathExtension] lowercaseString];
            if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound)
            {
                NSString *pathComponent = [NSString stringWithFormat:@"photo%d.%@", arc4random()%152345234, extension];
                NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:pathComponent];

                DropboxBundle *bun = [DropboxBundle new];
                bun.title = [child path];
                bun.path = path;
                bun.size = [child humanReadableSize];
                
                NSString *modStr = [[child lastModifiedDate] description];
                if([modStr hasSuffix:@"+0000"])
                {
                    bun.modified = [modStr substringToIndex:[modStr rangeOfString:@"+0000"].location];
                } else
                    bun.modified = modStr;
                
                [bundles addObject:bun];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath
{
    NSInteger i;
    for(i=0;i<[bundles count]; i++)
    {
        DropboxBundle *bun = [bundles objectAtIndex:i];
        if([bun.path isEqualToString:destPath])
        {
            bun.loaded = YES;
            break;
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bundles count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DropboxDataCell";
    
    DropboxCell *cell = (DropboxCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[DropboxCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.imageView.image = nil;
    }
        
    DropboxBundle *bun = [bundles objectAtIndex:indexPath.row];
    if([bun.path hasSuffix:@"jpg"] || [bun.path hasSuffix:@"png"] ||
       [bun.path hasSuffix:@"gif"] || [bun.path hasSuffix:@"jpeg"])
    {
        if(bun.loaded)
        {
            [cell.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            UIImage *thumbnail = [UIImage imageWithContentsOfFile:bun.path];
            
            const NSInteger thumbSize = 40;
            
            CGSize desiredSize = [self getBoundedSize:thumbnail.size forWidth:thumbSize height:thumbSize];
            CGSize itemSize = CGSizeMake(thumbSize, thumbSize);
            
            UIGraphicsBeginImageContext(itemSize);
            CGRect imageRect = CGRectMake(ceil(thumbSize/2 - desiredSize.width/2),
                                          ceil(thumbSize/2 - desiredSize.height/2),
                                          desiredSize.width,
                                          desiredSize.height);
            
            [thumbnail drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
        } else
        {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            const NSInteger spinnerSize = 12;
            spinner.frame = CGRectMake(20 - spinnerSize/2, 20 - spinnerSize/2, spinnerSize, spinnerSize);
            
            [spinner startAnimating];
            
            cell.imageView.image = [UIImage imageNamed:@"EmptyImage.png"];
            
            [cell.imageView addSubview:spinner];
            
            DropboxManager *dbManager = [DropboxManager dbManager];
            [[dbManager restClient] loadThumbnail:bun.title ofSize:@"iphone_bestfit" intoPath:bun.path];
        }
        
        cell.textLabel.text = [[bun.title componentsSeparatedByString:@"/"] lastObject];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@) Modified: %@", bun.size, bun.modified];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        
    } else
    {
        if([[bun.path componentsSeparatedByString:@"/"] count] > 0)
        {
            cell.textLabel.text = [[bun.path componentsSeparatedByString:@"/"] lastObject];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row > [bundles count])
    {
        return;
    }
    
    DropboxBundle *bun = [bundles objectAtIndex:indexPath.row];
    
    //If the user has selected a photo, present a simple photo view controller, where the image can be previewed.
    // Note that if you would like to handle other specific file types (e.g. .pdf, .zip) in a custom manner,
    // it can be done in a similar fashion.
    
    if([bun.path hasSuffix:@"jpg"] || [bun.path hasSuffix:@"png"] || [bun.path hasSuffix:@"gif"] || [bun.path hasSuffix:@"jpeg"])
    {
        DropboxPhotoPreviewController *dfc = [[DropboxPhotoPreviewController alloc] initWithPath:bun.path title:bun.title];
        dfc.popover = self.popover;
        [self.navigationController pushViewController:dfc animated:YES];
        return;
    }

    DropboxFolderController *dfc = [[DropboxFolderController alloc] initWithStyle:UITableViewStylePlain searchPath:bun.path];
    dfc.popover = self.popover;
    dfc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController pushViewController:dfc animated:YES];
}

@end
