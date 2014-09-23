//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Anthony Dagati on 9/20/14.
//  Copyright (c) 2014 Black Rail Capital. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end

@implementation BLCAwesomeFloatingToolbar


-(instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        /*
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        */
        
        //Make the four labels
        for (NSString *currentTitle in self.currentTitles) {
            
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            //button.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.titleLabel.textColor = [UIColor blackColor];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            //button.titleLabel.text = titleForThisButton;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.backgroundColor = colorForThisButton;
            //button.textColor = [UIColor whiteColor];
            [buttonsArray addObject:button];
            
            [button addTarget:self.delegate action:@selector(goBack) forControlEvents:
             UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self.delegate action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self.delegate action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
           //[button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
  

        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
            
            /* Labels code
            
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
             
        */
            
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds)/2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds)/2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust Button X and ButtonY for each label
        
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds)/2;
        }
        
        if (currentButtonIndex % 2 == 0) {
            buttonX = 0;
        } else {
            buttonX = CGRectGetWidth(self.bounds)/2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        }
    }
    
- (UIButton *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UIButton *)subview;
}

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

-(void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).titleLabel.text];
            }
        }
    }
}

-(void)panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        //NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self setNeedsDisplay];
        NSLog(@"Initial label colors are %@", self.colors);
        self.colors = @[[UIColor colorWithRed:205/255.0 green:250/255.0 blue:71/255.0 alpha:1],
                        [UIColor colorWithRed:192/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:149/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:205/255.0 green:105/255.0 blue:97/255.0 alpha:1]];
        //self.backgroundColor = [UIColor colorWithWhite:195/255.0f alpha:0.5];
        
        for (UIButton *button in self.buttons) {
            NSUInteger currentbuttonIndex = [self.buttons indexOfObject:button]; //0 through 3
            
            button.backgroundColor = [self.colors objectAtIndex:currentbuttonIndex];
        }
    }
    
    NSLog(@"New label colors are: %@", self.colors);
    NSLog(@"Testing that longpressed Gesture was pressed");
    
}



    /* Labels code
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds)/2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds)/2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds)/2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex divisible by 2?
            //0 or 2, so on the left
            labelX = 0;
        } else {
            labelX = CGRectGetWidth(self.bounds)/2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        }
}

     
- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}
     */

/* Labels code
-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

-(void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

-(void)panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        //NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self setNeedsDisplay];
        NSLog(@"Initial label colors are %@", self.colors);
        self.colors = @[[UIColor colorWithRed:205/255.0 green:250/255.0 blue:71/255.0 alpha:1],
                        [UIColor colorWithRed:192/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:149/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:205/255.0 green:105/255.0 blue:97/255.0 alpha:1]];
                        //self.backgroundColor = [UIColor colorWithWhite:195/255.0f alpha:0.5];

        for (UILabel *label in self.labels) {
            NSUInteger currentLabelIndex = [self.labels indexOfObject:label]; //0 through 3

            label.backgroundColor = [self.colors objectAtIndex:currentLabelIndex];
            }
        }

        NSLog(@"New label colors are: %@", self.colors);
        NSLog(@"Testing that longpressed Gesture was pressed");
        
    }

*/

/*- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
