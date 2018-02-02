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
@property (nonatomic, strong)   NSArray *ergDB;
@property (nonatomic, strong)   NSMutableArray *answers;
@property (nonatomic, strong)   NSString *dataDate;
@property (nonatomic, strong)   UISwipeGestureRecognizer *leftSwipe;

@property (nonatomic, strong)   UIButton *aboutButton;

@property (nonatomic, strong)   NSArray *flammabilityList;
@property (nonatomic, strong)   NSArray *healthList;
@property (nonatomic, strong)   NSArray *instabilityList;

@end

@implementation ViewController

@synthesize dotImageView;
@synthesize textField;
@synthesize webView;
@synthesize ergDB;
@synthesize answers;
@synthesize dataDate;
@synthesize aboutButton;
@synthesize leftSwipe;

@synthesize flammabilityList;
@synthesize healthList;
@synthesize instabilityList;

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    answers = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSURL *dbURL = [[NSBundle mainBundle] URLForResource:@"ergdb" withExtension:@""];
    if (!dbURL) {
        NSLog(@"inconceivable, database missing");
    }
    NSError *error;
    ergDB = [[NSString stringWithContentsOfURL:dbURL
                                      encoding:NSUTF8StringEncoding
                                         error:&error]
             componentsSeparatedByString:@"\n"];
    if (!ergDB || error) {
        NSLog(@"Inconceivable: DB read error %@",
              [error localizedDescription]);
    }
    
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
    
    aboutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aboutButton.frame = CGRectMake(0, 0, 70, HAZ_H);
    [aboutButton setTitle:@"?"
                 forState:UIControlStateNormal];
    aboutButton.titleLabel.font = [UIFont systemFontOfSize:30];
    aboutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [aboutButton addTarget:self
                    action:@selector(doAbout:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutButton];

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
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;

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
    f.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
    f.size = dotImageView.frame.size;
    dotImageView.frame = f;
    [dotImageView setNeedsDisplay];
    
    f = aboutButton.frame;
    f.origin.y = dotImageView.frame.origin.y;
    aboutButton.frame = f;
    [aboutButton setNeedsDisplay];
    
    f = self.view.frame;
    f.origin.y = BELOW(dotImageView.frame) + VSEP;
    f.size.height -= f.origin.y;
    webView.frame = f;
    [webView setNeedsLayout];

    [textField becomeFirstResponder];
    [textField setNeedsDisplay];
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

- (BOOL) displayAnswers: (int)query {
    NSString *substanceURL = nil;
    for (NSString *dbLine in ergDB) {
        Substance *substance = [[Substance alloc] initWithDBLine:dbLine];
        if (substance.number > query)
            break;
        if (substance.number == query) {
            [answers addObject:substance];
            if (!substanceURL)
                substanceURL = substance.numberURL;
        }
    }
    if (answers.count == 0)
        return NO;
    
    NSString *answerHTML =  @"<html><head>\n"
                            @"<style>\n"
                            @"body {\n"
                            @"  font-family: system, -apple-system, BlinkMacSystemFont,\n"
                            @"      \"Helvetica Neue\", \"Lucida Grande\"\n"
                            @"} </style>\n"
                            @"<meta name=\"viewport\" content=\"initial-scale=1.3\"/>\n"
                            @"</head><body>\n";
    for (Substance *substance in answers) {
        answerHTML = [NSString stringWithFormat:@"%@<p>\n%@.\n"
                      @"<a href=\"%@\">(Handling guide #%@)</a>."
                      @"</p>",
                      answerHTML, substance.description,
                      substance.guideURL, substance.guideNumber];
    }
    answerHTML = [answerHTML stringByAppendingString:[NSString stringWithFormat:
                                                      @"<a href=\"%@\">NOAA UN/NA chemical description</a></p>\n",
                                                      substanceURL]];
    answerHTML = [answerHTML stringByAppendingString:[NSString stringWithFormat:
                                                      @"<p><small>This information is provided for educational purposes from databases "
                                                      @"from the US NOAA as of %@.  While it is believed to be accurate, first responders "
                                                      @"should probably use official apps to access data in emergency situations.</small></p>"
                                                      @"</body></html>\n",
                                                      dataDate]];
    [webView loadHTMLString:answerHTML baseURL:nil];
    webView.hidden = NO;
    [webView setNeedsDisplay];
    leftSwipe.enabled = YES;
    return YES;
}

-(IBAction) doAbout: (id) sender {
    AboutVC *avc = [[AboutVC alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:avc];
    avc.modalPresentationStyle = UIModalPresentationPopover;
    avc.preferredContentSize = CGSizeMake(280,400);
    
    UIPopoverPresentationController *popvc = nav.popoverPresentationController;
    popvc.delegate = self;
    popvc.sourceView = self.view;
    popvc.barButtonItem = sender;
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    OfficialVC *ovc = [[OfficialVC alloc] init];
    [[self navigationController] pushViewController: ovc animated: YES];
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
    return [self displayAnswers:newText.intValue];
}

- (void) entryNotValid {
        if (answers.count > 0) {
            [answers removeAllObjects];
        }
    webView.hidden = YES;
    leftSwipe.enabled = NO;
    [webView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
