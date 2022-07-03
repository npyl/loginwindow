//
//  AppDelegate.m
//  loginwindow
//
//  Created by Nickolas Pylarinos Stamatelatos on 28/06/2022.
//  Copyright © 2022 Nickolas Pylarinos. All rights reserved.
//

#import "AppDelegate.h"

#import "UserImage.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *userImagesScrollView;
@property (weak) IBOutlet NSButton *evaluatePasswordButton;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //
    //  Get list of users & their respective user photo
    //
    
    // foreach user, create a UserImage
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)enterPasswordClick:(id)sender {
    NSLog(@"%@", _passwordField.stringValue);
    
    
}




@end
