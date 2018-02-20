//
//  ViewController.h
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "PadView.h"


@interface ViewController : UIViewController
    <UIPopoverPresentationControllerDelegate,
        WKNavigationDelegate,
        PadDelegate>

- (void) layoutViews;

@end
