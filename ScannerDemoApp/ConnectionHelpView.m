/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ConnectionHelpView.h
 *
 *  Notes: Generic UIView used to display instructions containing resizable images
 *
 ******************************************************************************/


#import "ConnectionHelpView.h"
#import "UIColor+DarkModeExtension.h"

@implementation zt_ConnectionHelpView
{
    CGFloat lastScale;
}


- (IBAction) twoFingerPinch : (UIPinchGestureRecognizer *) recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        lastScale = [recognizer scale];
    }
    else if ([recognizer state] == UIGestureRecognizerStateBegan ||
             [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGFloat currentScale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // adjust max/min values of zoom
        const CGFloat kMaxScale = 1.0;
        const CGFloat kMinScale = 0.70;
        
        CGFloat newScale = 1 - (lastScale - [recognizer scale]);
        
        newScale = MIN (newScale, kMaxScale/currentScale);
        newScale = MAX (newScale, kMinScale/currentScale);
        
        CGAffineTransform transform = CGAffineTransformScale([[recognizer view] transform], newScale, newScale);
        
        [recognizer view].transform = transform;
        
        lastScale = [recognizer scale];
    }
}



@end
