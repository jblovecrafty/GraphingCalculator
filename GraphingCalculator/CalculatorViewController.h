//
//  CalculatorViewController.h
//  Calculator_2
//
//  Created by Joe Jones on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableViewController.h"

@interface CalculatorViewController : RotatableViewController
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *historyDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variableValueDisplay;
@end
