//
//  HTZSequencerTests.m
//  HTZSequencerTests
//
//  Created by Hituzi Ando on 2022/06/02.
//

#import <XCTest/XCTest.h>

#import "HTZSequencer.h"

@interface HTZSequencerTests : XCTestCase

@end

@implementation HTZSequencerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSequencer_All_Steps_Succeeded {
    HTZSequencer *sequencer = [HTZSequencer new];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@{ @"message": @"First" }, nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        XCTAssertEqualObjects(result[@"message"], @"First");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Second", nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        XCTAssertEqualObjects(result, @"Second");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@{ @"key": @"Jf;kldajf;klaj" }, nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        XCTAssertEqualObjects(result[@"key"], @"Jf;kldajf;klaj");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@104, nil);
        });
    }];
    [sequencer finally:^(id _Nullable result, NSError *_Nullable error) {
        XCTAssertEqual(result, @104);
        XCTAssertNil(error);
    }];
}

- (void)testSequencer_Error_Occurred {
    HTZSequencer *sequencer = [HTZSequencer new];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@{ @"message": @"First" }, nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        XCTAssertEqualObjects(result[@"message"], @"First");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Second", nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        XCTAssertEqualObjects(result, @"Second");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, [NSError errorWithDomain:@"Test" code:3 userInfo:nil]);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion _Nonnull completion) {
        // This step is skipped.
        XCTFail();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Fourth", nil);
        });
    }];
    [sequencer finally:^(id _Nullable result, NSError *_Nullable error) {
        XCTAssertNil(result);
        XCTAssertEqualObjects(error.domain, @"Test");
        XCTAssertEqual(error.code, 3);
    }];
}

- (void)testSequencer_Error_Occurred_And_Recover {
    HTZSequencer *sequencer = [HTZSequencer new];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@{ @"message": @"First" }, nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(result[@"message"], @"First");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, [NSError errorWithDomain:@"Test" code:2 userInfo:nil]);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion completion) {
        // This step is skipped.
        XCTFail();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Third", nil);
        });
    }];
    [sequencer catch:^(NSError *error, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(error.domain, @"Test");
        XCTAssertEqual(error.code, 2);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Fourth", nil);
        });
    }];
    [sequencer catch:^(NSError *error, HTZSequencerCompletion completion) {
        // This step is skipped.
        XCTFail();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Fifth", nil);
        });
    }];
    [sequencer then:^(id _Nullable result, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(result, @"Fourth");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, [NSError errorWithDomain:@"Test" code:6 userInfo:nil]);
        });
    }];
    [sequencer catch:^(NSError *error, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(error.domain, @"Test");
        XCTAssertEqual(error.code, 6);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@107, nil);
        });
    }];
    [sequencer finally:^(id _Nullable result, NSError *_Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(result, @107);
    }];

    // Method chaining.
    [[[[[[[[HTZSequencer sequencer:^(id _Nullable result, HTZSequencerCompletion completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@{ @"message": @"First" }, nil);
        });
    }] then:^(id _Nullable result, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(result[@"message"], @"First");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, [NSError errorWithDomain:@"Test" code:2 userInfo:nil]);
        });
    }] then:^(id _Nullable result, HTZSequencerCompletion completion) {
        // This step is skipped.
        XCTFail();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Third", nil);
        });
    }] catch:^(NSError *error, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(error.domain, @"Test");
        XCTAssertEqual(error.code, 2);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Fourth", nil);
        });
    }] catch:^(NSError *error, HTZSequencerCompletion completion) {
        // This step is skipped.
        XCTFail();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@"Fifth", nil);
        });
    }] then:^(id _Nullable result, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(result, @"Fourth");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(nil, [NSError errorWithDomain:@"Test" code:6 userInfo:nil]);
        });
    }] catch:^(NSError *error, HTZSequencerCompletion completion) {
        XCTAssertEqualObjects(error.domain, @"Test");
        XCTAssertEqual(error.code, 6);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(@107, nil);
        });
    }] finally:^(id _Nullable result, NSError *_Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(result, @107);
    }];
}

@end
