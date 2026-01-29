#import "ResultsViewController.h"
#import <SafariServices/SafariServices.h>

@interface ResultsViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *loadingOverlay;
@property (nonatomic, strong) UILabel *tdeeLabel;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UISegmentedControl *loseGainControl;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UIButton *createPlanButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = @"Your Results";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sources" style:UIBarButtonItemStylePlain target:self action:@selector(openReferences)];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_scrollView];

    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 20;
    _stackView.alignment = UIStackViewAlignmentFill;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_stackView];

    _tdeeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tdeeLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    _tdeeLabel.textColor = [UIColor labelColor];
    _tdeeLabel.numberOfLines = 0;
    _tdeeLabel.textAlignment = NSTextAlignmentCenter;
    _tdeeLabel.alpha = 0;
    _tdeeLabel.hidden = YES;

    _questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _questionLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    _questionLabel.textColor = [UIColor labelColor];
    _questionLabel.text = @"Are you trying to lose weight or gain weight?";
    _questionLabel.numberOfLines = 0;
    _questionLabel.textAlignment = NSTextAlignmentCenter;
    _questionLabel.alpha = 0;
    _questionLabel.hidden = YES;

    _loseGainControl = [[UISegmentedControl alloc] initWithItems:@[ @"Lose", @"Gain" ]];
    _loseGainControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    [_loseGainControl addTarget:self action:@selector(loseGainChanged:) forControlEvents:UIControlEventValueChanged];
    _loseGainControl.alpha = 0;
    _loseGainControl.hidden = YES;

    _planLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _planLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    _planLabel.textColor = [UIColor labelColor];
    _planLabel.numberOfLines = 0;
    _planLabel.textAlignment = NSTextAlignmentCenter;
    _planLabel.alpha = 0;
    _planLabel.hidden = YES;

    _createPlanButton = [UIButton systemButtonWithPrimaryAction:nil];
    [_createPlanButton setTitle:@"Create Eating Plan" forState:UIControlStateNormal];
    [_createPlanButton addTarget:self action:@selector(createPlanTapped) forControlEvents:UIControlEventTouchUpInside];
    if (@available(iOS 15.0, *)) {
        _createPlanButton.configuration = [UIButtonConfiguration filledButtonConfiguration];
    } else {
        _createPlanButton.backgroundColor = [UIColor systemBlueColor];
        _createPlanButton.layer.cornerRadius = 10;
    }
    _createPlanButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_createPlanButton.heightAnchor constraintEqualToConstant:44].active = YES;
    _createPlanButton.alpha = 0;
    _createPlanButton.hidden = YES;

    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_stackView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:24],
        [_stackView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:24],
        [_stackView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-24],
        [_stackView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor constant:-24],
        [_stackView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor constant:-48],
    ]];

    _loadingOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    _loadingOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
    _loadingOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_loadingOverlay];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _spinner.color = [UIColor whiteColor];
    _spinner.translatesAutoresizingMaskIntoConstraints = NO;
    _spinner.transform = CGAffineTransformMakeScale(1.8, 1.8);
    [_loadingOverlay addSubview:_spinner];

    [NSLayoutConstraint activateConstraints:@[
        [_loadingOverlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_loadingOverlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_loadingOverlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_loadingOverlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_spinner.centerXAnchor constraintEqualToAnchor:_loadingOverlay.centerXAnchor],
        [_spinner.centerYAnchor constraintEqualToAnchor:_loadingOverlay.centerYAnchor],
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_spinner startAnimating];
    __weak typeof(self) w = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [w runRevealSequence];
    });
}

- (NSAttributedString *)attributedStringWithBoldNumber:(double)num format:(NSString *)fmt {
    UIFont *body = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    UIFont *numFont = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = NSTextAlignmentCenter;
    NSDictionary *baseAttrs = @{
        NSFontAttributeName: body,
        NSForegroundColorAttributeName: [UIColor labelColor],
        NSParagraphStyleAttributeName: para
    };
    NSString *numStr = [NSString stringWithFormat:@"%.0f", num];
    NSString *full = [NSString stringWithFormat:fmt, numStr];
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:full attributes:baseAttrs];
    NSRange r = [full rangeOfString:numStr];
    if (r.location != NSNotFound) {
        [a addAttributes:@{ NSFontAttributeName: numFont } range:r];
    }
    return [a copy];
}

- (void)runRevealSequence {
    [_spinner stopAnimating];
    _tdeeLabel.attributedText = [self attributedStringWithBoldNumber:self.tdee format:@"This is how many calories you burn on average each day:\n%@"];
    _tdeeLabel.hidden = NO;
    [_stackView addArrangedSubview:_tdeeLabel];

    [UIView animateWithDuration:0.5 animations:^{
        self.loadingOverlay.alpha = 0;
    } completion:^(BOOL finished) {
        self.loadingOverlay.hidden = YES;
    }];

    [UIView animateWithDuration:0.6 animations:^{
        self.tdeeLabel.alpha = 1;
    }];

    __weak typeof(self) w = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [w showQuestion];
    });
}

- (void)showQuestion {
    [_stackView addArrangedSubview:_questionLabel];
    [_stackView addArrangedSubview:_loseGainControl];
    _questionLabel.hidden = NO;
    _loseGainControl.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.questionLabel.alpha = 1;
        self.loseGainControl.alpha = 1;
    }];
}

- (void)loseGainChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == UISegmentedControlNoSegment) return;

    double targetKcal;
    NSString *fmt;
    if (sender.selectedSegmentIndex == 0) {
        targetKcal = self.tdee - 500;
        fmt = @"This is how many calories you can eat per day and still lose ~1lb of fat per week:\n%@";
    } else {
        targetKcal = self.tdee + 250;
        fmt = @"This is how many calories you can eat per day to steadily gain strength and muscle mass:\n%@";
    }
    _planLabel.attributedText = [self attributedStringWithBoldNumber:targetKcal format:fmt];

    if (_planLabel.superview == nil) {
        [_stackView addArrangedSubview:_planLabel];
        [_stackView addArrangedSubview:_createPlanButton];
        _planLabel.hidden = NO;
        _createPlanButton.hidden = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.planLabel.alpha = 1;
            self.createPlanButton.alpha = 1;
        }];
    }
}

- (void)createPlanTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This feature is coming soon!" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doneTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openReferences {
    NSString *refURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GutBurnReferencesURL"];
    if (refURLString.length == 0) return;
    NSURL *url = [NSURL URLWithString:refURLString];
    if (!url) return;
    if (@available(iOS 9.0, *)) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safari animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end
