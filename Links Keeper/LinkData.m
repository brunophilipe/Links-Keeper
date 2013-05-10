//
//  LinkData.m
//  Links Keeper
//
//  Created by Bruno Philipe on 3/29/13.
//	Copyright (C) 2013 Bruno Philipe
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

/**
 Instantiates the object with the data from the coder. Used for de-serialization.
 @param aDecoder The decoder containing the serialized data for the instance.
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];

	self.name = [aDecoder decodeObjectForKey:@"name"];
	self.url = [aDecoder decodeObjectForKey:@"url"];

	return self;
}

/**
 Sets the instance variables from the object into the coder. Used for serialization.
 @param aCoder The coder to insert the data.
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.url forKey:@"url"];
}

@end
