//
//  NSDate+CategoryKit.m
//  CategoryKit
//
//  Created by xujun on 15/7/29.
//  Copyright (c) 2014 xujun. All rights reserved.
//

#import "NSDate+CategoryKit.h"
#import <time.h>

@implementation NSDate (CategoryKit)

+ (instancetype)localeDate
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return localeDate;
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)nanosecond {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] nanosecond];
}

- (NSInteger)weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)weekdayOrdinal {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekdayOrdinal fromDate:self] weekdayOrdinal];
}

- (NSInteger)weekOfMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:self] weekOfMonth];
}

- (NSInteger)weekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:self] weekOfYear];
}

- (NSInteger)yearForWeekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYearForWeekOfYear fromDate:self] yearForWeekOfYear];
}

- (NSInteger)quarter {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] quarter];
}

- (BOOL)isLeapMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] isLeapMonth];
}

- (BOOL)isLeapYear {
    NSUInteger year = self.year;
    return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)));
}

#pragma mark  日
- (BOOL)isToday {
    if (fabs(self.timeIntervalSinceNow) >= 60 * 60 * 24) return NO;
    return [NSDate date].day == self.day;
}

- (BOOL)isTomorrow {
    NSDate *added = [self dateByAddingDays:-1];
    return [added isToday];
}

- (BOOL)isYesterday {
    NSDate *added = [self dateByAddingDays:1];
    return [added isToday];
}

#pragma mark  周
- (BOOL)isThisWeek {
    NSDate *date = [NSDate date];
    return (date.year == self.year && date.weekOfYear == self.weekOfYear);
}

- (BOOL)isNextWeek {
    NSDate *added = [self dateByAddingWeeks:-1];
    return [added isThisWeek];
}

- (BOOL)isLastWeek {
    NSDate *added = [self dateByAddingWeeks:1];
    return [added isThisWeek];
}

#pragma mark  月
- (BOOL)isThisMonth {
    NSDate *date = [NSDate date];
    return (date.year == self.year && date.month == self.month);
}

- (BOOL)isNextMonth {
    NSDate *added = [self dateByAddingMonths:-1];
    return [added isThisMonth];
}

- (BOOL)isLastMonth {
    NSDate *added = [self dateByAddingMonths:1];
    return [added isThisMonth];
}


#pragma mark  年
- (BOOL)isThisYear {
    NSDate *date = [NSDate date];
    return (date.year == self.year);
}

- (BOOL)isNextYear {
    NSDate *added = [self dateByAddingYears:-1];
    return [added isThisYear];
}

- (BOOL)isLastYear {
    NSDate *added = [self dateByAddingYears:1];
    return [added isThisYear];
}

///是否是过去的时间
- (BOOL)isInPastDate {
    return self.timeIntervalSinceNow < 0;
}
///是否是将来的时间
- (BOOL)isInFutureDate {
    return self.timeIntervalSinceNow > 0;
}




- (nonnull NSString *)weekDayString
{
    NSString *weekstr = nil;
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    switch ([componets weekday]) {
        case 1:
            weekstr = @"日";
            break;
        case 2:
            weekstr = @"一";
            break;
        case 3:
            weekstr = @"二";
            break;
        case 4:
            weekstr = @"三";
            break;
        case 5:
            weekstr = @"四";
            break;
        case 6:
            weekstr = @"五";
            break;
        case 7:
            weekstr = @"六";
            break;
        default:
            break;
    }
    
    return weekstr?:@"";
}


- (NSDate *)dateByAddingYears:(NSInteger)years {
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:weeks];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateByAddingHours:(NSInteger)hours {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 3600 * hours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 60 * minutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateByAddingSeconds:(NSInteger)seconds {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + seconds;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

- (NSString *)stringWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

- (NSString *)stringWithISOFormat {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)dateWithISOFormatString:(NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter dateFromString:dateString];
}

///从日期date开始计算  多少年
- (NSInteger)yearsSinceDate:(nonnull NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:date toDate:self options:0];
    return [components year];
}
///从日期date开始计算  多少月
- (NSInteger)monthsSinceDate:(nonnull NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:date toDate:self options:0];
    return [components month];
}
///从日期date开始计算  多少日
- (NSInteger)daysSinceDate:(nonnull NSDate *)date
{
    ///是不是不够一天  返回0 忘记了
    NSDate *beginDate = [date dateByRemoveTime];
    NSDate *endDate = [self dateByRemoveTime];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:beginDate toDate:endDate options:0];
    return [components day];
}

///从日期date开始计算  多少小时
- (NSInteger)hoursSinceDate:(nonnull NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:date toDate:self options:0];
    return [components hour];
}

///从日期date开始计算  多少分钟
- (NSInteger)minutesSinceDate:(nonnull NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:date toDate:self options:0];
    return [components minute];
}

///从日期date开始计算  多少秒
- (NSInteger)secondsSinceDate:(nonnull NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:date toDate:self options:0];
    return [components second];
}


///remove: year month day
- (NSDate *)dateByRemoveDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    NSString *myDateStr = [dateFormatter stringFromDate:self];
    NSDate *newDate = [dateFormatter dateFromString:myDateStr];
    return newDate;
}

///remove : hour minute second
- (NSDate *)dateByRemoveTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *myDateStr = [dateFormatter stringFromDate:self];
    NSDate *newDate = [dateFormatter dateFromString:myDateStr];
    
    return newDate;
}

///DateComponents年月日
- (NSDateComponents *)yearMonthDayComponents
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:self];
}

- (NSDateComponents *)hourMinuteSecondComponents
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
}

///第一天
- (NSDate *)firstDayDateOfThisMonth
{
    NSDate *startDate = nil;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:self];
    return startDate;
}

///这个月最后一天
- (NSDate *)lastDayDateOfThisMonth
{
    NSDate *firstDay = [self firstDayDateOfThisMonth];
    return [firstDay dateByAddingDays:self.daysOfThisMonth-1];
}

///本月 所在日期这周 有几天
- (NSUInteger)daysContainsInThisMonthAndWeek
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:self];
}

// 获取当月的天数
- (NSUInteger)daysOfThisMonth
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法 NSGregorianCalendar - ios 8
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay  //NSDayCalendarUnit - ios 8
                                   inUnit:NSCalendarUnitMonth //NSMonthCalendarUnit - ios 8
                                  forDate:self];
    return range.length;
}


///转为日期2017-07-07
- (NSString *)dateString_yyyyMMdd
{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}
//转为日期2017-07-07 12:12
- (NSString *)dateString_yyyyMMdd_HHmm
{
    return [self stringWithFormat:@"yyyy-MM-dd HH:mm"];
}
//转为日期2017-07-07 12:12:12
- (NSString *)dateString_yyyyMMdd_HHmmss
{
    return [self stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

//转为日期2017-07-07 00:00:00
- (NSString *)dateString_yyyyMMdd_HHmmss_begin
{
    return [self stringWithFormat:@"yyyy-MM-dd 00:00:00"];
}
///转为日期2017-07-07 23:59:59
- (NSString *)dateString_yyyyMMdd_HHmmss_end
{
    return [self stringWithFormat:@"yyyy-MM-dd 23:59:59"];
}
//转为时间11:22
- (NSString *)timeString_HHmm
{
    return [self stringWithFormat:@"HH:mm"];
}

#define CK_Return_IfInvalidDate(date1,date2)\
if (!date1 && !date2) return nil;\
if (date1 && !date2) return date1;\
if (!date1 && date2) return date2;

///最小的时间 合法的时间(如果有一个为nil 返回非nil)
+ (NSDate *)minValidDate:(NSDate *)date1 date2:(NSDate *)date2
{
    CK_Return_IfInvalidDate(date1,date2);
    return date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? date1 : date2;
}
///最大的时间 合法的时间(如果有一个为nil 返回非nil)
+ (NSDate *)maxValidDate:(NSDate *)date1 date2:(NSDate *)date2
{
    CK_Return_IfInvalidDate(date1,date2);
    return date1.timeIntervalSince1970 > date2.timeIntervalSince1970 ? date1 : date2;
}


///英富莱定义的时间格式(当天:16:00/ 同一年:04-11/不同年:2018-04-11)
- (NSString *)enfryDateString_short
{
    return [self enfryDateString:YES];
}

///英富莱定义的时间格式(当天:16:00/ 同一年:04-11 16:00/不同年:2018-04-11 16:00)
- (NSString *)enfryDateString_full
{
    return [self enfryDateString:NO];
}

- (NSString *)enfryDateString:(BOOL)isShort
{    
    if(self.isToday){
        //同一天  显示HH:mm
        return [self stringWithFormat:@"HH:mm"];
    }
    else if (self.isThisYear){
        ///同一年 显示MM-dd
        return [self stringWithFormat:isShort ? @"MM-dd" : @"MM-dd HH:mm"];
    }else{
        return [self stringWithFormat:isShort ? @"yyyy-MM-dd" : @"yyyy-MM-dd HH:mm"];
    }
}

@end


@implementation NSString (DateCategoryKit)

//+ (void)load
//{
//    NSDate *date=  [@"333315-02-28 11:11:22" toDate];
//    date = [date dateByAddingYears:10000];
//    NSLog(@"");
//}

- (NSDate *)toDate
{
    NSDate *retDate = nil;
    
    if (self.length == 0) {
        return retDate;
    }
    
    retDate = [self toDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];//enfry时间格式(下面为容错处理 和 天眼查时间戳处理)
    if (retDate) {
        return retDate;//有万年格式
    }
    
    NSArray *dateFormatArray = @[@"yyyyMMddHHmmss",@"yyyyMMdd",@"yyyyMMddHHmm",@"yyyyMM",@"yyyy"];//,@"yyyyMd" @"yyyyMMddHH"
    NSUInteger originLength = self.length;
    NSString *string = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"年" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"月" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"日" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    for (NSString *dateFormat in dateFormatArray) {
        
        if (string.length != dateFormat.length) {//格式不相等
            continue;
        }
        
        [dateFormatter setDateFormat:dateFormat];
        NSDate *date = [dateFormatter dateFromString:string];
        
        if (date) {
            
            if (originLength == string.length && date.year > 2999) {
                continue;///可能为时间戳 正好匹配为时间格式
            }
            retDate = date;
            break;
        }
    }
    
    return retDate;
}

- (nullable NSDate *)toEnfryDate;//英富莱专用格式 yyyy-MM-dd HH:mm:ss
{
    return [self toDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

///日期格式转换
- (nullable NSDate *)toDateWithFormat:(NSString *)dateFormat
{
    return [NSDate dateWithString:self format:dateFormat];
}

///时间戳转换
- (NSDate *)toDateByJavaTimeStamp
{
    NSTimeInterval timeInterval = self.doubleValue*1000;
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}



@end
