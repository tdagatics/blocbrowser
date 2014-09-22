//
//  BLCWebBrowser.m
//  BlocBrowser
//
//  Created by Anthony Dagati on 9/16/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved. Version 2.
//

#import "BLCWebBrowser.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward comand")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh")

@interface BLCWebBrowser () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;
//Need to account for multiple frames
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowser

-(void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:NSLocalizedString(@"Back", @"Back Command")]) {
        [self.webview goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward Command")]) {
        [self.webview goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop Command")]) {
        [self.webview stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload Command")]) {
        [self.webview reload];
    }
}


-(void)resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

-(void)loadView {
    UIView *mainView = [UIView new];
    self.webview = [[UIWebView alloc] init];
    UIAlertView *welcomeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome to Browser", "Welcome to Browser") message:NSLocalizedString(@"Welcome to Browser", "Welcome to Browser") delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay, use browser!", @"Okay, user browser!") otherButtonTitles:nil];
    [welcomeAlert show];
    self.webview.delegate = self;
    
    // Build TextFieldView
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
   // [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
   // [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
   // [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
   // [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    //[mainView addSubview:self.webview];
    //[mainView addSubview:self.textField]; // add textField as subview
    //[mainView addSubview:self.backButton];
    //[mainView addSubview:self.forwardButton];
    //[mainView addSubview:self.stopButton];
    //[mainView addSubview:self.reloadButton];
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // First, calculate some dimensions
    static CGFloat itemHeight = 50; // we want our URL bar to have a height of 50 so we create a variable for that
    CGFloat width = CGRectGetWidth(self.view.bounds); // We set the width equal to the view width
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);

    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - UITextFieldDelegate

    
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

# pragma google search
    
    NSString *URLString = textField.text;
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //Create a string called URLString from text entered by an end-user
    //Check to see if the string has whitespace
    
    NSRange whiteSpaceRange = [URLString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        NSString *stringAdjustedForGoogle = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *URLStringAdjustedForGoogle = [NSString stringWithFormat:@"http://www.google.com/search?q=%@",stringAdjustedForGoogle];
        URL = [NSURL URLWithString:URLStringAdjustedForGoogle];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
        } else if (!URL.scheme) {
        //The user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

    
-(void)webViewDidStartLoad:(UIWebView *)webview {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != -999) {
    UIAlertView *alert = [[[UIAlertView alloc] init] initWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateButtonsAndTitle];
}

#pragma mark - Miscellaneous

-(void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }

    if (self.isLoading) {
        if (self.frameCount > 0) {
          [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTtile:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTtile:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTtile:kBLCWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTtile:kBLCWebBrowserRefreshString];
}

-(void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

-(void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPinchWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    NSLog(@"Initial frame is %f %f %f %f", startingPoint.x, startingPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    CGRect newFrame = CGRectMake(startingPoint.x, startingPoint.y, CGRectGetWidth(toolbar.frame) - offset.x, CGRectGetHeight(toolbar.frame) - offset.y);
    NSLog(@"New frame after re-size is %f %f %f %f", startingPoint.x, startingPoint.y, CGRectGetWidth(toolbar.frame) - offset.x, CGRectGetHeight(toolbar.frame) - offset.y);
    
    if (CGRectContainsRect(self.view.bounds, newFrame)) {
        toolbar.frame = newFrame;
    }
}


@end
