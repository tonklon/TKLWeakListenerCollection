//
//  TKLWeakListenerCollection.h
//  Tobias Klonk
//
//  Created by Tobias Klonk on 20.01.14.
//  Copyright (c) 2014 Tobias Klonk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKLWeakListenerCollection : NSObject

- (instancetype)initWithProtocol:(Protocol*)protocol;

- (void)addListenerObject:(id)object;
- (void)removeListenerObject:(id)object;

@end
