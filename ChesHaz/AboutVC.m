//
//  AboutVC.m
//  ChesHaz
//
//  Created by ches on 18/2/2.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//


#import "AboutVC.h"

@interface AboutVC ()
    
@property (nonatomic, strong)   WKWebView *webView;

@end

@implementation AboutVC

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setOpaque:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.editing = NO;
    
    self.title = @"About ChesHaz";
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self
                                      action:@selector(doDone:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;

    webView = [[WKWebView alloc] init];
    webView.navigationDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:webView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    webView.frame = CGRectMake(0, 0,
                               self.view.frame.size.width, self.view.frame.size.height);
    [webView setNeedsLayout];
    
    NSURL *aboutURL = [[NSBundle mainBundle]
                       URLForResource:@"about" withExtension:@"html"];
    [webView loadFileURL:aboutURL allowingReadAccessToURL:aboutURL];
    [webView setNeedsDisplay];
}

-(IBAction) doDone: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
