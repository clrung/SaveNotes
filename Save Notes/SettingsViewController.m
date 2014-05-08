//
//  SettingsViewController.m
//  Save Notes
//
//  Created by Christopher Rung on 5/6/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import "SettingsViewController.h"
#import <Dropbox/Dropbox.h>

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end
CGFloat textSize = 14;
@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// Links the user's Dropbox account with the application.  If the account is
// already linked, this unlinks the account.  Also toggles button between
// link Dropbox account and unlink Dropbox account.
//
- (IBAction)didTouchLink:(id)sender {
    
    if(![[[DBAccountManager sharedManager] linkedAccount] isLinked]) {
        [[DBAccountManager sharedManager] linkFromController:self];
        [self.linkButton setTitle:@"Unlink Dropbox Account" forState:UIControlStateNormal];
    }
    else {
        [[[DBAccountManager sharedManager] linkedAccount] unlink];
        
        [[[UIAlertView alloc]
          initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
          [self updateButtons];
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    textSize = sender.value;
    _textSizeLabel.text =  [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)updateButtons {
    NSString* title = [[[DBAccountManager sharedManager] linkedAccount] isLinked] ? @"Unlink Dropbox Account" : @"Link Dropbox Account";
    [self.linkButton setTitle:title forState:UIControlStateNormal];
}

+ (CGFloat)getTextSize {
    return textSize;
}
@end
