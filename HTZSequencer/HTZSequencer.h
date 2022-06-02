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

#import <Foundation/Foundation.h>

//! Project version number for HTZSequencer.
FOUNDATION_EXPORT double HTZSequencerVersionNumber;

//! Project version string for HTZSequencer.
FOUNDATION_EXPORT const unsigned char HTZSequencerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HTZSequencer/PublicHeader.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^HTZSequencerCompletion)(id _Nullable result, NSError *_Nullable error);
typedef void(^HTZSequencerThen)(id _Nullable result, HTZSequencerCompletion completion);
typedef void(^HTZSequencerCatch)(NSError *error, HTZSequencerCompletion completion);

@interface HTZSequencer : NSObject

+ (instancetype)sequencer:(HTZSequencerThen)block;
/**
 * Adds a success handler.
 */
- (instancetype)then:(HTZSequencerThen)block;
/**
 * Adds an error handler.
 */
- (instancetype)catch:(HTZSequencerCatch)block;
/**
 * Runs added steps.
 */
- (void)finally:(nullable HTZSequencerCompletion)completion;

@end

NS_ASSUME_NONNULL_END