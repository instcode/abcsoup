/*
 *  Geometry.c
 *  Jigsaw
 *
 *  Created by Son Hua on 5/1/09.
 *  Copyright 2009 AptusVentures. All rights reserved.
 *
 */

#include "Geometry.h"

int testHitTriangle(struct JTriangle t, struct JPoint p) {
	float det		= (t.a.x - t.c.x) * (t.b.y - t.c.y) - (t.b.x - t.c.x) * (t.a.y - t.c.y);
	float detAlpha	= (p.x - t.c.x) * (t.b.y - t.c.y) - (t.b.x - t.c.x) * (p.y - t.c.y);
	float detBeta	= (t.a.x - t.c.x) * (p.y - t.c.y) - (p.x - t.c.x) * (t.a.y - t.c.y);
	if (det != 0) {
		float detReciprocal = 1.0 / det;
		float alpha = detAlpha * detReciprocal;
		float beta	= detBeta  * detReciprocal;
		if (alpha >= 0 && alpha <= 1.0 && beta >= 0 && beta <= 1.0) {
			return 1;
		}
	}
	return 0;
}
