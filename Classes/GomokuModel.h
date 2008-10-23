/*
 *  GomokuModel.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/23/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

/*
 * [2008-10-23] Wrap TrumCaro.c into an Objective-C class.
 */

/* 
 * Convention: 0: O, 1: X. This header file's define macro is for GomokuModel only.
 */

#define DEFAULT_BOARD_SIZE 10
#define DEFAULT_SEARCH_DEPTH 6

@interface GomokuModel : NSObject
{	
	int boardSize;
	int humanPiece;
	int computerPiece;
	int side;			// current turn
	int searchDepth;
}

// =========================== GomokuModel methods ================================ //
@property (assign) int boardSize;
@property (assign) int humanPiece;
@property (assign) int computerPiece;
@property (readonly) int side;
@property (assign) int searchDepth;

- (GomokuModel*)init; // constructor
- (int)getBoardValue:(int)row: column:(int)col; // row: y, col: x
- (void)setBoardValue:(int)value: atrow:(int)row: atcolumn:(int)col;
- (int)indexOf:(int)row: column:(int)col;
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
