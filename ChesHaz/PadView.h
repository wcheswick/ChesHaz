//
//  PadView.h
//  ChesHaz
//
//  Created by William Cheswick on 2/16/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PadDelegate <NSObject>
@required

- (BOOL) padTextIsOK: (NSString *)text;

@end

@interface PadView : UIView {
    NSString *keypadText;
}

@property (nonatomic, strong)   NSString *keypadText;

- (id)initWithTarget:(id<PadDelegate>) t keys:(NSString *)keys;
- (id)initWithTarget:(id<PadDelegate>) t;

- (void) scrambleKeys;
- (void) enabledKeys: (NSString *)enabled;
- (void) enableBackspace: (BOOL)e;
- (void) enableClear: (BOOL) e;

- (void) setupForView:(UIView *) v toHide:(BOOL)toHide;

@end
