//
//  Log.h
//  ChesHaz
//
//  Created by William Cheswick on 2/27/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Log : NSObject {
    NSString *text;
}

@property (nonatomic, strong)   NSString *text;

- (void) prependToLog: (NSString *) s;
- (void) save;

@end
