//
//  PlacardView.m
//  ChesHaz
//
//  Created by ches on 18/2/4.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import "Defines.h"
#import "PlacardView.h"

#define FONT_SIZE   20

@interface PlacardView ()

@property(nonatomic, strong)    Substance *substance;

@property (nonatomic, strong)   UIImageView *placardImageView;
@property (nonatomic, strong)   UILabel *healthLabel;
@property (nonatomic, strong)   UILabel *flammabilityLabel;
@property (nonatomic, strong)   UILabel *instabilityLabel;
@property (nonatomic, strong)   UILabel *specialLabel;

@property (nonatomic, strong)   UIImage *placardImage;

@end

@implementation PlacardView

@synthesize substance;
@synthesize placardImageView, placardImage;
@synthesize healthLabel, flammabilityLabel, instabilityLabel, specialLabel;

- (id)init {
    self = [super init];
    if (self) {
        substance = nil;
       placardImage = [UIImage imageNamed:@"NFPA.png"
                                  inBundle:[NSBundle mainBundle]
             compatibleWithTraitCollection:nil];
        if (!placardImage) {
            NSLog(@"inconceivable, placard image didn't load");
        }
        placardImageView = [[UIImageView alloc] init];
        placardImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:placardImageView];
        
        healthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        healthLabel.textAlignment = NSTextAlignmentCenter;
        healthLabel.text = @"h";
        healthLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        healthLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        healthLabel.opaque = NO;
        healthLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:healthLabel];
        
        flammabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        flammabilityLabel.textAlignment = NSTextAlignmentCenter;
        flammabilityLabel.text = @"f";
        flammabilityLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        flammabilityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        flammabilityLabel.opaque = NO;
        flammabilityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:flammabilityLabel];
        
        instabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        instabilityLabel.textAlignment = NSTextAlignmentCenter;
        instabilityLabel.text = @"i";
        instabilityLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        instabilityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        instabilityLabel.opaque = NO;
        instabilityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:instabilityLabel];
        
        specialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        specialLabel.textAlignment = NSTextAlignmentCenter;
        specialLabel.text = @"S";
        specialLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        specialLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        specialLabel.opaque = NO;
        specialLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:specialLabel];
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect f = self.frame;
    f.origin = CGPointMake(0, 0);
    placardImageView.frame = f;
    placardImageView.image = placardImage;
    [placardImageView setNeedsDisplay];
    
    f.size.width = placardImageView.frame.size.width/2.0;
    f.origin.y = self.frame.size.height/2.0 - FONT_SIZE*0.5;
    f.size.height = FONT_SIZE;
    f.origin.x = 0;
    healthLabel.frame = f;
    [healthLabel setNeedsDisplay];
    
    f.origin.x = RIGHT(healthLabel.frame);
    instabilityLabel.frame = f;
    [instabilityLabel setNeedsDisplay];
    
    f.origin.y = ((placardImageView.frame.size.height/2.0) - FONT_SIZE)/2.0;
    f.origin.x = 0;
    f.size.width = placardImageView.frame.size.width;
    flammabilityLabel.frame = f;
    [flammabilityLabel setNeedsDisplay];
    
    f.origin.y += placardImageView.frame.size.height/2.0;
    specialLabel.frame = f;
    [specialLabel setNeedsDisplay];
}

- (void) useSubstance:(Substance *)s {
    NSLog(@"numbers are %@", s.NFPAnumbers);
    substance = s;
    NSArray *numbers = [s.NFPAnumbers componentsSeparatedByString:@" "];
    
    healthLabel.text = [numbers objectAtIndex:0];
    [healthLabel setNeedsDisplay];
    flammabilityLabel.text = [numbers objectAtIndex:1];
    [flammabilityLabel setNeedsDisplay];
    instabilityLabel.text = [numbers objectAtIndex:2];
    [instabilityLabel setNeedsDisplay];
    
    if (numbers.count == 4) {
        specialLabel.text = [numbers objectAtIndex:3];
        [specialLabel setNeedsDisplay];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
