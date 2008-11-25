/*
 *  GomokuModel.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/23/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import "GomokuObservable.h"
/*
 * [2008-10-23] Wrap TrumCaro.c into an Objective-C class.
 * [2008-10-27] Implement Observable.
 * [2008-10-28] Remove setBoardValue method.
 */

/* 
 * Convention: 0: O, 1: X. This header file's define macro is for GomokuModel only.
 */

#import "Constant.h"

//#define MAN 0
//#define COM 1

// define the first player with index 0 so that history management is consistent.
#define MAN 1
#define COM 0

#define EMPTY 2
#define EDGE 3 // chuoi' wa' di :-w

@interface GomokuModel : NSObject <GomokuObservable>
{	
	int* history; // save the moves of two players. The first player decides how the history array is interpreted.
	// history index indicates the n-th move. The parity of the history index (even, odd) shows which player is moving.
	// history value indicates the position of the piece.
	// history array is used as a duplicate of the board array for rendering consistency. It is also be used to implement the undo/redo feature and show a list of history moves.
	int numMoves; // the number of moves in the history array.
	
	int boardSize;
	int humanPiece;
	int computerPiece;
	int side;			// current turn
	int searchDepth;
	bool isComputerThinking;
	bool computerMoveFirst;
	
	// a set of observers
	NSMutableSet* observers;
}

// =========================== GomokuModel methods ================================ //
@property (assign) int boardSize;
@property (assign) int humanPiece;
@property (assign) int computerPiece;
@property (readonly) int side;
@property (assign) int searchDepth;
@property (readonly) bool isComputerThinking;
@property (assign) bool computerMoveFirst;

- (GomokuModel*)init; // constructor
- (void)restart;
- (int)getBoardValue:(int)row column:(int)col; // row: y, col: x
//- (void)setBoardValue:(int)value row:(int)r column:(int)c; // obsolete
- (int)indexOf:(int)row column:(int)col;
- (int)humanMove:(int)row column:(int)col;
- (int)computerMove;
- (int)isGameOver;

// observable
- (void)attachGomoku:(id<GomokuObserver>)observer;
- (void)notifyGomoku;

// history management
- (void)historyPush:(int)move; // push a move to the history "stack"
- (void)historyPop;
//- (void)historyVisit:(void (*)(int x, int y, int val))visitor;
- (void)historyVisit:(id)visitor withSelector:(SEL)sel;
@end

// =========================== TrumCaro.c functions =============================== //
void Restart(int InitDepth, int InitStop);
int MakeManMove(int Move);
int MakeComMove(int Move);
void RestoreMan(int Move);
void RestoreCom(int Move);
int Evaluate(int Side);
void Sort(int A[], int D[], int l, int r);
void GenManDangerMove(int Ply);
void GenComDangerMove(int Ply);
void GenMan4Move(int Ply);
void GenCom4Move(int Ply);
void GenMove(int Ply);

int GetStroke(int* _Move, int R);
void PrintChar(int Move, int Ch);
void Print();
int EndManSearch(int Ply, int Alpha, int Beta);
int QuiesComSearch(int Ply, int Alpha, int Beta);
int QuiesManSearch(int Ply, int Alpha, int Beta);
int ManSearch(int Ply, int Alpha, int Beta);

int ComSearch(int Ply, int Alpha, int Beta);
int ManSearch(int Ply, int Alpha, int Beta);
void PrintOpinion(int R, int* _Roi);
void PrintIdea(int Index);
