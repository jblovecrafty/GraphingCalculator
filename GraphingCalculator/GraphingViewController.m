//
//  GraphingViewController.m
//  GraphingCalculator
//
//  Created by Joe Jones on 9/10/12.
//  Copyright (c) 2012 Joe Jones. All rights reserved.
//

#import "GraphingViewController.h"
#import "CalculatorBrain.h"
#import "GraphingCalculationProtocol.h"

@interface GraphingViewController () <GraphingCalculationProtocol>
@property (nonatomic) NSDictionary *varData;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphingViewController

@synthesize equationLabel;
@synthesize graph = _graph;
@synthesize program;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

NSString* const DESCRIPTION_OF_PROGRAM_INTRO = @"Equation: %@ ";
NSString* const PROGRAM_NIL_TEXT_FOR_DESCRIPTION_OF_PROGRAM = @"No Equation Entered";
NSString* const NAME_OF_SAVED_USER_SCALE = @"GraphUserScale";
NSString* const NAME_OF_SAVED_USER_ORIGIN = @"GraphUserOrigin";
NSString* const NAME_OF_GRAPH_DEFAULT_SAVE_STATE = @"GraphUserSaveState";


-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem)
    {
        NSMutableArray *toolBarItems = [self.toolbar.items mutableCopy];
        
        if(_splitViewBarButtonItem)
        {
            [toolBarItems removeObject:_splitViewBarButtonItem];
        }
        
        if(splitViewBarButtonItem)
        {
            [toolBarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        
        self.toolbar.items = toolBarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

//this is called to recalculate the graph on command
//
-(void)recalculateGraph
{
    self.equationLabel.text = [self setDescription:self.program];
    [self.graph setNeedsDisplay];
}

//lets set up our description items up here
//
-(NSString *)setDescription:(id)programToUse
{
    NSString *descriptionOfProgram;
    
    descriptionOfProgram = [NSString stringWithFormat:DESCRIPTION_OF_PROGRAM_INTRO, [CalculatorBrain descriptionOfProgram:programToUse]];
    
    return descriptionOfProgram;    
}

-(CGFloat)calculateY:(CGFloat)xValue
{
    CGFloat yValue;
    
    //call to calulator brain
    //
    self.varData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue],@"x", nil];
    
   yValue = (CGFloat) [CalculatorBrain runProgram:self.program usingVariableValues:self.varData];
    
    return yValue;
}


//set up the graphView gestures here
//
-(void) setGraph:(GraphingView *)graph
{
    _graph = graph;

    //set us as the delegate of the views data source
    //
    self.graph.datasource = self;

    //check to make sure that program has something to show
    //lets check if the program is nil
    //
    
    if(self.program)
    {
        self.equationLabel.text = [self setDescription:self.program];
    }
    else
    {
        self.equationLabel.text = PROGRAM_NIL_TEXT_FOR_DESCRIPTION_OF_PROGRAM;
    }
    
    [self.graph addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graph action:@selector(pinch:)]];
    
    [self.graph addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graph action:@selector(pan:)]];
    
    
    //ok I have to set up the tap gesture recognizer in this other way than using
    //the way listed above....I looked and I cant find it so I have to do it this way
    //
    UITapGestureRecognizer *threeTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self.graph action:@selector(tap:)];
    
    threeTapAction.numberOfTapsRequired = 3;
    
    [self.graph addGestureRecognizer:threeTapAction];
}

-(void)saveUserOrigin:(CGPoint)userOrigin
{
    //save the user's origin here
    //
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    //have to convert
    //
    NSString *stringOfUserOrigin = NSStringFromCGPoint(userOrigin);
    
    [settings setObject:stringOfUserOrigin forKey:NAME_OF_SAVED_USER_ORIGIN];
    
    [self saveGraphUserSaveState:YES];
    
    [settings synchronize];
    
}

-(void)saveUserScale:(CGFloat)userScale
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    [settings setFloat:userScale forKey:NAME_OF_SAVED_USER_SCALE];
    
    [self saveGraphUserSaveState:YES];
    
    [settings synchronize];
}

-(CGPoint)getSavedUserOrigin
{
    //return user's save origin if it exists
    //
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    return CGPointFromString([settings objectForKey:NAME_OF_SAVED_USER_ORIGIN]);
}

-(CGFloat)getSaveUserScale
{
    //return user's save scale if it exists
    //
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    return (CGFloat)[settings floatForKey:NAME_OF_SAVED_USER_SCALE];
}

-(void)saveGraphUserSaveState:(BOOL)saveState
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    [settings setBool:saveState forKey:NAME_OF_GRAPH_DEFAULT_SAVE_STATE];
    
    [settings synchronize];
    
}

-(BOOL)getGraphUserSaveState
{    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    return [settings boolForKey:NAME_OF_GRAPH_DEFAULT_SAVE_STATE];
}

-(BOOL)areUserDefaultsSet
{
    return [self getGraphUserSaveState];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
