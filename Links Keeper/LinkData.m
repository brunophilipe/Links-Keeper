//
//  LinkData.m
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import "LinkData.h"

@implementation LinkData

+ (LinkData *)linkDataWithName:(NSString *)name andURL:(NSURL *)url
{
	LinkData *ld = [[LinkData alloc] init];
	[ld setName:name];
	[ld setUrl:url];
	return ld;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];

	self.name = [aDecoder decodeObjectForKey:@"name"];
	self.url = [aDecoder decodeObjectForKey:@"url"];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.url forKey:@"url"];
}



@end
