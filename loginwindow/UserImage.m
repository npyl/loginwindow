//
//  UserImage.m
//  loginwindow
//
//  Created by Nickolas Pylarinos Stamatelatos on 04/07/2022.
//  Copyright © 2022 Nickolas Pylarinos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "UserImage.h"

@implementation UserImage : NSView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSImage *image = [NSImage imageNamed:@"NSUser"];
        
        userImage = [NSImageView imageViewWithImage:image];
        
        
        [self addSubview:userImage];
    }
    return self;
}

@end
