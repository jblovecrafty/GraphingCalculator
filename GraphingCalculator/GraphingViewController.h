//
//  GraphingViewController.h
//  GraphingCalculator
//
//  Created by Joe Jones on 9/10/12.
//  Copyright (c) 2012 Joe Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphingView.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphingViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (weak, nonatomic) IBOutlet UILabel *equationLabel;
@property (weak, nonatomic) IBOutlet GraphingView *graph;
@property (strong,nonatomic) id program;

-(void) recalculateGraph;

@end
