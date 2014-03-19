//
//  WeakListenerCollectionSpec.m
//  Tobias Klonk
//
//  Created by Tobias Klonk on 29.01.14.
//  Copyright 2014 Tobias Klonk. All rights reserved.
//

#import "Kiwi.h"
#import "TKLWeakListenerCollection.h"

struct SomeStruct {
  int field;
};

@protocol ListenerProtocol <NSObject>

- (void)listenToEvent1:(NSString* )string;

@optional

- (void)listenToEvent2:(struct SomeStruct)rect;

@end

@interface Listener1 : NSObject <ListenerProtocol> @end

@interface Listener2 : NSObject <ListenerProtocol> @end

@implementation Listener1

- (void)listenToEvent1:(NSString *)string {

}

@end

@implementation Listener2

- (void)listenToEvent1:(NSString *)string {

}

- (void)listenToEvent2:(struct SomeStruct)rect {

}

@end

SPEC_BEGIN(TKLWeakListenerCollectionSpec)

__block id collection;

beforeEach(^{
  collection = [[TKLWeakListenerCollection alloc] initWithProtocol:@protocol(ListenerProtocol)];
});

it(@"forwards messages to its listeners", ^{
  Listener1 *listener = [[Listener1 alloc] init];

  [collection addListenerObject:listener];

  [[[listener should] receive] listenToEvent1:@"foo"];
  [collection listenToEvent1:@"foo"];
});

it(@"supports removing an listener", ^{
  Listener1 *listener = [[Listener1 alloc] init];

  [collection addListenerObject:listener];
  [collection removeListenerObject:listener];

  [[[listener shouldNot] receive] listenToEvent1:@"foo"];
  [collection listenToEvent1:@"foo"];
});

it(@"forwards messages to multiple listeners", ^{
  Listener1 *listener1 = [[Listener1 alloc] init];
  Listener2 *listener2 = [[Listener2 alloc] init];
  Listener1 *listener3 = [[Listener1 alloc] init];

  [collection addListenerObject:listener1];
  [collection addListenerObject:listener2];
  [collection addListenerObject:listener3];

  [[[listener1 should] receive] listenToEvent1:@"foo"];
  [[[listener2 should] receive] listenToEvent1:@"foo"];
  [[[listener3 should] receive] listenToEvent1:@"foo"];
  [collection listenToEvent1:@"foo"];
});

it(@"forwards messages only to listeners which respond to it", ^{
  Listener1 *listener1 = [[Listener1 alloc] init];
  Listener2 *listener2 = [[Listener2 alloc] init];
  Listener1 *listener3 = [[Listener1 alloc] init];

  [collection addListenerObject:listener1];
  [collection addListenerObject:listener2];
  [collection addListenerObject:listener3];

  [[[listener2 should] receive] listenToEvent2:(struct SomeStruct) { 1 }];

  [[theBlock(^{
    [collection listenToEvent2:(struct SomeStruct) { 1 }];
  }) shouldNot] raise];
});

it(@"keeps weak references to its listeners", ^{
  __weak Listener1 *listener3;

  @autoreleasepool {

    Listener1 *listener1 = [[Listener1 alloc] init];
    Listener2 *listener2 = [[Listener2 alloc] init];
    Listener1 *listener = [[Listener1 alloc] init];

    [collection addListenerObject:listener1];
    [collection addListenerObject:listener2];
    [collection addListenerObject:listener];

    listener3 = listener;

  }

  [listener3 shouldBeNil];

  [[theBlock(^{
    [collection listenToEvent1:@"foo"];
  }) shouldNot] raise];

});

SPEC_END
