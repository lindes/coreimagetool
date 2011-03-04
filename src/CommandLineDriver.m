//
//  CommandLineDriver.m
//  CoreImageTool
//
//  Created by Marc Liyanage on 02.08.07.
//  Copyright 2007-2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "CommandLineDriver.h"
#include <stdio.h>


@implementation CommandLineDriver


+ (int)runWithArguments:(const char*[])argv count:(int)argc {

	int result, iterations = 1, i;
	for (i = 0; i < iterations; i++) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[CIPlugIn loadAllPlugIns];
		CommandLineDriver *cld = [CommandLineDriver driverForArguments:argv count:argc];
		result = [cld run];
		[pool release];
	}

	if (0) {
		char foo[100];
		fprintf(stderr, "hit any key...\n");
		fgets(foo, 100, stdin);
	}
	
	return result;
}


+ (CommandLineDriver *)driverForArguments:(const char*[])argv count:(int)argc {
	return [[[CommandLineDriver alloc] initWithArguments:argv count:argc] autorelease];
}


- (CommandLineDriver *)initWithArguments:(const char*[])argv count:(int)argc {
	self = [super init];
	if (!self) return nil;

	arguments = [[NSMutableArray alloc] init];
	programName = [[NSString stringWithUTF8String:argv[0]] retain];
	int i;
	for (i = 1; i < argc; i++) {
		[arguments addObject:[NSString stringWithUTF8String:argv[i]]];
	}

	[self setValue:[NSMutableDictionary dictionary] forKey:@"processors"];
	
	return self;

}


- (void) dealloc {
	[programName release];
	[arguments release];
	[processors release];
	[super dealloc];
}


- (int)run {

	NSUInteger i, count = [arguments count];
	
	if (count < 1) {
		fprintf(stderr, "Usage: CoreImageTool action key parameters [action key parameters ...]\n");
		fprintf(stderr, "See http://www.entropy.ch/software/macosx/coreimagetool for details\n");
		return 1;
	}
	
	for (i = 0; i < count; i++) {
		NSString *actionKey = [arguments objectAtIndex:i];
		Action *action = [Action actionForKey:actionKey];
		if (!action) continue;
		[action setValue:self forKey:@"logger"];

		NSUInteger availableArguments = [arguments count] - (i + 1);
		NSArray *lookaheadArguments =
			availableArguments > 0 ?
			[arguments subarrayWithRange:NSMakeRange(i + 1, availableArguments)]
			: [NSArray array];
		int requiredParameterCount = [action requiredParameterCount:lookaheadArguments];
		if (availableArguments < requiredParameterCount) {
			NSLog(@"action '%@' expects %d parameters but only %lu arguments remain", actionKey, requiredParameterCount, availableArguments);
			return 1;
		}

		NSMutableArray *actionParameters = [NSMutableArray array];
		int j;
		for (j = 0; j < requiredParameterCount; j++) {
			i++;
			[actionParameters addObject:[arguments objectAtIndex:i]];
		}
		
		BOOL result = [action runWithParameters:actionParameters processors:processors];
		if (!result) {
			NSLog(@"action '%@' failed", actionKey);
			return 1;
		}
	}

	return 0;
}


- (void)logVerbose:(NSString *)message {
	if (!verbose) return;
	NSLog(@"%@", message);
}


- (void)setVerbose:(BOOL)newVerbose {
	verbose = newVerbose;
}



@end
