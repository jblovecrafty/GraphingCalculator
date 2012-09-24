//
//  GraphingView.m
//  GraphingCalculator
//
//  Created by Joe Jones on 9/10/12.
//  Copyright (c) 2012 Joe Jones. All rights reserved.
//

#import "GraphingView.h"
#import "AxesDrawer.h"

@interface GraphingView()
@property (nonatomic) BOOL isDefaultOrigin;
@end

@implementation GraphingView

@synthesize currentOrigin = _currentOrigin;
@synthesize currentScale = _currentScale;
@synthesize datasource = _datasource;

//set up constants here
//
CGFloat const DEFAULT_SCALE = 1.0;

//getters and setters here
//
-(CGFloat)currentScale
{
    if(!_currentScale)
    {
        _currentScale = DEFAULT_SCALE;
    }

    return _currentScale;
}

-(void)setCurrentScale:(CGFloat)currentScale
{
    //Check for zero and return
    
    if(currentScale != _currentScale)
    {
        //call out to update our datasource
        //
        [self.datasource saveUserScale:currentScale];
        
        _currentScale = currentScale;
        [self setNeedsDisplay];
    }
}

-(void)setCurrentOrigin:(CGPoint)currentOrigin
{
    _currentOrigin = currentOrigin;
    
    //save our origin
    //
    [self.datasource saveUserOrigin:currentOrigin];
    
    [self setNeedsDisplay];
}


//actions we can handle
//
-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if((gesture.state == UIGestureRecognizerStateChanged) ||
       (gesture.state == UIGestureRecognizerStateEnded))
    {
        self.currentScale *= gesture.scale;
        
        gesture.scale = 1;
    }
}

-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint translatedPoint = [gesture translationInView:self];
        
        //get the x and y and redraw the graph based on the new bounds
        //
        [self setCurrentOrigin:CGPointMake(self.currentOrigin.x + translatedPoint.x, self.currentOrigin.y + translatedPoint.y)];
        
        self.isDefaultOrigin = NO;
        [self setNeedsDisplay];
        [gesture setTranslation:CGPointZero inView:self];
    }
}

//handle readjusting of the origin
//
-(void)tap:(UITapGestureRecognizer *)gesture
{
    CGPoint locationOfTap = [gesture locationInView:self];
    
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        [self setCurrentOrigin:CGPointMake(locationOfTap.x, locationOfTap.y)];
        self.isDefaultOrigin = NO;
        [self setNeedsDisplay];
    }
}

//


//
//helper methods
//
-(CGFloat)getViewMidPointXLocation
{
    return self.bounds.origin.x + self.bounds.size.width/2;
}

-(CGFloat)getViewMidPointYLocation
{
    return self.bounds.origin.y + self.bounds.size.height/2;
}

-(CGPoint)getExactViewMidpointLocation
{
    CGPoint midPoint;
    midPoint.x = [self getViewMidPointXLocation];
    midPoint.y = [self getViewMidPointYLocation];
    
    return midPoint;
}

-(CGFloat)translateXFromViewToCartesian:(CGFloat)xValueToTranslate
                           originXToUse:(CGFloat)passedOriginX
                      scaleToMultiplyBy:(CGFloat)scale
{
    CGFloat translatedX;
    
    //figure out the what the x should be translated to
    //
    
    translatedX = (xValueToTranslate - passedOriginX)/scale;
    
    return translatedX;
}


-(CGFloat)translateYFromCartesianToView:(CGFloat)yValueToTranslate
                           originYToUse:(CGFloat)passedOriginY
                        scaleToDivideBy:(CGFloat)scale
{
    CGFloat translatedY;
    
    CGFloat yOffsetInPoint = yValueToTranslate* scale;
    translatedY = (passedOriginY - yOffsetInPoint);
    
    return translatedY;
}

-(void) setUp
{
    //lets check if we have any defaults saved
    //
    if([self.datasource areUserDefaultsSet])
    {
        self.currentOrigin = [self.datasource getSavedUserOrigin];
        self.currentScale = [self.datasource getSaveUserScale];
        self.isDefaultOrigin = NO;
    }
    else
    {
        
        [self setCurrentOrigin:[self getExactViewMidpointLocation]];
        self.isDefaultOrigin = YES;
    }
}

-(void) awakeFromNib
{
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
        
    }
    return self;
}


//helper method to draw graph
//
- (void)drawGraph:(CGContextRef)context
{
    //push context
    //
    UIGraphicsPushContext(context);
    
    //x and y CGFLoats
    //
    CGFloat xValue1;
    CGFloat yValue1;

            
    CGContextBeginPath(context);
    
    //loop until for the width of the view screen
    //
    for(int i = 0; i <= self.bounds.size.width; i++)
    {
        //feed in x's and pull out y's
        //lets check if we need to make x negative
        //
        xValue1 = i;
    
        yValue1 = [self.datasource calculateY:[self translateXFromViewToCartesian:xValue1 originXToUse:self.currentOrigin.x scaleToMultiplyBy:self.currentScale]];
    
        //ok now translate the y back
        //
        yValue1 = [self translateYFromCartesianToView:yValue1 originYToUse:self.currentOrigin.y scaleToDivideBy:self.currentScale];

        
        //hacky
        //
        if(i==0)
        {
            CGContextMoveToPoint(context, xValue1, yValue1);
            continue;
        }
        
        CGContextAddLineToPoint(context, xValue1, yValue1);
    }
    //draw the path
    [[UIColor blackColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    
    //pop drawing context off
    //
    UIGraphicsPopContext();
}



- (void)drawRect:(CGRect)rect
{
    //ok lets check if we should keep the default origin in view
    //
    if(self.isDefaultOrigin)
    {
        [self setCurrentOrigin: [self getExactViewMidpointLocation]];
    }

    
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.currentOrigin scale:self.currentScale];
    
    //get the graphics context
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawGraph:context];

}


@end
