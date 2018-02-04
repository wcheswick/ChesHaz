//
//  ViewController.m
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

// #import <Intents.h>
#import "AboutVC.h"
#import "OfficialVC.h"
#import "ViewController.h"
#import "Substance.h"

#define LATER   0   // rect value to be filled in later
#define INSET   5
#define VSEP    9

#define DOT_H           200
#define HAZ_H           50
#define HAZ_FONT_SIZE   40

#define HSEP    5
#define BUTTON_FONT_SIZE    30
#define BUTTON_H        (BUTTON_FONT_SIZE*1.2)

#define BELOW(r)    ((r).origin.y + (r).size.height)
#define RIGHT(r)    ((r).origin.x + (r).size.width)

#define SET_VIEW_X(v,nx) {CGRect f = (v).frame; f.origin.x = (nx); (v).frame = f;}
#define SET_VIEW_Y(v,ny) {CGRect f = (v).frame; f.origin.y = (ny); (v).frame = f;}

#define SET_VIEW_WIDTH(v,w)     {CGRect f = (v).frame; f.size.width = (w); (v).frame = f;}
#define SET_VIEW_HEIGHT(v,h)    {CGRect f = (v).frame; f.size.height = (h); (v).frame = f;}
#define SET_VIEW_SIZE(v,w,h)     {CGRect f = (v).frame; f.size = CGSizeMake((w), (h)); (v).frame = f;}

@interface ViewController ()

@property (nonatomic, strong)   UIImageView *dotImageView;
@property (nonatomic, strong)   UITextField *textField;
@property (nonatomic, strong)   WKWebView *webView;
@property (nonatomic, strong)   NSString *dataDate;
@property (nonatomic, strong)   UISwipeGestureRecognizer *leftSwipe;

@property (nonatomic, strong)   NSArray *flammabilityList;
@property (nonatomic, strong)   NSArray *healthList;
@property (nonatomic, strong)   NSArray *instabilityList;

@property (nonatomic, strong)   NSMutableDictionary *substances;

@end

@implementation ViewController

@synthesize dotImageView;
@synthesize textField;
@synthesize webView;
@synthesize dataDate;
@synthesize leftSwipe;

@synthesize flammabilityList;
@synthesize healthList;
@synthesize instabilityList;

@synthesize substances;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.toolbarHidden = YES;
    self.title = @"ChesHaz";

    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"?"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(doAbout:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
 
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Official links >"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(doOfficial:)];
    rightBarButton.enabled = NO;
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
//    dotImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    dotImageView.layer.borderWidth = 1.0;
//    dotImageView.layer.cornerRadius = 5.0;
    [self.view addSubview:dotImageView];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 75, 120, HAZ_H)];
    textField.font = [UIFont boldSystemFontOfSize:36];
    textField.text = @"";
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.enabled = YES;
// can't get this to work:
//  textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.backgroundColor = [UIColor clearColor];
    [dotImageView addSubview:textField];
    
    webView = [[WKWebView alloc] init];
#ifdef notdef
    [webView addObserver:self
              forKeyPath:@"URL"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
#endif
    webView.navigationDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:webView];
    
    leftSwipe = [[UISwipeGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(swipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.enabled = NO;
    [self.view addGestureRecognizer:leftSwipe];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self layoutViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
//    + (void)requestSiriAuthorization:(void (^)(INSiriAuthorizationStatus status))handler;
//[INPreferences requestSiriAuthorization]
}

- (void) layoutViews {
    CGRect f = self.view.frame;
    f.origin.x = (f.size.width - dotImageView.frame.size.width)/2.0;
    f.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height +
    self.navigationController.navigationBar.frame.size.height;
    f.size = dotImageView.frame.size;
    dotImageView.frame = f;
    [dotImageView setNeedsDisplay];
    
    f = self.view.frame;
    f.origin.y = BELOW(dotImageView.frame) + VSEP;
    f.size.height -= f.origin.y;
    webView.frame = f;
    [webView setNeedsLayout];

    [textField becomeFirstResponder];
    [textField setNeedsDisplay];
}

- (void) loadDataBases {
    NSError *error;
    int count = 0;

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
    for (NSString *nfpaLine in nfpaDB) {
        NSString *UNNumber = [self firstField:nfpaLine];
        if (!UNNumber)
            continue;
        Substance *s = [substances objectForKey:UNNumber];
        if (!s)
            continue;   // we don't know about this one
        count++;
        [s addNFPA704DataLine:nfpaLine];
    }
    NSLog(@"NFPA 704 list accepted: %d", count);
    
    NSURL *wikiDBURL = [[NSBundle mainBundle] URLForResource:@"wikidb" withExtension:@""];
    if (!wikiDBURL) {
        NSLog(@"inconceivable, wiki database missing");
    }
    NSArray *wikiDB = [[NSString stringWithContentsOfURL:wikiDBURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                       componentsSeparatedByString:@"\n"];
    count = 0;
    for (NSString *wikiLine in wikiDB) {
        NSString *UNNumber = [self firstField:wikiLine];
        if (!UNNumber)
            continue;
        Substance *s = [substances objectForKey:wikiLine];
        if (!s)
            continue;   // we don't know about this one
        count++;
        [s addwikiLine:wikiLine];
    }
    NSLog(@"wiki items accepted: %d", count);
    
    NSURL *placardDBURL = [[NSBundle mainBundle] URLForResource:@"placarddb" withExtension:@""];
    if (!placardDBURL) {
        NSLog(@"inconceivable, placard database missing");
    }
    NSArray *placardDB = [[NSString stringWithContentsOfURL:placardDBURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error]
                       componentsSeparatedByString:@"\n"];
    count = 0;
    for (NSString *placardLine in placardDB) {
        NSString *UNNumber = [self firstField:placardLine];
        if (!UNNumber)
            continue;
        Substance *s = [substances objectForKey:UNNumber];
        if (!s)
            continue;   // we don't know about this one
        count++;
        [s addPlacardLine: placardLine];
    }
    NSLog(@"placard items accepted: %d", count);
}

- (NSString *) firstField:(NSString *) line {
    NSRange r = [line rangeOfString:@"\t"];
    if (r.location == NSNotFound) {
        return nil;
    }
    return [line substringToIndex:r.location];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect f = webView.frame;
    f.size.height = self.view.frame.size.height - f.origin.y - kbSize.height;
    webView.frame = f;
    [webView setNeedsLayout];
}

// Return YES if an answer exists. This database and routine are stupidly ineffecient,
// but it doesn't matter.

- (BOOL) displayAnswers: (NSString *)UNNumber {
    Substance *substance = [substances objectForKey:UNNumber];
    if (!substance)
        return NO;
    
    NSString *answerHTML =  @"<html><head>\n"
                            @"<style>\n"
                            @"body {\n"
                            @"  font-family: system, -apple-system, BlinkMacSystemFont,\n"
                            @"      \"Helvetica Neue\", \"Lucida Grande\"\n"
                            @"} </style>\n"
                            @"<meta name=\"viewport\" content=\"initial-scale=1.3\"/>\n"
                            @"</head><body>\n";
    answerHTML = [NSString stringWithFormat:@"%@<p>\n%@.\n"
                  @"<a href=\"%@\">(Handling guide #%@)</a>."
                  @"</p>",
                  answerHTML, substance.description,
                  substance.guideURL, substance.guideNumber];
    answerHTML = [answerHTML
                  stringByAppendingString:[NSString
                                           stringWithFormat:
                                           @"<a href=\"%@\">NOAA UN/NA chemical description</a></p>\n",
                                           substance.numberURL]];
    answerHTML = [answerHTML stringByAppendingString:[NSString stringWithFormat:
                                                      @"<p><small>This information is provided for educational purposes from databases "
                                                      @"from the US NOAA as of %@.  While it is believed to be accurate, first responders "
                                                      @"should probably use official apps to access data in emergency situations.</small></p>"
                                                      @"</body></html>\n",
                                                      dataDate]];
    [webView loadHTMLString:answerHTML baseURL:nil];
    webView.hidden = NO;
    [webView setNeedsDisplay];
    self.navigationItem.rightBarButtonItem.enabled = leftSwipe.enabled = YES;
    return YES;
}

-(IBAction) doAbout: (id) sender {
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

- (IBAction)doOfficial:(UISwipeGestureRecognizer *)sender {
    OfficialVC *ovc = [[OfficialVC alloc] init];
    [[self navigationController] pushViewController: ovc animated: YES];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    [self doOfficial:sender];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return NO;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location != NSNotFound)
        return NO;  // non-digits
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length > 4)
        return NO;
    if (newText.length < 4) {
        [self entryNotValid];
        return YES;
    }
    return [self displayAnswers:newText];
}

- (void) entryNotValid {
    webView.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = leftSwipe.enabled = NO;
    [webView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
