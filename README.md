HTZSequencer
=========

HTZSequencer is a library for asynchronous flow control on iOS and macOS.

HTZSequencer turns complicated nested blocks logic into a clean, straightforward, and readable code.

This library is forked from [berzniz/Sequencer](https://github.com/berzniz/Sequencer). Thank you!

## Installation

### Carthage

HTZSequencer is available through [Carthage](https://github.com/Carthage/Carthage). To install it, simply add the following line to your Cartfile:

```
github "HituziANDO/HTZSequencer"
```

You run the following command in the Terminal.

```
carthage update --use-xcframeworks
```

## Usage

### 1. Import framework

#### Objective-C

```objc
#import <HTZSequencer/HTZSequencer.h>
```

#### Swift

```swift
import HTZSequencer
```

### 2. Write asynchronous flow

The sample code is following.

#### Objective-C

```objc
HTZSequencer *sequencer = [HTZSequencer new];
[sequencer then:^(id result, HTZSequencerCompletion completion) {
    // First async step.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // If succeeded, complete with a result.
        completion(@"First", nil);
    });
}];
[sequencer then:^(id result, HTZSequencerCompletion completion) {
    // `result` is the result from first async step.

    // Second async step.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // If failed, complete with an error.
        // If an error is passed, the sequencer calls next catch block.
        completion(nil, [NSError errorWithDomain:@"Test" code:2 userInfo:nil]);
    });
}];
[sequencer then:^(id result, HTZSequencerCompletion completion) {
    // This block is skipped 
    // because second async step passed an error.
}];
[sequencer catch:^(NSError *error, HTZSequencerCompletion completion) {
    // `error` is the error from second async step.
    // Something to do for error handling.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // If the error handling is successfully completed,
        // pass nil to 2nd argument as the error.
        completion(@{ @"message": @"success" }, nil);
    });
}];
[sequencer finally:^(id result, NSError *error) {
    // `result[@"message"]` is "success" passed from last async step.
    // `error` is nil, and this means successfully completed.
}];
```

#### Swift

```swift
HTZSequencer { _, completion in
    // First async step.
    DispatchQueue.global().async {
        // If succeeded, complete with a result.
        completion("First", nil)
    }
}.then { result, completion in
    // `result` is the result from first async step.

    // Second async step.
    DispatchQueue.global().async {
        // If failed, complete with an error.
        // If an error is passed, the sequencer calls next catch block.
        completion(nil, NSError(domain: "Test", code: 2))
    }
}.then { _, completion in
    // This block is skipped 
    // because second async step passed an error.
}.catch { error, completion in
    // `error` is the error from second async step.
    // Something to do for error handling.
    DispatchQueue.global().async {
        // If the error handling is successfully completed,
        // pass nil to 2nd argument as the error.
        completion(["message": "success"], nil)
    }
}.finally { result, error in
    // `result["message"]` is "success" passed from last async step.
    // `error` is nil, and this means successfully completed.
}
```

More sample, see [this code](https://github.com/HituziANDO/HTZSequencer/blob/master/HTZSequencerTests/HTZSequencerTests.m).
