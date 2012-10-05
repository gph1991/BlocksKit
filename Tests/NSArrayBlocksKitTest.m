//
//  NSArrayBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSArrayBlocksKitTest.h"

@implementation NSArrayBlocksKitTest {
	NSArray *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = @[ @"1", @"22", @"333" ];
	_total = 0;
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	BKSenderBlock senderBlock = ^(id sender) {
		_total += [sender length];
	};
	[_subject each:senderBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testMatch {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];

	//match: is functionally identical to select:, but will stop and return on the first match
	STAssertEquals(_total, (NSInteger)3, @"total length of \"122\" is %d", _total);
	STAssertEquals(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];

	// @return Returns the object if found, `nil` otherwise.
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertNil(found, @"no matched object");
}

- (void)testSelect {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = [NSArray arrayWithObjects:@"1",@"22",nil];
	STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertFalse(found.count, @"no item is selected");
}

- (void)testReject {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = [NSArray arrayWithObjects:@"1",@"22",nil];
	STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertFalse(left.count, @"all items are rejected");
}

- (void)testMap {
	BKTransformBlock transformBlock = ^id(id obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSArray *transformed = [_subject map:transformBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = [NSArray arrayWithObjects:@"1",@"2",@"3",nil];
	STAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testReduceWithBlock {
	BKAccumulationBlock accumlationBlock = ^id(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject reduce:@"" withBlock:accumlationBlock];
	STAssertTrue([concatenated isEqualToString: @"122333"], @"concatenated string is %@", concatenated);
}

- (void)testAny {
    // Check if array has element with prefix 1
    BKValidationBlock existsBlockTrue = ^BOOL(id obj) {
        return [obj hasPrefix: @"1"];
    };
    
    BKValidationBlock existsBlockFalse = ^BOOL(id obj) {
        return [obj hasPrefix: @"4"];
    };
    
    BOOL letterExists = [_subject any: existsBlockTrue];
    STAssertTrue(letterExists, @"letter is not in array");
    
    BOOL letterDoesNotExist = [_subject any: existsBlockFalse];
    STAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
    NSArray *names = [NSArray arrayWithObjects: @"John", @"Joe", @"Jon", @"Jester", nil];
    NSArray *names2 = [NSArray arrayWithObjects: @"John", @"Joe", @"Jon", @"Mary", nil];
    
    // Check if array has element with prefix 1
    BKValidationBlock nameStartsWithJ = ^BOOL(id obj) {
        return [obj hasPrefix: @"J"];
    };

    BOOL allNamesStartWithJ = [names all: nameStartsWithJ];
    STAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");
    
    BOOL allNamesDoNotStartWithJ = [names2 all: nameStartsWithJ];
    STAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");  
}

- (void)testNone {
    NSArray *names = [NSArray arrayWithObjects: @"John", @"Joe", @"Jon", @"Jester", nil];
    NSArray *names2 = [NSArray arrayWithObjects: @"John", @"Joe", @"Jon", @"Mary", nil];
    
    // Check if array has element with prefix 1
    BKValidationBlock nameStartsWithM = ^BOOL(id obj) {
        return [obj hasPrefix: @"M"];
    };
	
	BOOL noNamesStartWithM = [names none: nameStartsWithM];
	STAssertTrue(noNamesStartWithM, @"some names start with M in array");
	
	BOOL someNamesStartWithM = [names2 none: nameStartsWithM];
	STAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
    NSArray *numbers = [NSArray arrayWithObjects: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil];
    NSArray *letters = [NSArray arrayWithObjects: @"1", @"2", @"3", nil];
    BOOL doesCorrespond = [numbers corresponds: letters withBlock: ^(id number, id letter) {
        return [[number stringValue] isEqualToString: letter];
    }];
    STAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
    
}

@end
