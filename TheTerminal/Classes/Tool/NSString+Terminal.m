//
//  NSString+Terminal.m
//  TerminalDemo
//
//  Created by TheMe on 2019/1/14.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "NSString+Terminal.h"

@implementation NSString (Terminal)

- (BOOL)hasContainString:(NSString *)string
{
    if([self rangeOfString:string].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isAppUrl
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(isTheRouteUrl)]) {
        return [self performSelector:@selector(isTheRouteUrl)];
    }
#pragma clang diagnostic pop
    return NO;
}

- (BOOL)supportScheme:(NSString *)scheme
{
    if ([NSString isEmptyOrNull:self]) {
        return NO;
    }
    NSString *schemePrefix = [NSString stringWithFormat:@"%@://",scheme];
    if ([[self lowercaseString] hasPrefix:schemePrefix]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyOrNull: (NSString *)string
{
    if ([string isKindOfClass:[NSNull class]] || string == nil || [string isEqualToString:@""] || [string isEqualToString:@"undefined"] || [string isEqualToString:@"null"])
        return true;
    return false;
}

+ (BOOL)isNotEmptyAndNull: (NSString *)string
{
    if (![string isKindOfClass:[NSNull class]] && string != nil && ![string isEqualToString:@""] && ![string isEqualToString:@"undefined"] && ![string isEqualToString:@"null"])
        return  true;
    return false;
}

- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)URLEncodedString
{
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)unencodedString,(CFStringRef)@"!*'();:@&=+$,/?%#[]",NULL,kCFStringEncodingUTF8));
    
    return encodedString;
}

- (NSString *)paramUrlEncoded
{
    NSString *url = [self copy];
    NSString *resultUrl = url;
    
    // @\\[[\\s\\S].*?\\] 懒惰模式   |    贪婪模式  @\\[[\\s\\S].*?\\]
    NSString *pattern = [NSString stringWithFormat:@"@\\[[\\s\\S].*?\\]"]; // /?[(%@)/|(%@)$]
    
    
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive  error:nil];
    if (regular != nil) {
        NSArray *matchs = [regular matchesInString:url options:0 range:NSMakeRange(0, [url length])];
        NSEnumerator *enume = [matchs reverseObjectEnumerator];
        
        NSTextCheckingResult *match;
        while (match = [enume nextObject]) {
            NSRange resultRange = [match rangeAtIndex:0];
            if (resultRange.location != NSNotFound) {
                
                NSRange contentRange = resultRange;
                contentRange.location += 2;
                contentRange.length -= 3;
                NSString *content = [url substringWithRange:contentRange];
                
                NSString *encodeContent = [content URLEncodedString];
                
                resultUrl = [resultUrl stringByReplacingCharactersInRange:resultRange withString:encodeContent];
            }
        }
    }
    return resultUrl;
}

- (NSArray<NSString *> *)getAllParameter
{
    NSString *url = [self copy];
    url = [url removeUrlArg];
    if ([url containsString:@"?"]) {
        url = [[url componentsSeparatedByString:@"?"] lastObject];
        NSArray *paramStrs = [url componentsSeparatedByString:@"&"];
        return paramStrs;
    }
    return @[];
}

- (NSDictionary *)getAllParameterDict
{
    NSString *url = [self copy];
    NSArray *paramStrs = [url getAllParameter];
    
    NSMutableDictionary *paramDict = [@{} mutableCopy];
    for (NSString *paramStr in paramStrs) {
        NSArray *paramKV = [paramStr componentsSeparatedByString:@"="];
        if (paramKV.count == 2) {
            NSString *key = [paramKV firstObject];
            NSString *value = [[paramKV lastObject] stringByDecodingURLFormat];
            if ([NSString isNotEmptyAndNull:key] && [NSString isNotEmptyAndNull:value]) {
                id dictValue = paramDict[key];
                if ([dictValue isKindOfClass:[NSString class]]) {
                    NSMutableArray *list = [@[] mutableCopy];
                    [list addObject:dictValue];
                    [list addObject:value];
                    paramDict[key] = list;
                }else if ([dictValue isKindOfClass:[NSMutableArray class]]) {
                    NSMutableArray *list = (NSMutableArray *)dictValue;
                    [list addObject:value];
                    paramDict[key] = list;
                }else{
                    paramDict[key] = value;
                }
            }
        }
    }
    
    return paramDict;
}

- (NSString *)deleteAllParameter
{
    NSString *result = self;
    
    NSRange range = [result rangeOfString:@"\\?[a-zA-Z=_&0-9:/%\\-.\u4e00-\u9fa5]+#?" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSString *subStr = [result substringWithRange:range];
        if ([subStr hasSuffix:@"#"]) {
            range.length--;
        }
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    }
    return result;
}

- (NSString *)getUrlArg
{
    NSString *url = [self copy];
    NSRange range = [url rangeOfString:@"#[a-zA-Z,:0-9]+\\/?" options:NSRegularExpressionSearch];
    
    NSString *result = nil;
    if (range.location != NSNotFound) {
        result = [url substringWithRange:range];
    }
    
    return result;
}

- (NSString *)removeUrlArg
{
    NSString *result = self;
    
    NSRange range = [result rangeOfString:@"#[a-zA-Z,:0-9]+\\/?" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSString *subStr = [result substringWithRange:range];
        if ([subStr hasSuffix:@"/"]) {
            range.length--;
        }
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    }
    
    return result;
}

- (NSString *)getUrlBody
{
    NSString *url = [self copy];
    url = [url removeUrlArg];
    url = [url deleteAllParameter];
    return url;
}

#pragma mark - json
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - path
#define kTheTerminalName @"TheTerminal.bundle"
+ (NSString *)imagePath:(NSString *)name
{
    NSString *bundleName = kTheTerminalName;
    
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    
    NSString *resourcePath = [[NSBundle bundleForClass:NSClassFromString(@"TheTerminal")] resourcePath];
    
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    
    NSString *imagepath = [bundlePath stringByAppendingPathComponent:image_name];;
    
    return imagepath;
}

#define kTheMeName @"theme.bundle"
+ (id)jsonWithAppFileName:(NSString *)filename andThemeName:(NSString *)themeName
{
    NSString *jsonstr = [self jsonStringWithFileName:filename andThemeName:themeName];
    return [self json2Object:jsonstr];
}

+ (NSString *)jsonStringWithFileName:(NSString *)filename andThemeName:(NSString *)themeName
{
    if ([NSString isEmptyOrNull:themeName]) {
        themeName = kTheMeName;
    }
    NSString *directory = [NSString stringWithFormat:@"%@/json", kTheMeName];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:filename ofType:@".json" inDirectory:directory];
    NSString *jsonstr = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    
    return jsonstr;
}

+ (id)json2Object:(NSString *)jsonstr
{
    id json;
    NSData *jsonData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return json;
}

@end

id themeTerminalJson(NSString *fileName)
{
    return [NSString jsonWithAppFileName:fileName andThemeName:@"theme"];
}
