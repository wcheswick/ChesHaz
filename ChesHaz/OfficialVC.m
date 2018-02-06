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
@property (nonatomic, strong)   Substance *substance;

@end

@implementation OfficialVC

@synthesize webView;
@synthesize substance;

- (id)initWithSubstance:(Substance *) s {
    self = [super init];
    if (self) {
        substance = s;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Official online information";
    
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
    
    officialHTML = [officialHTML
                    stringByAppendingString:
                    [NSString stringWithFormat:
                     @"<b>UN/NA %@: Links to official information<b><p>\n"
                     @"<a href=\"%@\">ERG handling guide number %@.</a><p>\n"
                     @"<a href=\"%@\">NFPA 704 data sheet.</a><p>\n"
                     @"</body></html>\n",
                     substance.UNnumber,
                     substance.guideURL, substance.guideNumber,
                     substance.dataSheetURL
                     ]];
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
