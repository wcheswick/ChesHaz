//
//  PadView.m
//  ChesHaz
//
//  Created by William Cheswick on 2/16/18.
//  Copyright © 2018 Cheswick.com. All rights reserved.
//
// This view size is fixed based on the number of keys required.

#import "PadView.h"

#define DELETE_ERASE_CH @"⌫"
#define CLEAR_CH        @"X"

#define DEFAULT_KEYS    @"1234567890"

#define INSET       5
#define KPR         3   // keys per row, always three, but mystery constants suck
#define KEYPAD_W    375 // minimum width, unless screen is narrower
#define KEYPAD_CORNER_RADIUS    10
#define KEYPAD_FULL_W   (KEYPAD_W + 2*KEYPAD_CORNER_RADIUS + 2*INSET)   // max width

#define KEYPAD_TOP_INSET    INSET
#define KEYPAD_BOTTOM_INSET     15

#define KEY_FONT_SIZE   24
#define KEY_H         40

#define UNASSIGNED_TAG  0   // should never happen
#define BACKSPACE_TAG   1
#define CLEAR_TAG       2
#define PAD_BASE_TAG    10

@interface PadView ()

@property (nonatomic, strong)   UIView *digitsView;
@property (nonatomic, strong)   UIButton *backspaceKey;
@property (nonatomic, strong)   UIButton *clearKey;
@property (nonatomic, strong)   NSString *padChars;

@property (assign)              id<PadDelegate> caller;

@end


@implementation PadView

@synthesize keypadText;
@synthesize digitsView;
@synthesize backspaceKey;
@synthesize clearKey;
@synthesize padChars;

@synthesize caller;

// Each key is one character


- (id)initWithTarget:(id<PadDelegate>)t
                keys:(NSString *)keys {
    self = [super init];
    if (self) {
        caller = t;
        [self initWith: keys];
    }
    return self;
}

-(id)initWithTarget:(id<PadDelegate>)t {
    self = [super init];
    if (self) {
        caller = t;
        [self initWith: DEFAULT_KEYS];
    }
    return self;
}

- (void) initWith:(NSString *) digitList {
    padChars = digitList;
    self.keypadText = @"";
    
    digitsView = [[UIView alloc] init];
    for (int i=0; i<padChars.length; i++) { // Make buttons
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.tag = PAD_BASE_TAG + i;
        [b setTitle:[padChars substringWithRange:NSMakeRange(i, 1)]
           forState:UIControlStateNormal];
        [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        b.titleLabel.font = [UIFont systemFontOfSize:KEY_FONT_SIZE];
        b.layer.cornerRadius = 3.0;
        b.layer.borderColor = [UIColor darkGrayColor].CGColor;
        b.layer.borderWidth = 0.25;
        b.backgroundColor = [UIColor whiteColor];
        [b addTarget:self action:@selector(doKey:)
           forControlEvents:UIControlEventTouchUpInside];
        [digitsView addSubview:b];
    }
    
    clearKey = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearKey setTitle:CLEAR_CH forState:UIControlStateNormal];
    clearKey.titleLabel.font = [UIFont systemFontOfSize:KEY_FONT_SIZE];
    clearKey.tag = CLEAR_TAG;
    [clearKey setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearKey setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    clearKey.backgroundColor = [UIColor clearColor];
    [clearKey addTarget:self action:@selector(doKey:)
       forControlEvents:UIControlEventTouchUpInside];
    [digitsView addSubview:clearKey];

    backspaceKey = [UIButton buttonWithType:UIButtonTypeCustom];
    [backspaceKey setTitle:DELETE_ERASE_CH forState:UIControlStateNormal];
    backspaceKey.tag = BACKSPACE_TAG;
    backspaceKey.titleLabel.font = [UIFont systemFontOfSize:KEY_FONT_SIZE];
    [backspaceKey setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backspaceKey setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    backspaceKey.backgroundColor = [UIColor clearColor];
    [backspaceKey addTarget:self action:@selector(doKey:)
           forControlEvents:UIControlEventTouchUpInside];
    [digitsView addSubview:backspaceKey];

    [self addSubview:digitsView];
    
    self.backgroundColor = [UIColor lightGrayColor];
}

- (void) scrambleKeys {
    NSLog(@"not yet");
}

- (void) layoutSubviews {
    // Our minimum keypad width is the lesser of KEYPAD_W or the current screen
    // width.  Buttons are slightly narrower than this.
    // If the screen is wider, our keypad is the minimum plus padding
    // with rounded corners, to look nice on, say, an iPad.
    
    CGFloat keypadW = [[UIScreen mainScreen] bounds].size.width;
    BOOL showFull = keypadW > KEYPAD_W;
    CGFloat firstX, rowW;
    CGFloat firstY = KEYPAD_TOP_INSET;

    if (showFull) {
        keypadW = KEYPAD_FULL_W;
        firstX = INSET + KEYPAD_CORNER_RADIUS;
        rowW = keypadW - 2*INSET - 2*KEYPAD_CORNER_RADIUS;
    } else {
        firstX = INSET;
        rowW = keypadW - 2*INSET;
    }
    CGFloat keyW = rowW/KPR;
    
    u_long buttonRows = ((padChars.length + 2 - 1)/KPR) + 1;
    u_long buttonIndex;
    u_long buttonRow, buttonColumn;
    
    for (UIButton *button in [digitsView subviews]) {
        switch (button.tag) {
            case CLEAR_TAG:
                buttonRow = buttonRows - 1;
                buttonColumn = 0;
                break;
            case BACKSPACE_TAG:
                buttonRow = buttonRows - 1;
                buttonColumn = KPR - 1;
                break;
            case UNASSIGNED_TAG:
                NSLog(@"** inconceivable, unassigned view **");
                continue;
            default: {
                buttonIndex = button.tag - PAD_BASE_TAG;
                buttonRow = buttonIndex / KPR;
                if (buttonRow == buttonRows - 1)    // last button is in the center
                    buttonColumn = KPR/2;
                else
                    buttonColumn = buttonIndex % KPR;
            }
        }
        button.frame = CGRectMake(firstX + buttonColumn*keyW,
                                  firstY + buttonRow*(KEY_H + INSET),
                                  keyW - INSET,
                                  KEY_H);
    }

    digitsView.frame = CGRectMake(0, 0,
                                  keypadW,
                                  firstY + buttonRows*(KEY_H + INSET) + KEYPAD_BOTTOM_INSET);
    self.layer.cornerRadius = showFull ? KEYPAD_CORNER_RADIUS : 0;
    
    CGRect f = digitsView.frame;
    f.origin = self.frame.origin;
    self.frame = f;
    NSLog(@"%s @ %.1f,%.1f", __PRETTY_FUNCTION__, f.origin.x, f.origin.y);
}
- (void) enableBackspace: (BOOL)e {
    backspaceKey.enabled = e;
    [backspaceKey setNeedsDisplay];
}

- (void) enableClear: (BOOL) e {
    clearKey.enabled = e;
    [clearKey setNeedsDisplay];
}

- (void) enabledKeys: (NSString *)enabled {
    for (UIButton *button in [digitsView subviews]) {
        switch (button.tag) {
            case CLEAR_TAG:
            case BACKSPACE_TAG:
                continue;
            default: {
                button.enabled = [enabled rangeOfString:button.titleLabel.text].location != NSNotFound;
                NSLog(@" %@: %@", button.enabled ? @"E" : @"d",  button.titleLabel.text);
                [button setNeedsDisplay];
            }
        }
    }
}

- (void) adjustActiveKeys {
    backspaceKey.enabled = clearKey.enabled = keypadText.length > 0;
}

- (IBAction)doKey:(id)sender {
    UIButton *v = (UIButton *)sender;
    switch (v.tag) {
        case BACKSPACE_TAG:
            keypadText = [keypadText substringToIndex:keypadText.length - 1];
            break;
        case CLEAR_TAG:
            keypadText = @"";
            break;
        default:    // regular key pressed
            keypadText = [keypadText stringByAppendingString:v.titleLabel.text];
    }
    [caller padTextIsNow:keypadText];
    [self adjustActiveKeys];
}

@end
