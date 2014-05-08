//
//  SettingsViewController.h
//  Save Notes
//
//  Created by Christopher Rung on 5/6/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//
//  This class manages the Settings view controller.

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *textSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *textSizeLabel;
- (IBAction)sliderValueChanged:(UISlider *)sender;
+ (CGFloat) getTextSize;

@end