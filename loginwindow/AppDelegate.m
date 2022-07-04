//
//  AppDelegate.m
//  loginwindow
//
//  Created by Nickolas Pylarinos Stamatelatos on 28/06/2022.
//  Copyright © 2022 Nickolas Pylarinos. All rights reserved.
//

#import "AppDelegate.h"

#include <security/pam_appl.h>
#include <security/openpam.h>    /* for openpam_ttyconv() */

#include <pwd.h>

#import <OpenDirectory/OpenDirectory.h>

#import "UserImage.h"

static pam_handle_t *pamh;
static struct pam_conv pamc;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *userImagesScrollView;
@property (weak) IBOutlet NSButton *evaluatePasswordButton;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSError *error;
    
    //
    //  Get list of users & their respective user photo
    //
    ODSession   *session;
    ODNode      *node;
    ODQuery     *query;
    
    session = [ODSession sessionWithOptions:nil error:&error];
    if (!session)
        goto OpenDirectoryError;

    node = [ODNode nodeWithSession:session type:kODNodeTypeLocalNodes error:&error];
    if (!node)
        goto OpenDirectoryError;
    
    query = [ODQuery queryWithNode:node
                    forRecordTypes:kODRecordTypeUsers
                         attribute:nil
                         matchType:kODMatchAny
                       queryValues:nil
                  returnAttributes:kODAttributeTypeNFSHomeDirectory
                    maximumResults:100
                             error:&error];
    if (!query)
        goto OpenDirectoryError;

    for (ODRecord *record in [query resultsAllowingPartial:NO error:&error]) {
        NSDictionary *attributes = [record recordDetailsForAttributes:@[kODAttributeTypeNFSHomeDirectory] error:&error];
        if (!attributes)
            goto OpenDirectoryError;
  
        NSArray *homeDirectories = [attributes objectForKey:@"dsAttrTypeStandard:NFSHomeDirectory"];
        if (homeDirectories.count != 1)
            continue;
        
        NSString *homeDirectory = homeDirectories.lastObject;
        if (!homeDirectory)
        {
            NSLog(@"Error!");
            continue;
        }

        if (![homeDirectory containsString:@"/Users"])
            continue;

        NSLog(@"%@: %@", record.recordName, homeDirectory);
    }

    // foreach user, create a UserImage
    
    
    //
    //  Handle Error
    //
    return;
OpenDirectoryError:
    NSLog(@"OpenDirectory Error: %@", error);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)enterPasswordClick:(id)sender {
    NSLog(@"%@", _passwordField.stringValue);
    
    char hostname[MAXHOSTNAMELEN];
    const char *tty;
    char **pam_envlist, **pam_env;
    struct passwd *pwd;
    int o, pam_err, status;
    
    const char* user = "root";

    // TODO: on production a.k.a. Ryven OS this should be called "loginwindow" (or something similar of our choosing)
    const char* pam_service = "whatever";
    
    pam_start(pam_service, user, &pamc, &pamh);
    
    /* set some items */
    gethostname(hostname, sizeof(hostname));
    if ((pam_err = pam_set_item(pamh, PAM_RHOST, hostname)) != PAM_SUCCESS)
        goto pamerr;
    user = getlogin();
    if ((pam_err = pam_set_item(pamh, PAM_RUSER, user)) != PAM_SUCCESS)
        goto pamerr;
    tty = ttyname(STDERR_FILENO);
    if ((pam_err = pam_set_item(pamh, PAM_TTY, tty)) != PAM_SUCCESS)
        goto pamerr;

    /* authenticate the applicant */
    if ((pam_err = pam_authenticate(pamh, 0)) != PAM_SUCCESS)
        goto pamerr;
    NSLog(@"%@", @"1");

    if ((pam_err = pam_acct_mgmt(pamh, 0)) == PAM_NEW_AUTHTOK_REQD)
        pam_err = pam_chauthtok(pamh, PAM_CHANGE_EXPIRED_AUTHTOK);
    if (pam_err != PAM_SUCCESS)
        goto pamerr;
    NSLog(@"%@", @"2");

    /* establish the requested credentials */
    if ((pam_err = pam_setcred(pamh, PAM_ESTABLISH_CRED)) != PAM_SUCCESS)
        goto pamerr;
    NSLog(@"%@", @"3");

    /* authentication succeeded; open a session */
    if ((pam_err = pam_open_session(pamh, 0)) != PAM_SUCCESS)
        goto pamerr;

    /* get mapped user name; PAM may have changed it */
    pam_err = pam_get_item(pamh, PAM_USER, (const void **)&user);
    if (pam_err != PAM_SUCCESS || (pwd = getpwnam(user)) == NULL)
        goto pamerr;

    /* export PAM environment */
    if ((pam_envlist = pam_getenvlist(pamh)) != NULL) {
        for (pam_env = pam_envlist; *pam_env != NULL; ++pam_env) {
            putenv(*pam_env);
            free(*pam_env);
        }
        free(pam_envlist);
    }

    
    return;

pamerr:
    NSLog(@"PAM Error: %s", pam_strerror(pamh, pam_err));
}




@end
