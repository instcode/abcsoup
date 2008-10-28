/*
 *  GomokuObservable.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

@protocol GomokuObserver;

@protocol GomokuObservable

- (void)attachGomoku:(id<GomokuObserver>)observer;
- (void)notifyGomoku;

@end
