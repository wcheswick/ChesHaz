//
//  Log.m
//  ChesHaz
//
//  Created by William Cheswick on 2/27/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import "Log.h"

#define LOG_FILE    @"Log"

@implementation Log

@synthesize text;

- (id)init {
    self = [super init];
    if (self) {
        NSError *error;
        text = [NSString stringWithContentsOfFile:[self logPath]
                                      encoding:NSUTF8StringEncoding
                                           error:&error];
        if (!text) {
            NSLog(@"Creating log");
            text = @"";
            [self save];
        }
        NSLog(@"log length %lu", (unsigned long)[text length]);
    }
    return self;
}

- (NSString *) now {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [dateFormatter setDateFormat:@"dd MMM HH:mm"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    return [dateFormatter stringFromDate:[NSDate date]];
}

// place the lines at the beginning of the log file

- (void) prependToLog: (NSString *) s {
    text = [NSString stringWithFormat:@"%@  %@\n%@",
            [self now], s, text];
    [self save];
}

- (void) save {
    NSError *error;
    [text writeToFile:[self logPath]
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:&error];
    if (error)
        NSLog(@"inconceivable: log write error %@", [error localizedDescription]);
}

- (NSString *) logPath {
    return [@"./" stringByAppendingString:LOG_FILE];
}

@end
