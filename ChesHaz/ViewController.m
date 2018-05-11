//
//  ViewController.m
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

// #import <Intents.h>
#import "Defines.h"
#import "AboutVC.h"
#import "OfficialVC.h"
#import "ViewController.h"
#import "PlacardView.h"
#import "Substance.h"
#import "LogVC.h"

#define VERTICAL_LINE   @"❘"

#define LATER   0   // rect value to be filled in later
#define VSEP    9

#define DOT_H           200
#define HAZ_FONT_SIZE   40
#define HAZ_H           (HAZ_FONT_SIZE + 6)

#define HSEP    5
#define BUTTON_FONT_SIZE    30
#define BUTTON_H        (BUTTON_FONT_SIZE*1.2)

#define SET_VIEW_X(v,nx) {CGRect f = (v).frame; f.origin.x = (nx); (v).frame = f;}
#define SET_VIEW_Y(v,ny) {CGRect f = (v).frame; f.origin.y = (ny); (v).frame = f;}

#define SET_VIEW_WIDTH(v,w)     {CGRect f = (v).frame; f.size.width = (w); (v).frame = f;}
#define SET_VIEW_HEIGHT(v,h)    {CGRect f = (v).frame; f.size.height = (h); (v).frame = f;}
#define SET_VIEW_SIZE(v,w,h)     {CGRect f = (v).frame; f.size = CGSizeMake((w), (h)); (v).frame = f;}

@interface ViewController ()

@property (nonatomic, strong)   UIImageView *dotImageView;
@property (nonatomic, strong)   UIButton *digitsView;
@property (nonatomic, strong)   PadView *padView;
@property (nonatomic, strong)   PlacardView *placardView;
@property (nonatomic, strong)   NSString *UNNAnumber;
@property (nonatomic, strong)   WKWebView *webView;
@property (nonatomic, strong)   NSString *dataDate;

@property (nonatomic, strong)   NSArray *flammabilityList;
@property (nonatomic, strong)   NSArray *healthList;
@property (nonatomic, strong)   NSArray *instabilityList;

@property (nonatomic, strong)   NSMutableDictionary *substances;
@property (nonatomic, strong)   Substance *currentSubstance;

@property (nonatomic, strong)   NSMutableDictionary *digitTree;

@property (nonatomic, strong)   Log *log;

@end

@implementation ViewController

@synthesize dotImageView;
@synthesize digitsView;
@synthesize padView;
@synthesize placardView;
@synthesize UNNAnumber;
@synthesize webView;
@synthesize dataDate;

@synthesize flammabilityList;
@synthesize healthList;
@synthesize instabilityList;

@synthesize substances, currentSubstance;

@synthesize digitTree;
@synthesize log;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentSubstance = nil;
    UNNAnumber = @"";
    log = [[Log alloc] init];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.opaque = YES;
    self.title = @"ChesHaz";

    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"?"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(doAbout:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
 
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Log"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(doLog:)];
    rightBarButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    flammabilityList = [NSArray arrayWithObjects:   // starting with 0
                        @"Normally stable, even under fire conditions."
                        @"Must be preheated before ignition can occur.",
                        @"Must be moderately heated or exposed to relatively high ambient temperatures before ignition can occur.",
                        @"Can be ignited under almost all ambient temperature conditions.",
                        @"Burns readily. Rapidly or completely vaporizes at atmospheric pressure and normal ambient temperature.",
                        nil];
    healthList = [NSArray arrayWithObjects:
                        @"Can cause significant irritation.",
                        @"Can cause temporary incapacitation or residual injury.",
                        @"Can cause serious or permanent injury.",
                        @"Can be lethal.",
                  nil];
    instabilityList = [NSArray arrayWithObjects:
                        @"Normally stable but can become unstable at elevated temperatures and pressures.",
                        @"Readily undergoes violent chemical changes at elevated temperatures and pressures.",
                        @"Capable of detonation or explosive decomposition or explosive reaction but requires a strong initiating source or must be heated under confinement before initiation.",
                        @"Readily capable of detonation or explosive decomposition or explosive reaction at normal temperatures and pressures.",
                       nil];
    
    [self loadDataBases];

#ifdef notdef
    NSDictionary *attrs = [[NSFileManager defaultManager]
                           attributesOfItemAtPath:dbURL.path
                           error:&error];
    if (attrs != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM yyyy"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSDate *modDate = (NSDate*)[attrs objectForKey: NSFileModificationDate];
        dataDate = [dateFormatter stringFromDate:modDate];
        NSLog(@"Database modification date: %@", dataDate);
    } else {
        NSLog(@" Date Not found");
        dataDate = @"(Unknown)";
    }
#endif
    
    UIImage *dotImage = [UIImage imageNamed:@"DOT.gif"];
    dotImageView = [[UIImageView alloc] initWithImage:dotImage];
    dotImageView.frame = CGRectMake(0, 30, DOT_H, DOT_H);
    dotImageView.userInteractionEnabled = YES;
    [self.view addSubview:dotImageView];
    
    digitsView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    digitsView.frame = CGRectMake(40, 77, 120, HAZ_H);
    digitsView.titleLabel.font = [UIFont boldSystemFontOfSize:36];
    [digitsView setTitle:@"" forState:UIControlStateNormal];
//    [digitsView setTitle:VERTICAL_LINE forState:UIControlStateNormal];
    [digitsView setTitleColor:[UIColor lightGrayColor]
                     forState:UIControlStateNormal];
    [digitsView addTarget:self
                   action:@selector(doDigitsTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [dotImageView addSubview:digitsView];

    placardView = [[PlacardView alloc] init];
    placardView.hidden = YES;
#ifdef notdef
    placardView.layer.borderColor = [UIColor grayColor].CGColor;
    placardView.layer.borderWidth = 1.0;
    placardView.layer.cornerRadius = 0.5;
#endif
    [self.view addSubview:placardView];
    
    webView = [[WKWebView alloc] init];
    webView.navigationDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:webView];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.enabled = YES;
    [self.view addGestureRecognizer:leftSwipe];
    
    padView = [[PadView alloc] initWithTarget:self];
    [self.view addSubview:padView];
    
    [self enableAvailableDigits];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;

    [padView setupForView:self.view toHide:YES];
    padView.hidden = YES;
    [self layoutViews];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self toggleDigitsView];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self layoutViews];
    [UIView transitionWithView:self.view
                      duration:0.25
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        [padView setupForView:self.view toHide:padView.hidden];
                     }
                    completion:^(BOOL finished) {
                        ;
                    }];
}

- (void) toggleDigitsView {
    BOOL hiding = !padView.hidden;
    if (!hiding) {
        padView.hidden = NO;
    }
    [UIView transitionWithView:self.view
                      duration:0.25
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                          [padView setupForView:self.view toHide:hiding];
                   }
                    completion:^(BOOL finished) {
                        if (hiding && finished)
                            padView.hidden = YES;
                    }];
}

- (IBAction)doDigitsTapped:(UIButton *)sender {
     [self toggleDigitsView];
}

- (BOOL) padTextIsOK: (NSString *)text {
    UNNAnumber = text;
    [digitsView setTitle:UNNAnumber forState:UIControlStateNormal];
    [digitsView setNeedsDisplay];
    if (UNNAnumber.length == 4) {
        if ([self displayAnswers:UNNAnumber])
            [self toggleDigitsView];
    } else {
        [self entryNotValid];
        return NO;
    }
    if (UNNAnumber.length > 0)
        [digitsView setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
    else {
        [digitsView setTitleColor:[UIColor lightGrayColor]
                         forState:UIControlStateNormal];
        [digitsView setTitle:@"" forState:UIControlStateNormal];
    }
    [self enableAvailableDigits];
    return YES;
}

- (void) enableAvailableDigits {
    NSMutableDictionary *node = digitTree;
    for (int i=0; i<[UNNAnumber length] && i < 4-1; i++) {
        NSString *ch = [UNNAnumber substringWithRange:NSMakeRange(i, 1)];
        NSMutableDictionary *nextNode = [node objectForKey:ch];
        node = nextNode;
    }
    NSString *available = @"";
    for (NSString *key in node) {
        available = [available stringByAppendingString:key];
    }
    [padView enabledKeys:available];
}

- (void) layoutViews {
    CGRect f = self.view.frame;
    f.origin.x = (f.size.width - dotImageView.frame.size.width)*0.5;
    f.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height +
    self.navigationController.navigationBar.frame.size.height;

    f.size = dotImageView.frame.size;
    dotImageView.frame = f;
    [dotImageView setNeedsDisplay];
    
    f.origin.x = RIGHT(dotImageView.frame);
    f.origin.y = dotImageView.frame.origin.y + dotImageView.frame.size.height/2.0;
    f.size.width = self.view.frame.size.width - f.origin.x;
    f.size.height = dotImageView.frame.size.height/2;
    if (f.size.width > f.size.height) {
        f.origin.x += (f.size.width - f.size.height);
        f.size.width = f.size.height;
    } else {
        f.origin.y += (f.size.height - f.size.width);
        f.size.height = f.size.width;
    }
    f.origin.x -= INSET;    // a little room
    placardView.frame = f;
    
    f = self.view.frame;
    f.origin.y = BELOW(dotImageView.frame) + VSEP;
    f.size.height -= f.origin.y;
    webView.frame = f;
    [webView setNeedsLayout];
}

- (void) loadDataBases {
    NSError *error;
    int count = 0;
    
    digitTree = [[NSMutableDictionary alloc] initWithCapacity:10];

    NSURL *dbURL = [[NSBundle mainBundle] URLForResource:@"ergdb" withExtension:@""];
    if (!dbURL) {
        NSLog(@"inconceivable, erg database missing");
    }
    NSArray *ergDB = [[NSString stringWithContentsOfURL:dbURL
                                               encoding:NSUTF8StringEncoding
                                                  error:&error]
                      componentsSeparatedByString:@"\n"];
    substances = [[NSMutableDictionary alloc] initWithCapacity:[ergDB count]];
    
    for (NSString *ergLine in ergDB) {
        Substance *substance = [[Substance alloc] initWithERGDBLine:ergLine];
        if (!substance)
            continue;
        if ([substances objectForKey:substance.UNnumber]) {
            NSLog(@"duplicate UN: %@, ignored for now", substance.UNnumber);
            continue;
        }
        [substances setObject:substance forKey:substance.UNnumber];
        [self addToTree: substance.UNnumber];
    }
    NSLog(@"substances read: %lu", (unsigned long)[substances count]);
    
    NSURL *nfpaURL = [[NSBundle mainBundle] URLForResource:@"nfpadb" withExtension:@""];
    if (!nfpaURL) {
        NSLog(@"inconceivable, nfpa database missing");
    }
    NSArray *nfpaDB = [[NSString stringWithContentsOfURL:nfpaURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                       componentsSeparatedByString:@"\n"];
    count = 0;
    int skipped = 0;
    for (NSString *nfpaLine in nfpaDB) {
        NSString *UNNumber = [self firstField:nfpaLine];
        if (!UNNumber)
            continue;
        Substance *s = [substances objectForKey:UNNumber];
        if (!s) {
            skipped++;
            continue;   // we don't know about this one
        }
        count++;
        [s addNFPA704DataLine:nfpaLine];
    }
    NSLog(@"NFPA 704 list accepted: %d, skipped %d", count, skipped);
    
    NSURL *wikiDBURL = [[NSBundle mainBundle] URLForResource:@"wikidb" withExtension:@""];
    if (!wikiDBURL) {
        NSLog(@"inconceivable, wiki database missing");
    }
    NSArray *wikiDB = [[NSString stringWithContentsOfURL:wikiDBURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                       componentsSeparatedByString:@"\n"];
    count = skipped = 0;
    for (NSString *wikiLine in wikiDB) {
        NSString *UNNumber = [self firstField:wikiLine];
        if (!UNNumber) {
            skipped++;
            continue;
        }
        Substance *s = [substances objectForKey:UNNumber];
        if (!s) {
            skipped++;
            continue;   // we don't know about this one
        }
        count++;
        [s addwikiLine:wikiLine];
    }
    NSLog(@"wiki items accepted: %d, skipped %d", count, skipped);
    
    NSURL *placardDBURL = [[NSBundle mainBundle] URLForResource:@"placarddb" withExtension:@""];
    if (!placardDBURL) {
        NSLog(@"inconceivable, placard database missing");
    }
    NSArray *placardDB = [[NSString stringWithContentsOfURL:placardDBURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                       componentsSeparatedByString:@"\n"];
    count = skipped = 0;
    for (NSString *placardLine in placardDB) {
        NSString *UNNumber = [self firstField:placardLine];
        if (!UNNumber) {
            skipped++;
            continue;
        }
        Substance *s = [substances objectForKey:UNNumber];
        if (!s)
            continue;   // we don't know about this one
        count++;
        [s addPlacardLine: placardLine];
    }
    NSLog(@"placard items accepted: %d, skipped %d", count, skipped);
}

- (void) addToTree: (NSString *) digits {
    NSMutableDictionary *node = digitTree;
    for (int i=1; i <=digits.length; i++) {
        NSString *ch = [digits substringWithRange:NSMakeRange(i-1, 1)];
        NSMutableDictionary *subNode = [node objectForKey:ch];
        if (!subNode) { // this is a new digit at this level
            if (i == digits.length) {   // last digit, no new pointer
                [node setObject:[NSNull null] forKey:ch];
            } else {
                NSMutableDictionary *newNode = [[NSMutableDictionary alloc] init];
                [node setObject:newNode forKey:ch];
                node = newNode;
            }
        } else
            node = subNode;
    }
}

- (NSString *) firstField:(NSString *) line {
    NSRange r = [line rangeOfString:@"\t"];
    if (r.location == NSNotFound) {
        return nil;
    }
    return [line substringToIndex:r.location];
}

// Return YES if an answer exists. This database and routine are stupidly ineffecient,
// but it doesn't matter.

- (BOOL) displayAnswers: (NSString *)UNNumber {
    Substance *s = [substances objectForKey:UNNumber];
    if (!s)
        return NO;
    
    currentSubstance = s;
    NSString *answerHTML =  @"<html><head>\n"
                            @"<style>\n"
                            @"body {\n"
                            @"  font-family: system, -apple-system, BlinkMacSystemFont,\n"
                            @"      \"Helvetica Neue\", \"Lucida Grande\"\n"
                            @"} </style>\n"
                            @"<meta name=\"viewport\" content=\"initial-scale=1.3\"/>\n"
                            @"</head><body>\n";
    
    answerHTML = [answerHTML
                  stringByAppendingString:[NSString
                                           stringWithFormat:
                                           @"<b>UN/NA %@:</b> %@.\n"
                                           @"<p>\n",
                                           UNNumber,
                                           currentSubstance.description]];
    
    // prepend adds a newline
    [log prependToLog:[NSString stringWithFormat:@"%@: %@",
                       UNNumber, currentSubstance.description]];

    NSURL *baseURL = nil;
    if (currentSubstance.placardFiles &&
        ![currentSubstance.placardFiles isEqualToString:@""]) {
        NSArray *placardList = [currentSubstance.placardFiles componentsSeparatedByString:@" "];
//        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"." error:nil];
//        for (NSString *file in files)
//            NSLog(@"  %@", file);
        
        for (NSString *file in placardList) {
            if ([file isEqualToString:@""])
                continue;
            if (!baseURL)
                baseURL = [[[NSBundle mainBundle] URLForResource:file withExtension:@""]
                           URLByDeletingLastPathComponent];
            answerHTML = [answerHTML
                          stringByAppendingString:[NSString stringWithFormat:
                                                   @"<img src=\"%@\">\n",
                                                   file]];
        }
        answerHTML = [answerHTML stringByAppendingString:@"\n<p>\n"];
    }
    if (currentSubstance.htmlDescription &&
        ![currentSubstance.htmlDescription isEqualToString:@""]) {
        answerHTML = [answerHTML
                          stringByAppendingString:[NSString stringWithFormat:
                                                   @"From Wikipedia: %@\n"
                                                   @"<p>\n",
                                                   currentSubstance.htmlDescription]];
    }
    
    answerHTML = [answerHTML
                    stringByAppendingString:
                    [NSString stringWithFormat:
                     @"<p>Links to official information:<p>\n"
                     @"<a href=\"%@\">NOAA ERG handling guide number %@.</a><p>\n",
                     currentSubstance.guideURL,
                     currentSubstance.guideNumber
                     ]];
    if (currentSubstance.dataSheetURL)
        answerHTML = [answerHTML
                      stringByAppendingString:
                      [NSString stringWithFormat:
                       @"<a href=\"%@\">NOAA NFPA 704 data sheet.</a><p>\n",
                       currentSubstance.dataSheetURL
                       ]];
    NSLog(@"*** %@: data sheet URL: %@",
          UNNumber, currentSubstance.dataSheetURL);
    answerHTML = [answerHTML stringByAppendingString:@"</body></html>\n"];
    [webView loadHTMLString:answerHTML baseURL:baseURL];
    webView.hidden = NO;
    [webView setNeedsDisplay];
    
    if (currentSubstance.NFPAnumbers) {
        [placardView useSubstance:currentSubstance];
        placardView.hidden = NO;
        [placardView setNeedsDisplay];
    }
    return YES;
}

- (IBAction) doAbout: (id) sender {
    AboutVC *avc = [[AboutVC alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:avc];
    avc.modalPresentationStyle = UIModalPresentationPopover;
    avc.preferredContentSize = CGSizeMake(self.view.frame.size.width - 20,
                                          self.view.frame.size.height - 120);
    
    UIPopoverPresentationController *popvc = nav.popoverPresentationController;
    popvc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popvc.delegate = self;
    popvc.sourceView = self.view;
    popvc.barButtonItem = sender;   // not working onthe iPhone
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)doLog:(UISwipeGestureRecognizer *)sender {
    LogVC *lvc = [[LogVC alloc] initWithLog:log];
//    self.navigationController.toolbarHidden = NO;
    [[self navigationController] pushViewController: lvc animated: YES];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    [self doLog:sender];
}

// We intercept clicks on our local web pages and send them off to the Safari
// app, which makes navigation easier.

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([[url absoluteString].lowercaseString hasPrefix:@"http"]) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:url
                     options:@{}
           completionHandler:^(BOOL success) {
           }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void) entryNotValid {
    currentSubstance = nil;
    webView.hidden = placardView.hidden = YES;
    [webView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
