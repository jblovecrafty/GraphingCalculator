//
//  GraphingCalculatorView.h
//  GraphingCalculator
//
//  Created by Joe Jones on 9/10/12.
//  Copyright (c) 2012 Joe Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphingCalculationProtocol.h"

@interface GraphingView : UIView

@property (nonatomic) CGPoint currentOrigin;
@property (nonatomic) CGFloat currentScale;
@property (nonatomic, weak) id <GraphingCalculationProtocol>datasource;

@end
