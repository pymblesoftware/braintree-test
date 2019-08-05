//
//  AppDelegate.h
//  Test3
//
//  Created by Regan Russell on 5/8/19.
//  Copyright © 2019 PymbleSoftware Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

