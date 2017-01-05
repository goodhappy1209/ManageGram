//
//  NetworkUtils.m
//  RXCustomTabBar
//
//  Created by Guoyang on 6/10/14.
//
//

#import "NetworkUtils.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

static NetworkUtils* sharedInstance = nil;


//typedef enum
//{
//    NoConnection = 0,
//    WiFiConnected,
//    WWANConnected
//} NetworkStatus;
//

@implementation NetworkUtils

+(NetworkUtils*) sharedInstance
{
    if(sharedInstance==nil)
        sharedInstance = [[NetworkUtils alloc] init];
    return sharedInstance;
}

- (BOOL)isReachableWithoutRequiringConnection:(SCNetworkReachabilityFlags)flags
{
    BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
    
    BOOL noConnectionRequired = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
        noConnectionRequired = YES;
    }
    
    return (isReachable && noConnectionRequired) ? YES : NO;
}
//
- (BOOL)isHostReachable:(NSString *)host
{
    if (!host || ![host length]) {
        return NO;
    }
    
    SCNetworkReachabilityFlags        flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
    BOOL gotFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    CFRelease(reachability);
    
    if (!gotFlags) {
        return NO;
    }
    
    return [self isReachableWithoutRequiringConnection:flags];
}


- (BOOL)connectedToNetwork {
    
//    return [self isHostReachable:@"www.hostyoureallycareabouthavingaconnectionwith.com"];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable)
        return false;
    else
        return true;
}

@end