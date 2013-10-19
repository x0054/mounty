//
//  main.m
//  mounty
//
//  Created by Bogdan on 9/24/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//
//  This is a tool for mounting network shares based on the SSID network the computer is connected to
//  


#import <Foundation/Foundation.h>
#import <NetFS/NetFS.h>
#import <CoreWLAN/CoreWLAN.h>

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        if(argc>=4){
            NSArray *arguments = [[NSProcessInfo processInfo] arguments];
            //NSLog(@"%@", arguments);
            NSString * share = arguments[1];
            NSString * path = arguments[2];
            NSString * ssid = arguments[3];
            
            
            // Check if connected to right SSID
            CWInterface *wif = [CWInterface interface];
            //NSString *wifissid = wif.ssid;
            if (![wif.ssid isEqualToString:ssid]) {
                printf("You are NOT connected to the right WiFi Base Station\n");
                return 0;
            }
            
            // Check if the Share is allready Mounted
            NSArray * keys = [NSArray arrayWithObjects:NSURLVolumeURLForRemountingKey, nil];
            NSArray * mountPaths = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:keys options:0];
            
            NSError * error;
            NSURL * remount;
            
            for (NSURL * mountPath in mountPaths) {
                [mountPath getResourceValue:&remount forKey:NSURLVolumeURLForRemountingKey error:&error];
                if(remount){
                    if ([[[NSURL URLWithString:share] host] isEqualToString:[remount host]] && [[[NSURL URLWithString:share] path] isEqualToString:[remount path]]) {
                        printf("Already mounted at %s\n", [[mountPath path] UTF8String]);
                        return 0;
                    }
                }
            }
            
            // Check if the Folder Exists
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            BOOL isDir;
            if (![fileManager fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
                printf("Mount Point deos NOT Exist. Please specify a valid mount point.\n");
                return 0;
            }
            
            CFMutableDictionaryRef mount_options = CFDictionaryCreateMutable( NULL, 0, NULL, NULL);
            CFDictionarySetValue(mount_options, kNetFSSoftMountKey, kCFBooleanTrue);
            CFDictionarySetValue(mount_options, kNetFSMountAtMountDirKey, kCFBooleanTrue);
            CFArrayRef mountpoints = NULL;
            
            OSStatus err = NetFSMountURLSync(
                                             (__bridge CFURLRef) [NSURL URLWithString: share],	// URL to mount, e.g. nfs://server/path
                                             (__bridge CFURLRef) [NSURL URLWithString: path],	// Path for the mountpoint
                                             NULL,                                             // Auth user name (overrides URL)
                                             NULL,                                             // Auth password (overrides URL)
                                             NULL,                                             // Options for session open (see below)
                                             mount_options,                                    // Options for mounting (see below)
                                             &mountpoints);                                    // Array of mountpoints
            
            if(err != noErr)
                printf("Problems mounting the drive! Error %d", (int)err);
        }else{
            printf("Too few arguments. Expected: mounty smb://server/share /mount/pint WiFi_SSID\n");
        }
        return 0;
    }
}
