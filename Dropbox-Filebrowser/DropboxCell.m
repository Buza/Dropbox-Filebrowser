//
//  DropboxCell.m
//  Dropbox-Filebrowser
//
//  Created by buza on 11/27/12.
//  Copyright (c) 2012 buzamoto. All rights reserved.
//

#import "DropboxCell.h"

@implementation DropboxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x,
                                                             self.contentView.frame.size.height - 1,
                                                             self.contentView.frame.size.width,
                                                             1)];
        border.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
        [self.contentView addSubview:border];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
