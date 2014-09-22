//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Anthony Dagati on 9/20/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwesomeFloatingToolbar;

@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>

@optional

-(void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
-(void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
-(void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPinchWithOffset:(CGPoint)offset;

@end

@interface BLCAwesomeFloatingToolbar : UIView

-(instancetype) initWithFourTitles:(NSArray *)titles;

-(void) setEnabled:(BOOL)enabled forButtonWithTtile:(NSString *)title;

@property (nonatomic, weak) id <BLCAwesomeFloatingToolbarDelegate> delegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
