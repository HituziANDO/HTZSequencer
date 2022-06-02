//
//  HTZSequencer.h
//  HTZSequencer
//
//  Created by Hituzi Ando on 2022/06/02.
//
//  forked from Sequencer
//  https://github.com/berzniz/Sequencer
//
//  Copyright (c) 2022 Hituzi Ando
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "HTZSequencer.h"

@interface HTZSequencerStep : NSObject
@property (nonatomic, copy, nullable) HTZSequencerThen thenBlock;
@property (nonatomic, copy, nullable) HTZSequencerCatch catchBlock;
/**
 * Tells whether this step is the error handler.
 */
@property (nonatomic, readonly) BOOL isError;
@end

@implementation HTZSequencerStep

- (BOOL)isError {
    return self.catchBlock != nil;
}

@end

@interface HTZSequencer ()
@property (nonatomic, copy) NSMutableArray<HTZSequencerStep *> *steps;
@end

@implementation HTZSequencer

+ (instancetype)sequencer:(HTZSequencerThen)block {
    return [[HTZSequencer new] then:block];
}

- (id)init {
    if (self = [super init]) {
        _steps = [NSMutableArray new];
    }
    return self;
}

- (instancetype)then:(HTZSequencerThen)block {
    HTZSequencerStep *step = [HTZSequencerStep new];
    step.thenBlock = [block copy];
    [self.steps addObject:step];
    return self;
}

- (instancetype)catch:(HTZSequencerCatch)block {
    HTZSequencerStep *step = [HTZSequencerStep new];
    step.catchBlock = [block copy];
    [self.steps addObject:step];
    return self;
}

- (void)finally:(nullable HTZSequencerCompletion)completion {
    [self runNextStepWithResult:nil error:nil completion:completion];
}

#pragma mark - private method

- (nullable HTZSequencerStep *)dequeueNextThenStep {
    if (self.steps.count <= 0) {
        return nil;
    }

    // Dequeue
    HTZSequencerStep *step = self.steps[0];
    [self.steps removeObjectAtIndex:0];

    if (step.isError) {
        // This step is "catch".
        return [self dequeueNextThenStep];
    }

    return step;
}

- (nullable HTZSequencerStep *)dequeueNextCatchStep {
    if (self.steps.count <= 0) {
        return nil;
    }

    // Dequeue
    HTZSequencerStep *step = self.steps[0];
    [self.steps removeObjectAtIndex:0];

    if (!step.isError) {
        // This step is "then".
        return [self dequeueNextCatchStep];
    }

    return step;
}

- (void)runNextStepWithResult:(nullable id)result
                        error:(nullable NSError *)error
                   completion:(nullable HTZSequencerCompletion)completion {
    if (error) {
        HTZSequencerStep *catchStep = [self dequeueNextCatchStep];

        if (!catchStep) {
            // Finish
            if (completion) {
                completion(nil, error);
            }

            return;
        }

        catchStep.catchBlock(error, ^(id _Nullable nextResult,
                                      NSError *_Nullable nextError) {
            [self runNextStepWithResult:nextResult
                                  error:nextError
                             completion:completion];
        });

        return;
    }

    HTZSequencerStep *thenStep = [self dequeueNextThenStep];

    if (!thenStep) {
        // Finish
        if (completion) {
            completion(result, nil);
        }

        return;
    }

    thenStep.thenBlock(result, ^(id _Nullable nextResult,
                                 NSError *_Nullable nextError) {
        [self runNextStepWithResult:nextResult
                              error:nextError
                         completion:completion];
    });
}

@end
