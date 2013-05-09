//
//  LinkData.h
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkData : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *url;

+ (LinkData *)linkDataWithName:(NSString *)name andURL:(NSURL *)url;

@end
