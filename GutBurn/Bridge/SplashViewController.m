#import "SplashViewController.h"

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"GutBurn.";
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) w = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [w transitionToCalculator];
    });
}

- (void)transitionToCalculator {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *calc = [sb instantiateViewControllerWithIdentifier:@"MainCalculator"];
    UIWindow *window = self.view.window;
    if (!window) {
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *ws = (UIWindowScene *)scene;
                    for (UIWindow *w in ws.windows) {
                        if (w.isKeyWindow) { window = w; break; }
                    }
                    if (!window && ws.windows.count > 0) window = ws.windows.firstObject;
                    if (window) break;
                }
            }
        }
    }
    if (!window || !calc) return;

    __weak typeof(self) w = self;
    [UIView animateWithDuration:0.5 animations:^{
        w.view.alpha = 0;
    } completion:^(BOOL finished) {
        window.rootViewController = calc;
    }];
}

@end
