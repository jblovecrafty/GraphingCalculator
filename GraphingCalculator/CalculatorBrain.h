//
//  CalculatorBrain.h
//  Calculator_2
//
//  Created by Joe Jones on 8/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void) pushOperand:(double)operand;

-(void) pushVariable:(NSString *)variable;


//bad design but I am following the tutorial so I will redesign later...
//maybe pass in an enum for the operation
//
-(double) performOperation:(NSString *)operation;

-(double) performOperation:(NSString *)operation
                          usingVariableValues:(NSDictionary *)variableValues;

-(void) clearOperandStack;

-(void) clearLastOperand;


@property (readonly) id program;

+(double)runProgram:(id)program;

+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

+(NSSet *)variablesUsedInProgram:(id)program;

+(NSString *)descriptionOfProgram:(id)program;

+(BOOL)isVariable:(NSString *)stringInQuestion;
+(BOOL)isOperation:(NSString *)stringInQuestion;

@end
