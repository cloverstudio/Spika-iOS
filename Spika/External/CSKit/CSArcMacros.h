//
//  CSArcMacros.h
//  CSUtils
//
//  Created by Josip Bernat on 5/9/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#ifndef CSUtils_CSArcMacros_h
#define CSUtils_CSArcMacros_h

#pragma mark - ARC macros

#if !__has_feature(objc_arc)
#define CS_AUTORELEASE(__OBJECT__) [__OBJECT__ autorelease]
#define CS_RELEASE(__OBJECT__) [__OBJECT__ release]
#define CS_RETAIN(__OBJECT__) [__OBJECT__ retain]
#define CS_QUEUE_RETAIN(__OBJECT__) dispatch_retain(__OBJECT__)
#define CS_QUEUE_RELEASE(__OBJECT__) dispatch_release(__OBJECT__)
#define CS_DEALLOC(__OBJECT__) [__OBJECT__ dealloc]
#define CS_SUPER_DEALLOC [super dealloc]
#else
#define CS_AUTORELEASE(__OBJECT__) [__OBJECT__ self]
#define CS_RELEASE(__OBJECT__) [__OBJECT__ self]
#define CS_RETAIN(__OBJECT__) [__OBJECT__ self]
#define CS_QUEUE_RETAIN(__OBJECT__) nil
#define CS_QUEUE_RELEASE(__OBJECT__) nil
#define CS_DEALLOC(__OBJECT__) nil
#define CS_SUPER_DEALLOC nil
#endif

#endif
