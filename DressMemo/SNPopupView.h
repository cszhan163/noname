/*
 * PopupView
 * SNPopupView.h
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/07.
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

typedef enum {
	SNPopupViewUp		= 1,
	SNPopupViewDown		= 2,
	SNPopupViewRight	= 1 << 8,
	SNPopupViewLeft		= 2 << 8,
}SNPopupViewDirection;

@interface SNPopupView : UIView {
	CGGradientRef gradient;
	CGGradientRef gradient2;
	
	CGRect		contentRect;
	CGRect		contentBounds;
	
	CGRect		popupRect;
	CGRect		popupBounds;
	
	CGRect		viewRect;
	CGRect		viewBounds;
	
	CGPoint		pointToBeShown;
	
	NSString	*title;
	UIImage		*image;
	
	float		horizontalOffset;
	SNPopupViewDirection	direction;
	id			target;
	SEL			action;
}
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *image;
- (id)initWithString:(NSString*)newValue;
- (id)initWithImage:(UIImage*)newImage;
- (void)showAtPoint:(CGPoint)p inView:(UIView*)inView;
- (void)dismiss;
- (void)addTarget:(id)target action:(SEL)action;
@end
