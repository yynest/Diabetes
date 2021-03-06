//
//  RegexVerifyTool.m
//  QianShanJY
//
//  Created by iosdev on 16/4/13.
//  Copyright © 2016年 chinasun. All rights reserved.
//

#import "RegexVerifyTool.h"

@implementation RegexVerifyTool

//删除特殊的字符：空格等
//    1、使用NSString中的stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]方法只是去掉左右两边的空格；
//    2、使用NSString *strUrl = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];可以去掉空格，注意此时生成的strUrl是autorelease属性的，不要妄想对strUrl进行release操作。
+ (NSString *)deleteSomeCharacterWith:(NSString *)string; {
    NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return temp;
}

/*
//验证身份证,必须满足以下规则
1. 长度必须是18位，前17位必须是数字，第十八位可以是数字或X
2. 前两位必须是以下情形中的一种：11,12,13,14,15,21,22,23,31,32,33,34,35,36,37,41,42,43,44,45,46,50,51,52,53,54,61,62,63,64,65,71,81,82,91
3. 第7到第14位出生年月日。第7到第10位为出生年份；11到12位表示月份，范围为01-12；13到14位为合法的日期
4. 第17位表示性别，双数表示女，单数表示男
5. 第18位为前17位的校验位
//算法如下：
（1）校验和 = (n1 + n11) * 7 + (n2 + n12) * 9 + (n3 + n13) * 10 + (n4 + n14) * 5 + (n5 + n15) * 8 + (n6 + n16) * 4 + (n7 + n17) * 2 + n8 + n9 * 6 + n10 * 3，其中n数值，表示第几位的数字
（2）余数 ＝ 校验和 % 11
（3）如果余数为0，校验位应为1，余数为1到10校验位应为字符串“0X98765432”(不包括分号)的第余数位的值（比如余数等于3，校验位应为9）
6. 出生年份的前两位必须是19或20
*/
+ (BOOL)regexVerifyWithIDCard:(NSString *)value
{
    value = [self deleteSomeCharacterWith:value];
    if ([value length] != 18) {
        return NO;
    }
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![regexTest evaluateWithObject:value]) {
        return NO;
    }
    int summary = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7+ ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4+ ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2.+ [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
    NSInteger remainder = summary % 11;
    NSString *checkString = @"10X98765432";
    NSString *checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
    return [checkBit isEqualToString:[[value substringWithRange:NSMakeRange(17,1)] uppercaseString]];
}

//验证真实姓名:汉字(2-16)，字母(2-32)正则表达式
+ (BOOL)regexVerifyWithRealName:(NSString *)value {
    value = [self deleteSomeCharacterWith:value];
    NSString *regex = @"^[\u4e00-\u9fa5]{2,16}$|^[A-Za-z]{2,32}$";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isRight = [predicate evaluateWithObject:value];
    return isRight;
}

//验证手机号码
+ (BOOL)regexVerifyWithMobilePhone:(NSString *)value {
    value = [self deleteSomeCharacterWith:value];
    NSString * MOBILE = @"^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    return  [regextestmobile evaluateWithObject:value]   ||
    [regextestphs evaluateWithObject:value]      ||
    [regextestct evaluateWithObject:value]       ||
    [regextestcu evaluateWithObject:value]       ||
    [regextestcm evaluateWithObject:value];
}

// 采用正则表达式验证手机号是否正确. 规则：以1开头的11位数字
+ (BOOL)validatePhoneNumber:(NSString *)phone
{
    NSString *phoneRegex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [predicate evaluateWithObject:phone];
}

// 采用正则表达式验证短信验证码是否输入正确. 规则：4位数字
+ (BOOL)regexVerifySMSVerifyCode:(NSString *)smsCode
{
    smsCode = [self deleteSomeCharacterWith:smsCode];
    NSString *smsRegex = @"^\\d{4}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", smsRegex];
    return [predicate evaluateWithObject:smsCode];
}

//判断字符串是否为空
+ (BOOL)checkEmptyString:(NSString *)string {
    string = [self deleteSomeCharacterWith:string];
    BOOL isEmpty = NO;
    if (string == nil) {
        isEmpty = YES;
    }
    else if(string.length == 0) {
        isEmpty = YES;
    }
    else if([string isEqual:NSNull.null]) {
        isEmpty = YES;
    }
    else if ([string isEqualToString:@"未填写"]){
        isEmpty = YES;
    }
    return isEmpty;
}


@end
