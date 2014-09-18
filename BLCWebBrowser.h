//
//  BLCWebBrowser.h
//  BlocBrowser
//
//  Created by Anthony Dagati on 9/16/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCWebBrowser : UIViewController <UIWebViewDelegate>

/**
 Replaces the web view with a fresh one, erasing all history. Also updates the URL field and tool bar buttons appropriately.
 */
-(void) resetWebView;

@end


