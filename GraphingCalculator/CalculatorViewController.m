//
//  CalculatorViewController.m
//  Calculator_2
//
//  Created by Joe Jones on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphingViewController.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInMiddleOfEnteringNumber;
@property (nonatomic) BOOL decimalInDisplay;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) NSDictionary *varTestData;
@end


@implementation CalculatorViewController

@synthesize display;
@synthesize historyDisplay;
@synthesize userIsInMiddleOfEnteringNumber;
@synthesize decimalInDisplay;
@synthesize brain = _brain;

//constants
//
int const MAX_DISPLAY_HISTORY_CHARS = 24;
NSString* const DISPLAY_CLEARED_CHAR = @"0";
NSString* const DISPLAY_HISTORY_CLEARED_CHAR = @"";
NSString* const EQUATION_STRING_TEMPLATE = @" %@ = %@";
NSString* const RESULT_STRING_TEMPLATE = @"%g";
NSString* const HISTORY_STRING_TEMPLATE = @" %@";


//create calculator brain
//
- (CalculatorBrain *)brain
{
    if(!_brain)
    {
        _brain = [[CalculatorBrain alloc] init];
    }
    
    return _brain;
}

//base method for handling items that should show up on the display
//
- (void)displayItem:(UIButton *)sender
{
    NSString *displayItem = [sender currentTitle];
    
    //NSLog(@"Is User in the Middle of Typing %c", self.userIsInMiddleOfEnteringNumber);
    
    if(self.userIsInMiddleOfEnteringNumber)
    {
        self.display.text = [self.display.text stringByAppendingString:displayItem];
    }
    else
    {
        self.display.text = displayItem;
        self.userIsInMiddleOfEnteringNumber = YES;
    }
}

//show the history of the various calculations
//
- (void)historyDisplayList:(NSString *)newText
{
        
    self.historyDisplay.text = newText;
}

//This method handles a digit button being pressed
//
- (IBAction)digitPressed:(UIButton *)sender
{
    [self displayItem:sender];    
}


//allow decimals to be used
//
- (IBAction)decimalPressed:(UIButton *)sender
{
    //lets check if there is a decimal in display
    //
    if(!self.decimalInDisplay)
    {
        [self displayItem:sender];
        self.decimalInDisplay = YES;
    }
}

//allow for variables to be used
//
- (IBAction)variablePressed:(UIButton *)sender
{
    [self displayItem:sender];    
}

//clear out the display the history and the stack
//
- (IBAction)clearDisplay:(id)sender
{
    self.display.text = DISPLAY_CLEARED_CHAR;
    self.historyDisplay.text = DISPLAY_HISTORY_CLEARED_CHAR;
    self.variableValueDisplay.text = DISPLAY_HISTORY_CLEARED_CHAR;
    self.userIsInMiddleOfEnteringNumber = NO;
    self.decimalInDisplay = NO;
    [self.brain clearOperandStack];
}

//handle the sending of test data to the brain
- (IBAction)varTestData:(UIButton *)sender
{
    //ok check what is being passed to us
    //NEED TO REWORK THIS
    //
    if([[sender currentTitle] isEqualToString:@"Test1"])
    {
        self.varTestData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2],@"x", [NSNumber numberWithDouble:10],@"y", nil];
        
    }
    else
    {
        self.varTestData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:5],@"x", [NSNumber numberWithDouble:1],@"y", nil];
    }
    
    //update the vars used
    //
    self.variableValueDisplay.text = [self displayVariableValuesUsedInEntry];
}



//clear the last entry if it is not a result of an operation
//
- (IBAction)clearLastEntry:(UIButton *)sender
{
    //check if they pressed enter and if so then pop off stack
    //otherwise just zero out the display and remove the
    //last digit from history
    //
    if(!self.userIsInMiddleOfEnteringNumber)
    {
        self.decimalInDisplay = NO;
        [self.brain clearLastOperand];
        
        //update display with last calculation or number on stack
        //
        self.display.text = [[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.varTestData ]]  stringValue];
    }
    else
    {
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        
        //if no decimals set decimalInDisplay = NO
        //
        if([self.display.text rangeOfString:@"."].location == NSNotFound)
        {
            self.decimalInDisplay = NO;
        }
    }
    
    if([self.display.text length] == 0)
    {
        self.display.text = DISPLAY_CLEARED_CHAR;
        self.userIsInMiddleOfEnteringNumber = NO;
        self.decimalInDisplay = NO;
    }
    
    
    //update history display
    //
    [self historyDisplayList:[CalculatorBrain descriptionOfProgram:self.brain.program]];
}


//action to handle the enter pressed button
//
- (IBAction)enterPressed
{
    //check if we are getting a double or a variable
    //
    if([CalculatorBrain isVariable:self.display.text])
    {
        [self.brain pushVariable:self.display.text];
    }
    else
    {
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    
    //update history display
    //
    [self historyDisplayList:[CalculatorBrain descriptionOfProgram:self.brain.program]];
    
    self.userIsInMiddleOfEnteringNumber = NO;
    self.decimalInDisplay = NO;

}

//action to handle the operation keys
//
- (IBAction)operationPressed:(UIButton *)sender 
{
    if(self.userIsInMiddleOfEnteringNumber)
    {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    
    double result;
    
    //lets get the results
    //
    result = [self getCalculatorResults:operation];
    
    self.display.text = [NSString stringWithFormat:RESULT_STRING_TEMPLATE, result];
    
    //update history display
    //
    [self historyDisplayList:[CalculatorBrain descriptionOfProgram:self.brain.program]];
    
    self.decimalInDisplay = NO;
    
}

- (IBAction)graphButton
{
    [self sendProgram];
}


//helper method for which result to send
//
-(double)getCalculatorResults:(NSString *)operation
{
    double result = 0;
    
    //lets check if we need to pass along a varaible dictionary
    //
    if(self.varTestData)
    {
        result = [self.brain performOperation:operation usingVariableValues:self.varTestData];
    }
    else
    {
        result = [self.brain performOperation:operation];
    }
    
    return result;
}

//helper method to display chosen variable values
//
- (NSString *)displayVariableValuesUsedInEntry
{
    NSString *varResults = @"";
    
    NSSet *setOfVars;
    
    //check to see if we have a valid entry (AKA varTestData isnt nil
    //
    if([self varTestData])
    {
        //ok we have a set of test data
        //build string by pulling the vars we are using from the program and then check and pull values from varTestData
        //
        setOfVars = [CalculatorBrain variablesUsedInProgram:self.brain.program];
        
        NSEnumerator *varSetEnumerator = [setOfVars objectEnumerator];
        id setItemValue;
        NSString *variableValue;
        
        while((setItemValue = [varSetEnumerator nextObject]))
        {
            //test if the setItemValue is in the varTestData
            //if so then format and append string
            //
            if([self.varTestData objectForKey:setItemValue])
            {
                variableValue = [self.varTestData objectForKey:setItemValue];
                
                varResults = [varResults stringByAppendingString:[NSString stringWithFormat:@"%@ = %@ ", setItemValue, variableValue]];
            }
        }
    }
    else
    {
        //ok if we have nil display error message
        //FACTOR OUT INTO A CONST
        //
        varResults = @"No Variable Data Chosen";
    }
    
    
    return varResults;
}

-(void)sendProgram
{
    if([self splitViewGraphingController])
    {
        [self splitViewGraphingController].program = self.brain.program;
        [[self splitViewGraphingController] recalculateGraph];
    }
    else
    {
        //segue
        //
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}

//handle our segue here
//
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //handle passing of the program to the segued to controller
    //
    if([segue.identifier isEqualToString:@"ShowGraph"])
    {
        GraphingViewController *graphViewController = segue.destinationViewController;
        graphViewController.program = self.brain.program;
    }
}

-(GraphingViewController *)splitViewGraphingController
{
    id graphingViewController = [self.splitViewController.viewControllers lastObject];
    
    if(![graphingViewController isKindOfClass:[GraphingViewController class]])
    {
        graphingViewController = nil;
    }
    
    return graphingViewController;    
}

//overide orientation to protect the iphone version

- (void)viewDidUnload {
    [self setHistoryDisplay:nil];
    [super viewDidUnload];
}
@end
