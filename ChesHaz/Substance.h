//
//  Substance.h
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ERG
@interface Substance : NSObject {
    int number;             // UN/NA number from ERG db
    NSString *numberURL;    // https://cameochemicals.noaa.gov/unna/1003
    NSString *guideNumber;  // ERG handling guide number
    NSString *guideURL;     // ERG handling guide URL
    NSString *description;
    NSString *flags;        // TIH, WR, CBW
    
    
}

@property (assign)              int number;
@property (nonatomic, strong)   NSString *numberURL;
@property (nonatomic, strong)   NSString *guideNumber;
@property (nonatomic, strong)   NSString *guideURL;
@property (nonatomic, strong)   NSString *description;
@property (nonatomic, strong)   NSString *flags;

- (id)initWithERGDBLine:(NSString *) line;

@end
