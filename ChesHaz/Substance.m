//
//  Substance.m
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Substance.h"

@implementation Substance

@synthesize number, numberURL;
@synthesize guideNumber, guideURL;
@synthesize description;
@synthesize flags;


- (id)initWithERGDBLine:(NSString *) line {
    self = [super init];
    if (self) {
        NSArray *fields = [line componentsSeparatedByString:@"\t"];
        if ([fields count] != 6) {
            NSLog(@"db error, wrong field count:%@", line);
            return nil;
        }
        number = [(NSString *)[fields objectAtIndex:0] intValue];
        numberURL = [fields objectAtIndex:1];
        guideNumber = [fields objectAtIndex:2];
        guideURL = [fields objectAtIndex:3];
        description = [fields objectAtIndex:4];
        flags = [fields objectAtIndex:5];
    }
    return self;
}

@end
