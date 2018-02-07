//
//  OfficialVC.h
//  ChesHaz
//
//  Created by ches on 18/2/2.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "Substance.h"

@interface OfficialVC : UIViewController <WKNavigationDelegate>

- (id)initWithSubstance:(Substance *) s;

@end
