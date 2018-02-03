//
//  Substance.h
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum HazardFlags {
    HazTIH = 1, // toxic inhalation
    HazCBW = 2, // chemical/biological warfare
    HazWR = 4,  // water reaction
} HazardFlags;

@interface Substance : NSObject {
    int number;             // UN/NA number from ERG db
    NSString *numberURL;    // https://cameochemicals.noaa.gov/unna/1003
    NSString *guideNumber;  // ERG handling guide number
    NSString *guideURL;     // ERG handling guide URL
    NSString *description;
    HazardFlags hazardFlags;
    
    NSString *dataSheetURL; // from NFPA704 data
    NSString *NFPAnumbers;  // health, flammability, instability
    NSString *special;      // special entry, plus description
    
    NSString *hazardClass;  // From wikipedia
    NSString *htmlDescription;
}

@property (assign)              int number;
@property (nonatomic, strong)   NSString *numberURL;
@property (nonatomic, strong)   NSString *guideNumber;
@property (nonatomic, strong)   NSString *guideURL;
@property (nonatomic, strong)   NSString *description;
@property (assign)              HazardFlags hazardFlags;

@property (nonatomic, strong)   NSString *dataSheetURL;
@property (nonatomic, strong)   NSString *NFPAnumbers;
@property (nonatomic, strong)   NSString *special;

@property (nonatomic, strong)   NSString *hazardClass;
@property (nonatomic, strong)   NSString *htmlDescription;

- (id)initWithERGDBLine:(NSString *) line;
- (void) addNFPA704DataLine: (NSString *) line;
- (void) addwikiLine: (NSString *) line;

@end
