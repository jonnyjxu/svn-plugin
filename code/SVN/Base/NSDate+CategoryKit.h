//
//  NSDate+CategoryKit.h
//  CategoryKit
//
//  Created by xujun on 15/7/29.
//  Copyright (c) 2014 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


#define CK_MinDate(_date1_,_date2_) [NSDate minValidDate:_date1_ date2:_date2_]
#define CK_MaxDate(_date1_,_date2_) [NSDate maxValidDate:_date1_ date2:_date2_]

@interface NSDate (CategoryKit)

//手机  当前时区的时间
+ (instancetype)localeDate;


#pragma mark - Component Properties
///=============================================================================
/// @name Component Properties
///=============================================================================

@property (nonatomic, readonly) NSInteger year; ///< Year component
@property (nonatomic, readonly) NSInteger month; ///< Month component (1~12)
@property (nonatomic, readonly) NSInteger day; ///< Day component (1~31)
@property (nonatomic, readonly) NSInteger hour; ///< Hour component (0~23)
@property (nonatomic, readonly) NSInteger minute; ///< Minute component (0~59)
@property (nonatomic, readonly) NSInteger second; ///< Second component (0~59)
@property (nonatomic, readonly) NSInteger nanosecond; ///< Nanosecond component
@property (nonatomic, readonly) NSInteger weekday; ///< Weekday component (1~7, first day is based on user setting)
@property (nonatomic, readonly) NSInteger weekdayOrdinal; ///< WeekdayOrdinal component
@property (nonatomic, readonly) NSInteger weekOfMonth; ///< WeekOfMonth component (1~5)
@property (nonatomic, readonly) NSInteger weekOfYear; ///< WeekOfYear component (1~53)
@property (nonatomic, readonly) NSInteger yearForWeekOfYear; ///< YearForWeekOfYear component
@property (nonatomic, readonly) NSInteger quarter; ///< Quarter component
@property (nonatomic, readonly) BOOL isLeapMonth; ///< Weather the month is leap month
@property (nonatomic, readonly) BOOL isLeapYear; ///< Weather the year is leap year
@property (nonatomic, readonly) BOOL isToday; ///< Weather date is today (based on current locale)
@property (nonatomic, readonly) BOOL isTomorrow;
@property (nonatomic, readonly) BOOL isYesterday; ///< Weather date is yesterday (based on current locale)
///日
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
///月
- (BOOL)isThisMonth;
- (BOOL)isNextMonth;
- (BOOL)isLastMonth;
///年
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

///是否是过去的时间
- (BOOL)isInPastDate;
///是否是将来的时间
- (BOOL)isInFutureDate;

///日 一 二 三...
- (nonnull NSString *)weekDayString;
#pragma mark - Date modify
///=============================================================================
/// @name Date modify
///=============================================================================

/**
 Returns a date representing the receiver date shifted later by the provided number of years.
 
 @param years  Number of years to add.
 @return Date modified by the number of desired years.
 */
- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

/**
 Returns a date representing the receiver date shifted later by the provided number of months.
 
 @param months  Number of months to add.
 @return Date modified by the number of desired months.
 */
- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

/**
 Returns a date representing the receiver date shifted later by the provided number of weeks.
 
 @param weeks  Number of weeks to add.
 @return Date modified by the number of desired weeks.
 */
- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

/**
 Returns a date representing the receiver date shifted later by the provided number of days.
 
 @param days  Number of days to add.
 @return Date modified by the number of desired days.
 */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

/**
 Returns a date representing the receiver date shifted later by the provided number of hours.
 
 @param hours  Number of hours to add.
 @return Date modified by the number of desired hours.
 */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

/**
 Returns a date representing the receiver date shifted later by the provided number of minutes.
 
 @param minutes  Number of minutes to add.
 @return Date modified by the number of desired minutes.
 */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

/**
 Returns a date representing the receiver date shifted later by the provided number of seconds.
 
 @param seconds  Number of seconds to add.
 @return Date modified by the number of desired seconds.
 */
- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;


#pragma mark - Date Format
///=============================================================================
/// @name Date Format
///=============================================================================

/**
 Returns a formatted string representing this date.
 see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 for format description.
 
 @param format   String representing the desired date format.
 e.g. @"yyyy-MM-dd HH:mm:ss"
 
 @return NSString representing the formatted date string.
 */
- (nullable NSString *)stringWithFormat:(NSString *)format;

/**
 Returns a formatted string representing this date.
 see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 for format description.
 
 @param format    String representing the desired date format.
 e.g. @"yyyy-MM-dd HH:mm:ss"
 
 @param timeZone  Desired time zone.
 
 @param locale    Desired locale.
 
 @return NSString representing the formatted date string.
 */
- (nullable NSString *)stringWithFormat:(NSString *)format
                               timeZone:(nullable NSTimeZone *)timeZone
                                 locale:(nullable NSLocale *)locale;

/**
 Returns a string representing this date in ISO8601 format.
 e.g. "2010-07-09T16:13:30+12:00"
 
 @return NSString representing the formatted date string in ISO8601.
 */
- (nullable NSString *)stringWithISOFormat;

/**
 Returns a date parsed from given string interpreted using the format.
 
 @param dateString The string to parse.
 @param format     The string's date format.
 
 @return A date representation of string interpreted using the format.
 If can not parse the string, returns nil.
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

/**
 Returns a date parsed from given string interpreted using the format.
 
 @param dateString The string to parse.
 @param format     The string's date format.
 @param timeZone   The time zone, can be nil.
 @param locale     The locale, can be nil.
 
 @return A date representation of string interpreted using the format.
 If can not parse the string, returns nil.
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(nullable NSTimeZone *)timeZone
                             locale:(nullable NSLocale *)locale;

/**
 Returns a date parsed from given string interpreted using the ISO8601 format.
 
 @param dateString The date string in ISO8601 format. e.g. "2010-07-09T16:13:30+12:00"
 
 @return A date representation of string interpreted using the format.
 If can not parse the string, returns nil.
 */
+ (nullable NSDate *)dateWithISOFormatString:(NSString *)dateString;

///从日期date开始计算  多少年
- (NSInteger)yearsSinceDate:(nonnull NSDate *)date;
///从日期date开始计算  多少月
- (NSInteger)monthsSinceDate:(nonnull NSDate *)date;
///从日期date开始计算  多少日
- (NSInteger)daysSinceDate:(nonnull NSDate *)date;
///从日期date开始计算  多少小时
- (NSInteger)hoursSinceDate:(nonnull NSDate *)date;
///从日期date开始计算  多少分钟
- (NSInteger)minutesSinceDate:(nonnull NSDate *)date;
///从日期date开始计算  多少秒
- (NSInteger)secondsSinceDate:(nonnull NSDate *)date;

///remove: year month day
- (nonnull NSDate *)dateByRemoveDate;
///remove : hour minute second
- (nonnull NSDate *)dateByRemoveTime;

///DateComponents年月日/周
- (nonnull NSDateComponents *)yearMonthDayComponents;
///DateComponents时分秒
- (NSDateComponents *)hourMinuteSecondComponents;

///这个月第一天
- (nonnull NSDate *)firstDayDateOfThisMonth;
///这个月最后一天
- (nonnull NSDate *)lastDayDateOfThisMonth;
///本月 所在日期这周 有几天 (0-7)
- (NSUInteger)daysContainsInThisMonthAndWeek;
/// 获取当月的天数(0-31)
- (NSUInteger)daysOfThisMonth;

///转为日期2017-07-07
- (NSString *)dateString_yyyyMMdd;
///转为日期2017-07-07 12:12
- (NSString *)dateString_yyyyMMdd_HHmm;
///转为日期2017-07-07 12:12:12
- (NSString *)dateString_yyyyMMdd_HHmmss;
//转为日期2017-07-07 00:00:00
- (NSString *)dateString_yyyyMMdd_HHmmss_begin;
///转为日期2017-07-07 23:59:59
- (NSString *)dateString_yyyyMMdd_HHmmss_end;
///转为时间11:22
- (NSString *)timeString_HHmm;


///最小的时间 合法的时间(如果有一个为nil 返回非nil)
+ (NSDate *)minValidDate:(NSDate *)date1 date2:(NSDate *)date2;
///最大的时间 合法的时间(如果有一个为nil 返回非nil)
+ (NSDate *)maxValidDate:(NSDate *)date1 date2:(NSDate *)date2;


///英富莱定义的时间格式(当天:16:00/ 同一年:04-11/不同年:2018-04-11)
- (NSString *)enfryDateString_short;
///英富莱定义的时间格式(当天:16:00/ 同一年:04-11 16:00/不同年:2018-04-11 16:00)
- (NSString *)enfryDateString_full;

@end


@interface NSString (DateCategoryKit)

///日期格式转换
- (nullable NSDate *)toDate;
- (nullable NSDate *)toEnfryDate;//英富莱专用格式 yyyy-MM-dd HH:mm:ss
///日期格式转换
- (nullable NSDate *)toDateWithFormat:(NSString *)dateFormat;
///JAVA时间戳转换
- (nonnull NSDate *)toDateByJavaTimeStamp;


@end

NS_ASSUME_NONNULL_END
