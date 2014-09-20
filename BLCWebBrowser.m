//
//  BLCWebBrowser.m
//  BlocBrowser
//
//  Created by Anthony Dagati on 9/16/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import "BLCWebBrowser.h"

@interface BLCWebBrowser () <UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isLoading;
//Need to account for multiple frames
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowser

-(void)resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    self.textField.text = nil;
}

-(void)loadView {
    UIView *mainView = [UIView new];
    self.webview = [[UIWebView alloc] init];
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
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", "Back command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", "Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", "Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", "Reload command") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    //[mainView addSubview:self.webview];
    //[mainView addSubview:self.textField]; // add textField as subview
    //[mainView addSubview:self.backButton];
    //[mainView addSubview:self.forwardButton];
    //[mainView addSubview:self.stopButton];
    //[mainView addSubview:self.reloadButton];
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; // We calculate the height of the browser view to be the height of the entire main venue minus the height of the URL bar
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight); //cteate a frame for the textField view
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight); //create a frame for the webview view
    
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) { thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
}
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
    
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    self.stopButton.enabled = self.frameCount > 0;
    self.reloadButton.enabled = self.frameCount == 0;
}



@end
