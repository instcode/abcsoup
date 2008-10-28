/*
 *  GomokuObserver.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
@protocol GomokuObservable;

@protocol GomokuObserver

- (void)onGomokuNotify:(id<GomokuObservable>)observable;

@end
