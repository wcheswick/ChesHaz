//
//  LogVC.h
//  ChesHaz
//
//  Created by William Cheswick on 2/27/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "Log.h"

@interface LogVC : UIViewController
<UITextViewDelegate,
UIScrollViewDelegate,
MFMailComposeViewControllerDelegate> {
    Log *log;
}

@property (nonatomic, strong)   Log *log;

- (id) initWithLog:(Log *) log;

@end


