//
//  ViewController.m
//  ChesHaz
//
//  Created by ches on 17/12/2.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "ViewController.h"
#import "Substance.h"

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

@interface ViewController ()

@property (nonatomic, strong)   UIView *headerView;
@property (nonatomic, strong)   UIImageView *dotImageView;
@property (nonatomic, strong)   UIButton *dataSheet;
@property (nonatomic, strong)   UIButton *ergGuide;
@property (nonatomic, strong)   UITableView *tableView;
@property (nonatomic, strong)   UITextField *textField;
@property (nonatomic, strong)   NSArray *ergDB;
@property (nonatomic, strong)   NSMutableArray *answers;

@end

@implementation ViewController

@synthesize headerView;
@synthesize dotImageView;
@synthesize dataSheet, ergGuide;
@synthesize tableView;
@synthesize textField;
@synthesize ergDB;
@synthesize answers;

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

    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 320, DOT_H)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    
    UIImage *dotImage = [UIImage imageNamed:@"DOT.gif"];
    dotImageView = [[UIImageView alloc] initWithImage:dotImage];
    dotImageView.frame = CGRectMake(0, 0, DOT_H, DOT_H);
//    dotImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    dotImageView.layer.borderWidth = 1.0;
//    dotImageView.layer.cornerRadius = 5.0;
    [headerView addSubview:dotImageView];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 75, 120, HAZ_H)];
    textField.font = [UIFont boldSystemFontOfSize:36];
    textField.text = @"";
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.enabled = YES;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.backgroundColor = [UIColor clearColor];
    [dotImageView addSubview:textField];
    
    dataSheet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect f = headerView.frame;
    f.origin.x = RIGHT(dotImageView.frame) - 20;
    f.origin.y = 40;
    f.size.width = headerView.frame.size.width - f.origin.x;
    f.size.height = BUTTON_H;
    dataSheet.frame = f;
    [dataSheet setTitle:@"NOAA datasheet"
                  forState:UIControlStateNormal];
    dataSheet.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [dataSheet addTarget:self
                     action:@selector(doDataSheet:)
           forControlEvents:UIControlEventTouchUpInside];
    dataSheet.hidden = YES;
    [headerView addSubview:dataSheet];
    
// this is wrong, needs multiple for a number
    ergGuide = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    f.origin.y = BELOW(f) + VSEP;
    ergGuide.frame = f;
    [ergGuide setTitle:@"NOAA ERG guide"
               forState:UIControlStateNormal];
    ergGuide.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [ergGuide addTarget:self
                  action:@selector(doergGuide:)
        forControlEvents:UIControlEventTouchUpInside];
    ergGuide.hidden = YES;
    [self.view addSubview:ergGuide];

    tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                             style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;

    CENTER_VIEW(headerView, self.view);
    [headerView setNeedsDisplay];
    
    CGRect f = self.view.frame;
    f.origin.y = BELOW(headerView.frame) + VSEP;
    f.size.height = 0;
    tableView.frame = f;
    [tableView reloadData];
    
    [textField becomeFirstResponder];
    [textField setNeedsDisplay];
}

// Return YES if an answer exists. This database and routine are stupidly ineffecient,
// but it doesn't matter.

- (BOOL) displayAnswers: (int)query {
    for (NSString *dbLine in ergDB) {
        Substance *substance = [[Substance alloc] initWithDBLine:dbLine];
        if (substance.number > query)
            break;
        if (substance.number == query) {
            [answers addObject:substance];
        }
    }
    if (answers.count == 0)
        return NO;
    [self entryValid:YES];
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

-(IBAction) doergGuide: (id) sender {
}

- (void) adjustTableHeight {
    SET_VIEW_HEIGHT(tableView, [answers count] * 44.0);
    [tableView setNeedsLayout];
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Top cell is for new apiary entry

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SubstanceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Substance *substance = [answers objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = substance.description;
    cell.detailTextLabel.text = substance.flags;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Substance *substance = [answers objectAtIndex:indexPath.row];
    CGRect r = [substance.description
                boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 50, 999999)
                options:NSStringDrawingUsesLineFragmentOrigin
                attributes:@{
                             NSFontAttributeName: [UIFont systemFontOfSize:44]
                             }
                context:nil];
    return r.size.height;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        [self entryValid:NO];
        return YES;
    }
    return [self displayAnswers:newText.intValue];
}

- (void) entryValid:(BOOL)valid {
    if (valid) {
        [self adjustTableHeight];
    } else {
        if (answers.count > 0) {
            [answers removeAllObjects];
            [self adjustTableHeight];
        }
    }
    dataSheet.hidden = !valid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
