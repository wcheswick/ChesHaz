//
//  OfficialVC.m
//  ChesHaz
//
//  Created by ches on 18/2/2.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import "OfficialVC.h"

@interface OfficialVC ()

@property (nonatomic, strong)   WKWebView *webView;

@end

@implementation OfficialVC

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setOpaque:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.title = @"Links to Official Sites";
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self
                                      action:@selector(doDone:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    webView = [[WKWebView alloc] init];
    webView.navigationDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:webView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(swipeRight:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    webView.frame = self.view.frame;
    [webView setNeedsLayout];
    
    NSString *officialHTML =  @"<html><head>\n"
    @"<style>\n"
    @"body {\n"
    @"  font-family: system, -apple-system, BlinkMacSystemFont,\n"
    @"      \"Helvetica Neue\", \"Lucida Grande\"\n"
    @"} </style>\n"
    @"<meta name=\"viewport\" content=\"initial-scale=1.3\"/>\n"
    @"</head><body>\n";

#ifdef notyet
    officialHTML = [officialHTML stringByAppendingString:[NSString stringWithFormat:
                                                      @"<a href=\"%@\">NOAA UN/NA chemical description</a></p>\n",
                                                      substanceURL]];
#endif
    
    officialHTML = [officialHTML stringByAppendingString:[NSString stringWithFormat:
                                                      @"<p><small>This information is provided for educational purposes from databases. "
                                                      @"While it is believed to be accurate, first responders "
                                                      @"should probably use official apps to access data in emergency situations.</small></p>"
                                                      @"</body></html>\n"]];
    [webView loadHTMLString:officialHTML baseURL:nil];
    [webView setNeedsDisplay];
}

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) doDone: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
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
