//
//  GraphingCalculationProtocol.h
//  GraphingCalculator
//
//  Created by Joe Jones on 9/11/12.
//  Copyright (c) 2012 Joe Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GraphingCalculationProtocol
-(CGFloat) calculateY:(CGFloat)xValue;
-(BOOL)areUserDefaultsSet;
-(void)saveUserOrigin:(CGPoint)userOrigin;
-(void)saveUserScale:(CGFloat)userScale;
-(CGPoint)getSavedUserOrigin;
-(CGFloat)getSaveUserScale;
@end
