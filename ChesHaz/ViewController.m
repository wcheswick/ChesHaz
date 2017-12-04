//
//  ViewController.m
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

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

#define CENTER_VIEW(cv, v)  {CGRect f = (cv).frame; \
f.origin.x = ((v).frame.size.width - f.size.width)/2.0; \
(cv).frame = f;}

#define SCROLL_FUDGE    65

@interface ViewController ()

@property (nonatomic, strong)   UIImageView *dotImageView;
@property (nonatomic, strong)   UITextField *textField;
@property (nonatomic, strong)   WKWebView *webView;
@property (nonatomic, strong)   NSArray *ergDB;
@property (nonatomic, strong)   NSMutableArray *answers;
@property (nonatomic, strong)   NSString *dataDate;

@end

@implementation ViewController

@synthesize dotImageView;
@synthesize textField;
@synthesize webView;
@synthesize ergDB;
@synthesize answers;
@synthesize dataDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    answers = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSURL *dbURL = [[NSBundle mainBundle] URLForResource:@"ergdb" withExtension:@""];
    if (!dbURL) {
        NSLog(@"inconcievable, database missing");
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
    NSLog(@"database has %lu entries", (unsigned long)[ergDB count]);
    
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
        NSLog(@"Date Created: %@", dataDate);
    } else {
        NSLog(@" Date Not found");
        dataDate = @"(Unknown)";
    }
    
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
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#ifdef notdef
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;

    CENTER_VIEW(dotImageView, self.view);
    [dotImageView setNeedsDisplay];
    
    CGRect f = self.view.frame;
    f.origin.y = BELOW(dotImageView.frame) + VSEP;
    f.size.height -= f.origin.y;
    webView.frame = f;
    [webView setNeedsLayout];
    
    NSLog(@"textfield y, height: %.0f %.0f", textField.frame.origin.y,
          textField.frame.size.height);
    [textField becomeFirstResponder];
    [textField setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    SET_VIEW_HEIGHT(webView, self.view.frame.size.height - webView.frame.origin.y - kbSize.height - SCROLL_FUDGE);
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
                                                      @"<small>This information is provided for educational purposes from databases "
                                                      @"from the US NOAA as of %@.  While it is believed to be accurate, first responders "
                                                      @"should probably use official apps to access data in emergency situations.</small>"
                                                      @"</body></html>\n",
                                                      dataDate]];
   [webView loadHTMLString:answerHTML baseURL:nil];
    webView.hidden = NO;
    [webView setNeedsDisplay];
    return YES;
}

-(IBAction) doDataSheet: (id) sender {
    if (!answers || ![answers count])   // this should never happen
        return;
    Substance *substance = [answers objectAtIndex:0];   // they all have the same URL for this
    
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:substance.numberURL];
    [application openURL:URL
                 options:@{}
       completionHandler:^(BOOL success) {
       }];
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
    [webView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
