//
//  AppDelegate.h
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *navController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)   UINavigationController *navController;


@end

