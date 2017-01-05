//
//  NetworkUtils.h
//  RXCustomTabBar
//
//  Created by Guoyang on 6/10/14.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface NetworkUtils : NSObject

+ (NetworkUtils*) sharedInstance;
//int getNetworkStatus();
- (BOOL)connectedToNetwork;

@end
