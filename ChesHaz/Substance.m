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
@synthesize hazardFlags;

@synthesize dataSheetURL, NFPAnumbers, special;
@synthesize hazardClass, htmlDescription;

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
        NSString *haz = [fields objectAtIndex:5];
        hazardFlags = (([haz containsString:@"TIH"]) ? HazTIH : 0) |
            (([haz containsString:@"CBW"]) ? HazCBW : 0) |
            (([haz containsString:@"WR"]) ? HazWR : 0);
    }
    return self;
}

- (void) addNFPA704DataLine: (NSString *) line {
    NSArray *fields = [line componentsSeparatedByString:@"\t"];
    if ([fields count] < 3 || [fields count] > 4) {
        NSLog(@"NFPA db error, wrong field count:%@", line);
        return;
    }
    dataSheetURL = [fields objectAtIndex:1];
    NFPAnumbers = [fields objectAtIndex:2];
    if ([fields count] == 4)
        special = [fields objectAtIndex:2];
    else
        special = nil;
}

- (void) addwikiLine: (NSString *) line {
    NSArray *fields = [line componentsSeparatedByString:@"\t"];
    if ([fields count] != 3) {
        NSLog(@"Wiki db error, wrong field count:%@", line);
        return;
    }
    hazardClass = [fields objectAtIndex:1];
    htmlDescription = [fields objectAtIndex:2];
}

@end
