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
 *  Description:  barcode128.h
 *
 *  Notes:
 *
 ******************************************************************************/

#pragma once
#ifndef BARCODE128_H
#define BARCODE128_H

// Input - NULL terminated
//  ASCII symbol from 0x20 (space) to 0x127 (DEL)
//  FNC1 - 0x01, FNC2 - 0x02, FNC3 - 0x03, FNC4 - 0x04
// Output - shall be length of input + 3 (Start, Control, Stop)
// Output unit format - LSB X1X1X2X2X3X3X4X4X5X5X6X60000 MSB
//                           ^   ^   ^   ^   ^   ^
//                          bar  |  bar  |  bar  |
//                             space   space   space
// XnXn -
//      00 - 1
//      01 - 2
//      10 - 3
//      11 - 4
// The stop symbol is always 2331112 - 0110100000000100
unsigned generateBarcode128B(const char *input, unsigned short *output, unsigned *width);

#endif  // #ifndef BARCODE128_H
