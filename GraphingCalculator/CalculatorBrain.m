//
//  CalculatorBrain.m
//  Calculator_2
//
//  Created by Joe Jones on 8/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property(nonatomic, strong)NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

//hold our set of validOperations
//
static NSSet *validOperationsSet;

static NSSet *twoOperandsFunctionsSet;

static NSSet *singleOperandsFunctionsSet;

static NSSet *singleOperandsSet;


//set up the set here
//
+ (void)initialize
{
    [super initialize];
    
    if (self == [CalculatorBrain class])
    {
        //USE NSSET WITH OBJECTS
        //
        validOperationsSet = [[NSSet alloc] initWithObjects:@"+", @"-", @"*",@"/" ,@"sin",@"cos",@"tan", @"sqrt",@"π",nil];
        
        twoOperandsFunctionsSet = [[NSSet alloc] initWithObjects:@"+", @"-", @"*",@"/",nil];
        
        singleOperandsFunctionsSet = [[NSSet alloc] initWithObjects:@"sin",@"cos",@"tan", @"sqrt",nil];
        
        singleOperandsSet = [[NSSet alloc] initWithObjects:@"π",nil];
    }
}


//getter for the operandStack
//
- (NSMutableArray *)programStack
{
    //lazy instansiation
    //
    if(!_programStack)//equiv to operandStack == nil
    {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}


//clear what we have
//
-(void)clearOperandStack
{
    [self.programStack removeAllObjects];
}

//only clear out the last operand
//
-(void) clearLastOperand
{
    //CHECK THE STACK FOR AN EMPTY STACK
    //
    if(self.programStack.count > 0)
    {
        //NSLog(@"Last Item %@", [self.operandStack lastObject]);
        [self.programStack removeLastObject];
    }
}

//add numerical operand to the stack
//
- (void) pushOperand:(double)operand
{
    //wrap the operand in an object
    //
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

//push var on to stack
//check if the var being pushed is an operation if so ignore
//if not add it to the stack also make sure contains only a-z
//
-(void) pushVariable:(NSString *)variable
{
    //get our character set set up
    // if letterCharacterSet is not nil then push
    //
    if([CalculatorBrain isVariable:variable])
    {
        //push on to the stack
        //
        [self.programStack addObject:variable];
    }
}

//lets look at the operand that is currently available and
//that is all
//
- (double)peekOperand
{
    NSNumber *operandObject = [self.programStack lastObject];
    
    return [operandObject doubleValue];
}

//delegate to runprogram
//
- (double) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

//there is a better way to handle this
//
- (double) performOperation:(NSString *)operation
usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

//lets us pass around the program stack and thus be able to pass it
//to the controller if needed
//
- (id)program
{
    return [self.programStack copy];
}

//this prints out the full program and the results of said program
//
+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    
    //check if we are dealing with an array
    //
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self stringPopOperandOffStack:stack recursiveCall:NO];
}

//this is a helper method to help us pop an operand of the stack
//returns string values
//
+(NSString *)stringPopOperandOffStack:(NSMutableArray *)stack recursiveCall:(BOOL)isRecursive
{
    //Should refactor this case statement stuff into a method
    //since I am using the (basically) same code twice
    //
    NSString *result;
    
    //put the bool if this is the inital recursive call or not
    //
    BOOL isRecursiveCall = true;
    isRecursiveCall = isRecursive;
    
    id topOfStack = [stack lastObject];
    
    if(topOfStack)
    {
        [stack removeLastObject];
    }
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack stringValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        if([twoOperandsFunctionsSet containsObject:operation])
        {
            //check if we have two stack items
            //PUSH THESE STRINGS INTO CONSTS
            //
            NSString *firstItem = @"0";
            NSString *secondItem = @"0";
            
            //THIS FEELS LIKE SUCH A HACK
            //
            if([stack count] >= 2)
            {
                firstItem = [self stringPopOperandOffStack:stack recursiveCall:YES];
                secondItem = [self stringPopOperandOffStack:stack recursiveCall:YES];
                
                result = [NSString stringWithFormat:@"(%@ %@ %@)", secondItem, operation , firstItem];
            }
            else if([stack count] == 1)
            {
                firstItem = [self stringPopOperandOffStack:stack recursiveCall:YES];
                
                result = [NSString stringWithFormat:@"(%@ %@ %@)", secondItem, operation , firstItem];
            }
            else
            {
               result = operation; 
            }
            
        }
        else if([singleOperandsFunctionsSet containsObject:operation])
        {
            
            if([stack count] >= 1)
            {
                result = [NSString stringWithFormat:@"%@(%@)", operation, [self stringPopOperandOffStack:stack recursiveCall:YES]];
            }
            else
            {
                result = operation;
            }
            
        }
        else if([singleOperandsSet containsObject:operation])
        {
            result = operation;
        }
        else
        {
            
            //ok we have a string here and it should be a variable
            //dont know if I should run the isVaraible method on string
            //
            result = operation;
        }
    }
    
    //ok if we are the initial call to this method lets check to see if there
    //is anything else on the stack
    //THERE IS A BETTER WAY TO HANDLE THIS
    //
    while(([stack count] > 0) && (!isRecursiveCall))
    {
        result = [NSString stringWithFormat:@"%@, %@", [self stringPopOperandOffStack:stack recursiveCall:YES],result];
    }
    
    return result;
}



//pop operand off stack and call this recursively
//ODD BUG FOUND WHEN TAKING SINGLE OPERATION THEN MULTIPLING IT GETTING 0
//
+ (double)popOperandOffStack:(NSMutableArray *)stack
          usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    
    if(topOfStack)
    {
        [stack removeLastObject];
    }
        
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        if([operation isEqualToString:@"+"])
        {
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] + [self popOperandOffStack:stack usingVariableValues:variableValues];
        }
        else if([operation isEqualToString:@"-"])
        {
            //order of operations
            //
            double subtrahend = [self popOperandOffStack:stack usingVariableValues:variableValues];
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] - subtrahend;
        }
        else if([operation isEqualToString:@"*"])
        {
            result = [self popOperandOffStack:stack usingVariableValues:variableValues] * [self popOperandOffStack:stack usingVariableValues:variableValues];
        }
        else if([operation isEqualToString:@"/"])
        {
            //check if denominator is 0
            //
            double denominator = [self popOperandOffStack:stack usingVariableValues:variableValues];
            
            if(denominator == 0)
            {
                result = 0;
            }
            else
            {
                result = [self popOperandOffStack:stack usingVariableValues:variableValues] / denominator;
            }
        }//trig functions
        else if([operation isEqualToString:@"sin"])
        {
            result = sin([self popOperandOffStack:stack usingVariableValues:variableValues]);
        }
        else if([operation isEqualToString:@"cos"])
        {
            result = cos([self popOperandOffStack:stack usingVariableValues:variableValues]);
        }
        else if([operation isEqualToString:@"tan"])
        {
            result = tan([self popOperandOffStack:stack usingVariableValues:variableValues]);
        }
        else if([operation isEqualToString:@"sqrt"])
        {
            result = sqrt([self popOperandOffStack:stack usingVariableValues:variableValues]);
        }//pi
        else if([operation isEqualToString:@"π"])
        {
            result = M_PI;
        }
        else
        {
            
            //first lets make sure that the passed dict isnt nil
            //if so then lets set result to 0
            //
            if(variableValues)
            {
                //ok now search thru the dict to see if the
                //var exists in there are grab its value
                //
                if([variableValues objectForKey:operation])
                {
                    result = [[variableValues objectForKey:operation] doubleValue];
                }
                
                
            }
        }
        
    }
    
    //NSLog(@"Is Var: %@", [self isVariable:@"tan"] ? @"YES" : @"NO");
    //NSLog(@"Is Operation %@", [self isOperation:@"tan"]  ? @"YES" : @"NO");
    
    return result;
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    result = [self popOperandOffStack:stack usingVariableValues:nil];
    
    return result;
}

//run a program and return a double answer
//
+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    
    //check if we are dealing with an array
    //
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack];
}

//run a program and return a double answer
//
+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    
    //check if we are dealing with an array
    //
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack usingVariableValues:variableValues];
}

//This method check if the string is a valid variable
//
+(BOOL)isVariable:(NSString *)stringInQuestion
{
    BOOL isVar = NO;
    
    //set up letterCharacterSet action here or not a valid operation
    //
    NSCharacterSet *decimalDigitSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890,."];
    
    if( ([stringInQuestion rangeOfCharacterFromSet:decimalDigitSet].location == NSNotFound)  && (![self isOperation: stringInQuestion]) )
    {
        isVar = YES;
    }
    
    return isVar;
}

//Check if we are a valid operation
//
+(BOOL)isOperation:(NSString *)stringInQuestion
{
    BOOL isOperation = NO;
    
    if([validOperationsSet containsObject:stringInQuestion])
    {
        isOperation = YES;
    }
    
    return isOperation;
    
}

//list out the variables used in the program
//
+(NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *setOfVars = [NSMutableSet set];
    NSString *potentialVarInProgram;
    
    //ok lets loop thru this program if it is an array and
    //then put vars into the set
    //
    //check if we are dealing with an array
    //
    if([program isKindOfClass:[NSArray class]])
    {
        for (id potentialVar in program)
        {
            //lets check if we have a number
            //
            if(![potentialVar isKindOfClass:[NSNumber class]])
            {
            
                potentialVarInProgram = (NSString *)potentialVar;
            
                if([self isVariable:(NSString *)potentialVar])
                {
                    //ok we have a variable
                    //
                    [setOfVars addObject:potentialVar];
                }
            }
        }
    }
    
    //convert to an NSSet and return but only if we have something
    //UGLY
    //
    if(setOfVars.count > 0)
    {
        NSSet *returnSet = [setOfVars copy];
        return returnSet;
    }
    else
    {
        return nil;
    }
    
}


@end
