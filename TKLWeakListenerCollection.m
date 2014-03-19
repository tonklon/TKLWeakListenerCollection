//
//  TKLWeakListenerCollection.m
//  Tobias Klonk
//
//  Created by Tobias Klonk on 29.01.14.
//  Copyright (c) 2014 Tobias Klonk. All rights reserved.
//

#import "TKLWeakListenerCollection.h"
#import <objc/runtime.h>

@interface TKLWeakListenerWrapper : NSProxy {
  @public
  __weak id _object;
}

+ (instancetype)withObject:(id)object;

@end

@implementation TKLWeakListenerWrapper

+ (id)withObject:(id)object {
  TKLWeakListenerWrapper *instance = [self alloc];
  instance->_object = object;
  return instance;
}

- (NSUInteger)hash {
  return [_object hash];
}

- (BOOL)isEqual:(id)object {
  return [_object isEqual:object];
}

@end

@implementation TKLWeakListenerCollection {
  NSMutableSet *_set;
  Protocol *_protocol;
}

- (instancetype)initWithProtocol:(Protocol*)protocol {
  NSParameterAssert(protocol != nil);
  if (self = [super init]) {
    _protocol = protocol;
    _set = [NSMutableSet set];
  }
  return self;
}

- (id)init {
  return [self initWithProtocol:nil];
}

- (void)addListenerObject:(id)object {
  [_set addObject:[TKLWeakListenerWrapper withObject:object]];
}

- (void)removeListenerObject:(id)object {
  [_set removeObject:object];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  [_set enumerateObjectsUsingBlock:^(TKLWeakListenerWrapper *wrapper, BOOL *stop) {
    if ((wrapper->_object) && [wrapper->_object respondsToSelector:[anInvocation selector]]) {
      [anInvocation invokeWithTarget:wrapper->_object];
    }
  }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  struct objc_method_description theDescription;
  theDescription = protocol_getMethodDescription(_protocol,aSelector, NO, YES);
  if (theDescription.types == NULL) {
    theDescription = protocol_getMethodDescription(_protocol,aSelector, YES, YES);
  }
  if (theDescription.types == NULL) {
    return nil;
  }
  return [NSMethodSignature signatureWithObjCTypes:theDescription.types];
}

@end
