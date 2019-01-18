//
//  NSString+Terminal.h
//  TerminalDemo
//
//  Created by TheMe on 2019/1/14.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define nsstrcat(str1,str2) [str1 stringByAppendingString:str2]
#define nsstrformatcat(...) [NSString stringWithFormat:__VA_ARGS__]

id themeTerminalJson(NSString *fileName);

@interface NSString (Terminal)

- (BOOL)hasContainString:(NSString *)string;

- (BOOL)isAppUrl;
- (BOOL)supportScheme:(NSString *)scheme;

/*
  对url中@[xxx]内xxx给予编码
 */
- (NSString *)paramUrlEncoded;

+ (BOOL)isEmptyOrNull: (NSString *)string;
+ (BOOL)isNotEmptyAndNull: (NSString *)string;

- (NSString *)stringByDecodingURLFormat;
- (NSString *)URLEncodedString;

- (NSArray<NSString *> *)getAllParameter;
- (NSDictionary *)getAllParameterDict;
- (NSString *)deleteAllParameter;

- (NSString *)getUrlArg;
- (NSString *)removeUrlArg;

- (NSString *)getUrlBody;

#pragma mark - json
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

#pragma mark - path;
+ (NSString *)imagePath:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
