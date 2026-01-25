#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include "CalculatorBridge.hpp"
#import "ResultsViewController.h"

static std::string ns2str(NSString *s) {
    if (!s || s.length == 0) return std::string();
    const char *c = [s UTF8String];
    return c ? std::string(c) : std::string();
}

@interface ViewController : UIViewController
@end

@interface ViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *weightLabel;
@property (nonatomic, weak) IBOutlet UITextField *weightField;
@property (nonatomic, weak) IBOutlet UILabel *heightFtLabel;
@property (nonatomic, weak) IBOutlet UITextField *heightFtField;
@property (nonatomic, weak) IBOutlet UILabel *heightInLabel;
@property (nonatomic, weak) IBOutlet UITextField *heightInField;
@property (nonatomic, weak) IBOutlet UITextField *ageField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *sexControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *activityControl;
@property (nonatomic, weak) IBOutlet UITextField *daysPerWeekField;
@property (nonatomic, weak) IBOutlet UIButton *calculateButton;
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController {
    UIToolbar *_keyboardToolbar;
    CGFloat _keyboardHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Fallback: wire outlets by hierarchy when storyboard outlets are nil (e.g. class/module mismatch).
    // Structure: self.view → scrollView → contentView → stackView; stack.arrangedSubviews[idx].
    if (!self.weightField) {
        UIScrollView *scroll = nil;
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[UIScrollView class]]) { scroll = (UIScrollView *)v; break; }
        }
        if (scroll) {
            if (!self.scrollView) self.scrollView = scroll;
            UIView *content = scroll.subviews.firstObject;
            UIStackView *stack = [content.subviews.firstObject isKindOfClass:[UIStackView class]] ? (UIStackView *)content.subviews.firstObject : nil;
            if (stack && stack.arrangedSubviews.count >= 16) {
                NSArray *arr = stack.arrangedSubviews;
                if (!self.weightField)       self.weightField = [arr[2] isKindOfClass:[UITextField class]] ? (UITextField *)arr[2] : nil;
                if (!self.heightFtField)     self.heightFtField = [arr[4] isKindOfClass:[UITextField class]] ? (UITextField *)arr[4] : nil;
                if (!self.heightInField)     self.heightInField = [arr[6] isKindOfClass:[UITextField class]] ? (UITextField *)arr[6] : nil;
                if (!self.ageField)          self.ageField = [arr[8] isKindOfClass:[UITextField class]] ? (UITextField *)arr[8] : nil;
                if (!self.sexControl)        self.sexControl = [arr[10] isKindOfClass:[UISegmentedControl class]] ? (UISegmentedControl *)arr[10] : nil;
                if (!self.activityControl)   self.activityControl = [arr[12] isKindOfClass:[UISegmentedControl class]] ? (UISegmentedControl *)arr[12] : nil;
                if (!self.daysPerWeekField)  self.daysPerWeekField = [arr[14] isKindOfClass:[UITextField class]] ? (UITextField *)arr[14] : nil;
                if (!self.calculateButton)   self.calculateButton = [arr[15] isKindOfClass:[UIButton class]] ? (UIButton *)arr[15] : nil;
            }
        }
    }

    self.weightLabel.text = @"Weight (lb)";

    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    _keyboardToolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    _keyboardToolbar.items = @[ flex, done ];
    [_keyboardToolbar sizeToFit];

    if (self.weightField) self.weightField.inputAccessoryView = _keyboardToolbar;
    if (self.heightFtField) self.heightFtField.inputAccessoryView = _keyboardToolbar;
    if (self.heightInField) self.heightInField.inputAccessoryView = _keyboardToolbar;
    if (self.ageField) self.ageField.inputAccessoryView = _keyboardToolbar;
    if (self.daysPerWeekField) self.daysPerWeekField.inputAccessoryView = _keyboardToolbar;

    // Let the scroll view pass touches straight to the Calculate button (and other controls).
    // Default delaysContentTouches=YES can block or delay button taps.
    if (self.scrollView) self.scrollView.delaysContentTouches = NO;

    // White outline on text fields for visibility
    for (UITextField *tf in @[ self.weightField, self.heightFtField, self.heightInField, self.ageField, self.daysPerWeekField ]) {
        if (tf) {
            tf.layer.borderColor = [UIColor whiteColor].CGColor;
            tf.layer.borderWidth = 1.5;
            tf.layer.cornerRadius = 8;
        }
    }

    // Calculate button: bright green, purple glow beneath, pulsating
    if (self.calculateButton) {
        if (@available(iOS 15.0, *)) {
            UIButtonConfiguration *cfg = self.calculateButton.configuration ?: [UIButtonConfiguration filledButtonConfiguration];
            cfg.baseBackgroundColor = [UIColor colorWithRed:0.2 green:0.85 blue:0.25 alpha:1];
            self.calculateButton.configuration = cfg;
        } else {
            self.calculateButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.85 blue:0.25 alpha:1];
        }
        self.calculateButton.clipsToBounds = NO;
        self.calculateButton.layer.masksToBounds = NO;
        self.calculateButton.layer.shadowColor = [UIColor purpleColor].CGColor;
        self.calculateButton.layer.shadowOffset = CGSizeMake(0, 4);
        self.calculateButton.layer.shadowRadius = 12;
        self.calculateButton.layer.shadowOpacity = 0.9;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToDismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Start pulsating animation on Calculate button (AllowUserInteraction so taps still work)
    if (self.calculateButton) {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.calculateButton.transform = CGAffineTransformMakeScale(1.04, 1.04);
        } completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)handleTapToDismissKeyboard:(UITapGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    UIView *hit = [self.view hitTest:p withEvent:nil];
    for (UIView *v = hit; v; v = v.superview) {
        if ([v isKindOfClass:[UITextField class]]) return;
    }
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *v = touch.view;
    for (; v; v = v.superview) {
        if ([v isKindOfClass:[UIControl class]]) return NO;  // don’t steal taps from buttons, segmented controls, etc.
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)n {
    if (!self.scrollView) return;
    NSDictionary *info = n.userInfo;
    CGRect fr = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = fr.size.height;
    NSTimeInterval dur = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:dur animations:^{
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.bottom = self->_keyboardHeight;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)n {
    if (!self.scrollView) return;
    NSDictionary *info = n.userInfo;
    NSTimeInterval dur = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:dur animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (IBAction)onCalculate:(id)sender {
    [self dismissKeyboard];

    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *w = [[(self.weightField.text ?: @"") stringByTrimmingCharactersInSet:ws] copy];
    NSString *hft = [[(self.heightFtField.text ?: @"") stringByTrimmingCharactersInSet:ws] copy];
    NSString *hin = [[(self.heightInField.text ?: @"") stringByTrimmingCharactersInSet:ws] copy];
    NSString *a = [[(self.ageField.text ?: @"") stringByTrimmingCharactersInSet:ws] copy];
    NSString *days = [[(self.daysPerWeekField.text ?: @"") stringByTrimmingCharactersInSet:ws] copy];

    if (w.length == 0 || hft.length == 0 || hin.length == 0 || a.length == 0 || days.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please fill out all fields before moving on" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    std::string weightStr = ns2str(w);
    std::string heightFt = ns2str(hft);
    std::string heightIn = ns2str(hin);
    std::string ageStr = ns2str(a);
    BOOL isMale = (self.sexControl.selectedSegmentIndex == 0);
    NSInteger seg = self.activityControl.selectedSegmentIndex;
    int activityIndex = (seg >= 0 && seg <= 4) ? (int)seg : 0;

    gutburn::BridgeResult r = gutburn::calculateFromInputs(
        false, weightStr, heightFt, heightIn, ageStr, isMale, activityIndex
    );

    if (r.valid) {
        ResultsViewController *rvc = [[ResultsViewController alloc] init];
        rvc.tdee = r.tdee;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
