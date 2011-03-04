//
//  FilterParameterParser.m
//  CoreImageTool
//
//  Created by Marc Liyanage on 03.08.07.
//  Copyright 2007-2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "FilterParameterParser.h"


@implementation FilterParameterParser


+ (FilterParameterParser *)parserForFilterName:(NSString *)filterName imageSource:(id<KeyedImageSource>) imageSource {
	Class parserClass = [FilterParameterParser classForFilterName:filterName];
	FilterParameterParser *parser = [[[parserClass alloc] init] autorelease];
	if (!parser) {
		NSLog(@"Unable to create filter parameter parser for filter name '%@'", filterName);
		return nil;
	}
	[parser setValue:imageSource forKey:@"imageSource"];
	return parser;
}


- (void) dealloc {
	[imageSource release];
	[super dealloc];
}



+ (Class)classForFilterName:(NSString *)filterName {
	Class class = NSClassFromString([NSString stringWithFormat:@"FilterParameterParser%@", filterName]);
	if (class) return class;
	return NSClassFromString(@"FilterParameterParserGeneric");
}


- (BOOL)configureFilter:(CIFilter *)filter withParameterString:(NSString *)parameterString {
	[NSException raise:NSGenericException format:@"%@ is abstract", NSStringFromSelector(_cmd)];
	return NO; // not reached
}


- (NSDictionary *)splitParameterString:(NSString *)string {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSArray *pairs = [string componentsSeparatedByString:@":"];
	NSUInteger i, count = [pairs count];
	if (count < 1) {
		NSLog(@"empty parameter string");
		return parameters;
	}
	for (i = 0; i < count; i++) {
		NSString *pair = [pairs objectAtIndex:i];
		NSArray *keyvalue = [pair componentsSeparatedByString:@"="];
		if ([keyvalue count] != 2) {
			NSLog(@"invalid parameter key/value pair '%@'", pair);
			continue;
		}
		NSString *key = [keyvalue objectAtIndex:0];
		NSString *firstLetter = [[key substringToIndex:1] capitalizedString];
		NSString *tail = [key substringFromIndex:1];
		NSString *inputName = [[@"input" stringByAppendingString:firstLetter] stringByAppendingString:tail];
		[parameters setValue:[keyvalue objectAtIndex:1] forKey:inputName];
	}
	return parameters;
}



- (id)string:(NSString *)string toValueOfClass:(NSString *)className {
	id value = [ValueClassConverter convertString:string toValueOfClass:className imageSource:imageSource];
	return value;
}



@end
