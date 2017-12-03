//
//  Substance.h
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Substance : NSObject {
    int number;
    NSString *numberURL;
    NSString *guideNumber;
    NSString *guideURL;
    NSString *description;
    NSString *flags;
}

@property (assign)              int number;
@property (nonatomic, strong)   NSString *numberURL;
@property (nonatomic, strong)   NSString *guideNumber;
@property (nonatomic, strong)   NSString *guideURL;
@property (nonatomic, strong)   NSString *description;
@property (nonatomic, strong)    NSString *flags;

- (id)initWithDBLine:(NSString *) line;

@end
