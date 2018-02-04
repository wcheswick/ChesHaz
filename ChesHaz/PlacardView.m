//
//  PlacardView.m
//  ChesHaz
//
//  Created by ches on 18/2/4.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import "PlacardView.h"

@interface PlacardView ()

@property(nonatomic, strong)    Substance *substance;

@property (nonatomic, strong)   UILabel *healthLabel;
@property (nonatomic, strong)   UILabel *flammabilityLabel;
@property (nonatomic, strong)   UILabel *instabilityLabel;
@property (nonatomic, strong)   UILabel *specialLabel;

@end

@implementation PlacardView

@synthesize substance;
@synthesize healthLabel, flammabilityLabel, instabilityLabel, specialLabel;

- (id)init {
    self = [super init];
    if (self) {
        substance = nil;
        self.frame = CGRectMake(0, 0, 150, 150);
        NSURL *nfpaURL = [[NSBundle mainBundle] URLForResource:@"nfpadb" withExtension:@""];
        if (!nfpaURL) {
            NSLog(@"inconceivable, nfpa database missing");
        }
        NSURL *placardImageURL = [[NSBundle mainBundle] URLForResource:@"ergdb" withExtension:@""];
        if (!placardImageURL) {
            NSLog(@"inconceivable, placard image missing");
        }
        self.image = [UIImage imageWithContentsOfFile:placardImageURL.absoluteString];
        
        healthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        healthLabel.textAlignment = NSTextAlignmentCenter;
        healthLabel.text = @"h";
        healthLabel.font = [UIFont systemFontOfSize:18.0];
        healthLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        healthLabel.opaque = NO;
        healthLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:healthLabel];
        
        flammabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        flammabilityLabel.textAlignment = NSTextAlignmentCenter;
        flammabilityLabel.text = @"f";
        flammabilityLabel.font = [UIFont systemFontOfSize:18.0];
        flammabilityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        flammabilityLabel.opaque = NO;
        flammabilityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:flammabilityLabel];
        
        instabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        instabilityLabel.textAlignment = NSTextAlignmentCenter;
        instabilityLabel.text = @"i";
        instabilityLabel.font = [UIFont systemFontOfSize:18.0];
        instabilityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        instabilityLabel.opaque = NO;
        instabilityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:instabilityLabel];
        
        specialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        specialLabel.textAlignment = NSTextAlignmentCenter;
        specialLabel.text = @"S";
        specialLabel.font = [UIFont systemFontOfSize:18.0];
        specialLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        specialLabel.opaque = NO;
        specialLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:specialLabel];

    }
    return self;
}

- (void) useSubstance:(Substance *)s {
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
