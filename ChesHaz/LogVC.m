//
//  LogVC.m
//  ChesHaz
//
//  Created by William Cheswick on 2/27/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//

#import "LogVC.h"

@interface LogVC ()

@property (nonatomic, strong)   UIBarButtonItem *clearButton;
@property (nonatomic, strong)   UIBarButtonItem *mailButton;
@property (nonatomic, strong)   UITextView *logTextView;
@property (nonatomic, strong)   UIView *activeField;

@end

@implementation LogVC

@synthesize clearButton;
@synthesize mailButton;

@synthesize logTextView, activeField;
@synthesize log;

- (id) initWithLog:(Log *) l {
    self = [super init];
    if (self) {
        self.log = l;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ChesHaz log";
    
    clearButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"Clear"
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(doClear:)];
    
    mailButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"Mail"
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(doMail:)];
 
    UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil
                                   action:nil];
    
    self.navigationItem.rightBarButtonItems = @[
                          clearButton,
                          flexSpacer,
                          mailButton];
    
    logTextView = [[UITextView alloc] init];
    logTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    logTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    logTextView = YES;
    logTextView.editable = YES;
    logTextView.font = [UIFont fontWithName:@"Courier" size:16];
    logTextView.text = log.text;
    logTextView.keyboardType = UIKeyboardTypeAlphabet;
    logTextView.returnKeyType = UIReturnKeyDone;
    logTextView.delegate = self;
    logTextView.scrollEnabled = YES;
    //    logTextView = UIEdgeInsetsMake(0.0f, 0.0f, -50.0f, 0.0f);
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(swipeRight:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipe.enabled = YES;
    [self.view addGestureRecognizer:rightSwipe];

    [self.view addSubview:logTextView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.dragging) {
        // scrolling is caused by user
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    logTextView.frame = self.view.bounds;
    [logTextView setNeedsDisplay];
    
    [self adjustButtons];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = logTextView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    logTextView.frame = newFrame;
    
    [UIView commitAnimations];
}

#define KEYBOARD_H  230

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    logTextView.contentInset = contentInsets;
    logTextView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 20;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [logTextView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    logTextView.contentInset = contentInsets;
    logTextView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text; {
    //    if ([text isEqualToString: @"\n"]) {
    //        [textView resignFirstResponder];
    //        return NO;
    //    }
    return YES;
}

-(IBAction) doClose: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    [self doClose:sender];
}

-(IBAction) doClear: (id) sender {
    logTextView.text = log.text = @"";
    [log save];
    [logTextView setNeedsDisplay];
    [self adjustButtons];
}

- (void) adjustButtons {
    clearButton.enabled = mailButton.enabled = (log.text.length > 0);
    if (mailButton.enabled) {
        mailButton.enabled = [MFMailComposeViewController canSendMail];
    }
}

-(IBAction) doMail: (id) sender {
    NSString *emailTitle = @"Substance log from the ChesHaz app";
    
    NSString *messageBody = [@"Substances looked up in ChesHaz\n\n"
                             stringByAppendingString:log.text];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];

    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error {
    if (error)
        NSLog(@"mail error %@", [error localizedDescription]);
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed: {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Mail failed"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        default:
            NSLog(@"inconceivable: unknown mail result %ld", (long)result);
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    log.text = textView.text;
    [log save];
    activeField = nil;
    [self adjustButtons];
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
#ifdef notdef
    CGPoint p = [textView contentOffset];
    CGSize s = textView.contentSize;
    NSLog(@"content offset at %.0f %.0f   %.0f %.0f",
          p.x, p.y, s.width, s.height);
    NSLog(@"h: %.0f %.0f", self.view.frame.size.height, textView.frame.size.height);
    if (textView.frame.size.height - s.height < KEYBOARD_H) {
        p.y += 30;
        NSLog(@"scroll! %.0f up %.0f", textView.frame.size.height, p.y);
        //        [textView setContentOffset:p animated:YES];
        //        [textView setNeedsDisplay];
    }
    //    [textView setContentOffset:p animated:YES];
    //   [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
    //    [textView setNeedsDisplay];
#endif
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end

