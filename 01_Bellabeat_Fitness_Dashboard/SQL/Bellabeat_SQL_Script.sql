/*======================================================================
                         BELLABEAT CASE STUDY
======================================================================

Project Name : Bellabeat Smart Device Usage Analysis
Author       : Temitayo Medubi
Role         : Junior Data Analyst
Tool         : Microsoft SQL Server Management Studio 2025
Database     : BellabeatDB
Dataset      : Fitbit Fitness Tracker Data
               Fitabase Data 4.12.16 - 5.12.16

Project Goal:
Analyze Fitbit smart-device usage data to identify patterns
in users' activity habits and provide marketing recommendations
for Bellabeat.

Business Questions:
1. What trends exist in smart-device usage?
2. How could these trends apply to Bellabeat customers?
3. How could these trends influence Bellabeat's marketing strategy?

======================================================================*/

USE BellabeatDB;
GO


/*======================================================================
                         STEP 1: DATA VALIDATION
======================================================================

Objective:
Verify that the daily activity dataset was imported correctly
and assess whether it is suitable for analysis.

Validation checks:
1. Total number of records
2. Number of unique users
3. Duplicate records
4. Missing values

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: TOTAL NUMBER OF RECORDS

Question:
How many daily activity records are in the table?

Reason:
This confirms the number of rows imported into SQL Server.
----------------------------------------------------------------------*/

SELECT COUNT(*) AS TotalRows
FROM dbo.dailyActivity;
GO

/*
Result:
940 rows.

Interpretation:
The dailyActivity_merged table contains 940 daily activity
records. This confirms that the dataset was successfully imported.
*/


/*----------------------------------------------------------------------
CHECK 2: NUMBER OF UNIQUE USERS

Question:
How many different Fitbit users are represented in the table?

Reason:
This helps determine the size of the participant sample.
----------------------------------------------------------------------*/

SELECT COUNT(DISTINCT Id) AS TotalUsers
FROM dbo.dailyActivity;
GO

/*
Result:
33 unique users.

Interpretation:
The dataset contains daily activity records for 33 Fitbit users.
Each user contributed activity records for multiple days.
*/


/*----------------------------------------------------------------------
CHECK 3: DUPLICATE RECORDS

Question:
Does any user have more than one activity record for the same date?

Reason:
Duplicate daily records could inflate totals and distort averages.
A valid daily activity table should contain only one record per
user per day.
----------------------------------------------------------------------*/

SELECT
    Id,
    ActivityDate,
    COUNT(*) AS DuplicateCount
FROM dbo.dailyActivity
GROUP BY
    Id,
    ActivityDate
HAVING COUNT(*) > 1;
GO

/*
Result:
0 rows returned.

Interpretation:
No duplicate records were found using the combination of
Id and ActivityDate. No duplicate removal is required.
*/


/*----------------------------------------------------------------------
CHECK 4: MISSING VALUES

Question:
Do important columns contain NULL values?

Reason:
Missing values may affect calculations, comparisons, and
interpretation of the results.

Note:
COUNT(*) counts every row.
COUNT(column_name) counts only non-NULL values.
----------------------------------------------------------------------*/

SELECT
    COUNT(*) AS TotalRows,
    COUNT(Id) AS IdCount,
    COUNT(ActivityDate) AS DateCount,
    COUNT(TotalSteps) AS TotalStepsCount,
    COUNT(TotalDistance) AS TotalDistanceCount,
    COUNT(LoggedActivitiesDistance) AS LoggedActivitiesDistanceCount,
    COUNT(Calories) AS CaloriesCount
FROM dbo.dailyActivity;
GO

/*
Result:
TotalRows                       = 940
IdCount                         = 940
DateCount                       = 940
TotalStepsCount                 = 940
TotalDistanceCount              = 940
LoggedActivitiesDistanceCount   = 908
CaloriesCount                   = 940

Interpretation:
The main activity columns contain no NULL values.

LoggedActivitiesDistance contains 32 NULL values:

940 total rows - 908 non-NULL values = 32 NULL values.

These rows will not be deleted at this stage. The column records
manually logged activity distance, and missing values may indicate
that the user did not manually log an activity.
*/


/*======================================================================
                       DATA VALIDATION SUMMARY
======================================================================

Findings:
- The table contains 940 daily activity records.
- The table represents 33 unique Fitbit users.
- No duplicate daily records were found.
- The main analytical columns contain no NULL values.
- LoggedActivitiesDistance contains 32 NULL values.
- No rows were removed during validation.

Conclusion:
The dailyActivity_merged table is suitable for further assessment
and analysis.

======================================================================*/

/*======================================================================
                    STEP 2: TABLE STANDARDIZATION

Objective:
Rename imported tables using a consistent naming convention.

Reason:
The imported table names include the suffix "_merged", which
comes from the original CSV files. For readability and easier
query writing, we will rename the tables.

======================================================================*/
EXEC sp_rename
    'dbo.dailyActivity',
    'DailyActivity';
GO

/*-----------------------------------------------------------
Check all tables in the Bellabeat database.

Reason:
Before renaming a table, verify its current name.
-----------------------------------------------------------*/

USE BellabeatDB;
GO

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_NAME;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

/*======================================================================
                    STEP 3: UNDERSTANDING THE DATASET
======================================================================

Objective:
Determine the period covered by the DailyActivity dataset.

Reason:
Understanding the time span of the dataset provides context
for all subsequent analysis and ensures accurate interpretation
of trends.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: DATE RANGE

Question:
What is the earliest and latest activity date in the dataset?

Business Reason:
This establishes the analysis period for the Bellabeat case study.

----------------------------------------------------------------------*/

SELECT
    MIN(ActivityDate) AS StartDate,
    MAX(ActivityDate) AS EndDate
FROM dbo.DailyActivity;
GO

/*----------------------------------------------------------------------
CHECK 2: ANALYSIS PERIOD

Question:
How many days are covered by the dataset?

Business Reason:
Knowing the duration of the study helps us understand
the observation period and gives context to averages
and behavioural trends.

----------------------------------------------------------------------*/

SELECT
    DATEDIFF(DAY,
             MIN(ActivityDate),
             MAX(ActivityDate)) + 1 AS TotalDays
FROM dbo.DailyActivity;
GO

/*
Result:

Start Date : 2016-04-12

End Date   : 2016-05-12

Interpretation:

The DailyActivity dataset covers the period from
12 April 2016 to 12 May 2016.

This provides one month of Fitbit activity data
for analysis.
*/

/*
Result:

31 days.

Interpretation:

The DailyActivity dataset covers a continuous period of
31 days, from 12 April 2016 to 12 May 2016.

This provides one full month of user activity data,
which is sufficient for identifying behavioural trends,
activity patterns, and generating marketing insights.
*/

/*======================================================================
                    STEP 4: DAILY ACTIVITY SUMMARY
======================================================================

Objective:
Calculate the average daily activity metrics across all users.

Reason:
Understanding the average user's activity level provides
a baseline for identifying behaviour patterns and developing
marketing recommendations.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: AVERAGE DAILY ACTIVITY

Question:
What does an average day look like for a Fitbit user?

Business Reason:
This establishes a baseline for evaluating user engagement
and physical activity.

----------------------------------------------------------------------*/

SELECT
    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgDailySteps,
    ROUND(AVG(TotalDistance),2) AS AvgDistanceKm,
    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories,
    ROUND(AVG(CAST(VeryActiveMinutes AS FLOAT)),0) AS AvgVeryActiveMinutes,
    ROUND(AVG(CAST(FairlyActiveMinutes AS FLOAT)),0) AS AvgFairlyActiveMinutes,
    ROUND(AVG(CAST(LightlyActiveMinutes AS FLOAT)),0) AS AvgLightlyActiveMinutes,
    ROUND(AVG(CAST(SedentaryMinutes AS FLOAT)),0) AS AvgSedentaryMinutes
FROM dbo.DailyActivity;
GO

/*
Result:

Average Daily Steps          : 7,638

Average Distance             : 5.49 km

Average Calories Burned      : 2,304 kcal

Average Very Active Minutes  : 21 mins

Average Fairly Active Minutes: 14 mins

Average Lightly Active Minutes: 193 mins

Average Sedentary Minutes    : 991 mins

Interpretation:

Fitbit users demonstrate a moderate level of daily physical
activity, averaging 7,638 steps and 5.49 km per day.

Users spend approximately 35 minutes per day in moderate to
vigorous activity, while a large proportion of the day is
classified as sedentary.

Business Insight:

Bellabeat has an opportunity to encourage users to increase
their daily activity levels through personalized reminders,
goal tracking, wellness challenges, and motivational
notifications.
*/

/*======================================================================
                    STEP 5: ACTIVITY BY DAY OF THE WEEK
======================================================================

Objective:
Determine whether activity levels vary by day of the week.

Business Reason:
Understanding daily activity patterns can help Bellabeat
schedule notifications, wellness challenges, and promotional
campaigns on days when users are less active.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: AVERAGE DAILY STEPS BY DAY OF WEEK

Question:
On which day of the week do users walk the most steps?

Business Reason:
This insight helps Bellabeat identify high-activity and
low-activity days for targeted engagement.

----------------------------------------------------------------------*/

SELECT
    DATENAME(WEEKDAY, ActivityDate) AS DayOfWeek,
    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgSteps
FROM dbo.DailyActivity
GROUP BY DATENAME(WEEKDAY, ActivityDate)
ORDER BY AVG(TotalSteps) DESC;
GO

/*
Result:

Saturday    : 8,153 steps

Tuesday     : 8,125 steps

Monday      : 7,781 steps

Wednesday   : 7,559 steps

Friday      : 7,448 steps

Thursday    : 7,406 steps

Sunday      : 6,933 steps

Interpretation:

Users are most active on Saturdays and least active
on Sundays.

Weekend behaviour differs, with activity peaking on
Saturday before dropping significantly on Sunday.

Business Insight:

Bellabeat can improve user engagement by scheduling
walking challenges, motivational reminders, and
fitness notifications on Sundays when activity levels
are lowest.
*/

/*======================================================================
                    STEP 6: STEPS VS CALORIES
======================================================================

Objective:
Determine whether higher daily step counts are generally
associated with higher calorie expenditure.

Business Reason:
Understanding this relationship helps Bellabeat encourage
users to increase their daily activity through personalized
fitness goals.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: DAILY STEP CATEGORIES

Question:
How do average calories burned differ across step-count
categories?

Business Reason:
Grouping users into activity levels makes the results easier
for business stakeholders to understand.

----------------------------------------------------------------------*/

SELECT
    CASE
        WHEN TotalSteps < 5000 THEN 'Sedentary (<5,000)'
        WHEN TotalSteps BETWEEN 5000 AND 7499 THEN 'Low Active (5,000-7,499)'
        WHEN TotalSteps BETWEEN 7500 AND 9999 THEN 'Somewhat Active (7,500-9,999)'
        ELSE 'Active (10,000+)'
    END AS ActivityLevel,

    COUNT(*) AS NumberOfDays,

    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgSteps,

    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories

FROM dbo.DailyActivity

GROUP BY
    CASE
        WHEN TotalSteps < 5000 THEN 'Sedentary (<5,000)'
        WHEN TotalSteps BETWEEN 5000 AND 7499 THEN 'Low Active (5,000-7,499)'
        WHEN TotalSteps BETWEEN 7500 AND 9999 THEN 'Somewhat Active (7,500-9,999)'
        ELSE 'Active (10,000+)'
    END

ORDER BY AvgSteps;
GO

/*
Result:

Sedentary (<5,000)
Average Steps     : 2,128
Average Calories  : 1,807

Low Active (5,000–7,499)
Average Steps     : 6,264
Average Calories  : 2,254

Somewhat Active (7,500–9,999)
Average Steps     : 8,726
Average Calories  : 2,461

Active (10,000+)
Average Steps     : 13,337
Average Calories  : 2,744

Interpretation:

The analysis shows a clear positive association between
daily step count and average calories burned.

As average daily steps increase, average calorie expenditure
also increases across all activity categories.

Business Insight:

Bellabeat can encourage users to gradually increase their
daily step count through personalized goals, progress
tracking, walking challenges, and motivational reminders.

Users in the Sedentary and Low Active categories present
the greatest opportunity for targeted engagement.
*/

/*======================================================================
                    STEP 7: DAILY STEP GOAL ACHIEVEMENT
======================================================================

Objective:
Determine the proportion of daily records that achieve
the commonly referenced 10,000-step goal.

Business Reason:
This helps Bellabeat understand how frequently users reach
a high daily activity level and identify opportunities for
engagement.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: STEP GOAL ACHIEVEMENT

Question:
How many daily records achieved at least 10,000 steps?

Business Reason:
Understanding the proportion of active versus less active
days supports targeted marketing and wellness campaigns.

----------------------------------------------------------------------*/

SELECT
    CASE
        WHEN TotalSteps >= 10000 THEN 'Goal Achieved (10,000+)'
        ELSE 'Goal Not Achieved (<10,000)'
    END AS StepGoalStatus,

    COUNT(*) AS NumberOfDays,

    CAST(
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.DailyActivity),
        2
    ) AS DECIMAL(5,2)
) AS PercentageOfDays

FROM dbo.DailyActivity

GROUP BY
    CASE
        WHEN TotalSteps >= 10000 THEN 'Goal Achieved (10,000+)'
        ELSE 'Goal Not Achieved (<10,000)'
    END

ORDER BY NumberOfDays DESC;
GO

/*
Result:

Goal Not Achieved (<10,000)
Number of Days : 637
Percentage     : 67.77%

Goal Achieved (10,000+)
Number of Days : 303
Percentage     : 32.23%

Interpretation:

Only 32.23% of the 940 daily activity records achieved
at least 10,000 steps, while 67.77% remained below the goal.

These percentages represent daily observations rather than
the percentage of unique users. A single user may appear in
both categories on different days.

Business Insight:

Most recorded days did not meet the 10,000-step benchmark.
Bellabeat can use personalised goals, progress reminders,
streaks, milestone rewards, and targeted activity challenges
to help users increase their daily movement consistently.
*/

/*======================================================================
                    STEP 8: DEVICE USAGE FREQUENCY
======================================================================

Objective:
Measure how consistently each participant used the Fitbit
device during the 31-day observation period.

Business Reason:
Usage frequency helps Bellabeat distinguish highly engaged
users from occasional users and design suitable retention
strategies.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: RECORDED DAYS PER USER

Question:
How many days of activity data were recorded for each user?

Business Reason:
This shows the consistency of device usage across participants.
----------------------------------------------------------------------*/

SELECT
    Id,
    COUNT(DISTINCT ActivityDate) AS RecordedDays
FROM dbo.DailyActivity
GROUP BY Id
ORDER BY RecordedDays DESC;
GO

/*
Result:

The dataset contains activity records for 33 Fitbit users.

Several users recorded activity for the full 31-day
observation period, indicating strong device engagement.

Interpretation:

Many participants consistently used their Fitbit devices
throughout the study period.

Business Insight:

Bellabeat should continue investing in features that
encourage long-term device usage, such as personalized
goals, achievement badges, reminders, and progress tracking.
*/

/*======================================================================
                    STEP 9: MOST ACTIVE USERS
======================================================================

Objective:
Identify the users with the highest average daily step count.

Business Reason:
Recognizing highly active users can help Bellabeat develop
reward programs, ambassador campaigns, and personalized
fitness experiences.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: TOP 10 MOST ACTIVE USERS

Question:
Who are the most active users based on average daily steps?

Business Reason:
Highly active users can provide insights into successful
behaviour patterns and help shape engagement strategies.

----------------------------------------------------------------------*/

SELECT TOP 10
    Id,
    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgDailySteps,
    ROUND(AVG(TotalDistance),2) AS AvgDailyDistance,
    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories
FROM dbo.DailyActivity
GROUP BY Id
ORDER BY AvgDailySteps DESC;
GO

/*
Result:

The analysis identified the ten most active Fitbit users
based on their average daily step count.

Several users consistently exceeded the commonly referenced
10,000-step goal.

Interpretation:

Highly active users demonstrated average daily step counts
between approximately 9,000 and over 12,000 steps.

Although higher step counts were generally associated with
higher calorie expenditure, calorie burn varied between
users, suggesting that additional factors also influence
daily energy expenditure.

Business Insight:

Bellabeat can study the behaviour of highly active users
to develop personalized recommendations, ambassador
programs, achievement badges, and motivational campaigns
that encourage other users to become more active.
*/

/*======================================================================
                    STEP 10: LEAST ACTIVE USERS
======================================================================

Objective:
Identify the users with the lowest average daily step count.

Business Reason:
Understanding which users are least active helps Bellabeat
target personalized wellness campaigns and increase user
engagement.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: BOTTOM 10 LEAST ACTIVE USERS

Question:
Which users have the lowest average daily step count?

Business Reason:
These users are the most likely to benefit from personalized
coaching, reminders, and activity challenges.

----------------------------------------------------------------------*/

SELECT TOP 10
    Id,
    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgDailySteps,
    ROUND(AVG(TotalDistance),2) AS AvgDailyDistance,
    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories
FROM dbo.DailyActivity
GROUP BY Id
ORDER BY AvgDailySteps ASC;
GO

/*
Result:

The analysis identified the ten least active users
based on average daily step count.

Several users averaged fewer than 3,000 steps per day,
indicating very low daily activity levels.

Interpretation:

The dataset shows substantial variation in user activity.

Some participants consistently exceeded 10,000 daily steps,
while others averaged fewer than 3,000 steps.

Business Insight:

Bellabeat should avoid using a single activity goal for
all users.

Instead, personalized step targets, adaptive coaching,
and progressive challenges can help users gradually
increase their physical activity and remain motivated.
*/

/*======================================================================
                STEP 11: EXECUTIVE KPI DASHBOARD
======================================================================

Objective:
Create an executive summary of the DailyActivity dataset.

Business Reason:
Senior management requires high-level KPIs rather than
individual transaction records.

These KPIs will also serve as the foundation for the
Power BI dashboard.

======================================================================*/


/*----------------------------------------------------------------------
EXECUTIVE KPI SUMMARY

Question:
What are the key metrics that describe the dataset?

Business Reason:
Provide management with an at-a-glance summary of user
activity and engagement.

----------------------------------------------------------------------*/

SELECT

    COUNT(DISTINCT Id) AS TotalUsers,

    COUNT(*) AS TotalRecords,

    MIN(ActivityDate) AS StartDate,

    MAX(ActivityDate) AS EndDate,

    DATEDIFF(DAY,
             MIN(ActivityDate),
             MAX(ActivityDate)) + 1 AS ObservationPeriod,

    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgDailySteps,

    ROUND(AVG(TotalDistance),2) AS AvgDistanceKm,

    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories,

    ROUND(AVG(CAST(VeryActiveMinutes AS FLOAT)),0) AS AvgVeryActiveMinutes,

    ROUND(AVG(CAST(FairlyActiveMinutes AS FLOAT)),0) AS AvgFairlyActiveMinutes,

    ROUND(AVG(CAST(LightlyActiveMinutes AS FLOAT)),0) AS AvgLightlyActiveMinutes,

    ROUND(AVG(CAST(SedentaryMinutes AS FLOAT)),0) AS AvgSedentaryMinutes,

    SUM(CASE
            WHEN TotalSteps >= 10000 THEN 1
            ELSE 0
        END) AS GoalAchievedDays,

    SUM(CASE
            WHEN TotalSteps < 10000 THEN 1
            ELSE 0
        END) AS GoalNotAchievedDays

FROM dbo.DailyActivity;
GO

/*
Interpretation:

The Executive KPI Summary provides a high-level overview
of the Fitbit activity dataset.

It consolidates user counts, observation period,
average activity metrics, and step-goal achievement
into a single result set.

Business Insight:

This summary enables management to assess user activity
at a glance and forms the basis for executive dashboards
and performance monitoring.
*/

/*======================================================================
                STEP 12: ACTIVITY LEVEL DISTRIBUTION
======================================================================

Objective:
Determine the distribution of daily activity records across
different step-count categories.

Business Reason:
Understanding the distribution of activity levels helps
Bellabeat identify where most users fall and where
engagement efforts should be concentrated.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: ACTIVITY LEVEL DISTRIBUTION

Question:
How are daily records distributed across activity levels?

Business Reason:
Provides management with an overview of user activity
segments.

----------------------------------------------------------------------*/

SELECT

    CASE

        WHEN TotalSteps < 5000
            THEN 'Sedentary (<5,000)'

        WHEN TotalSteps BETWEEN 5000 AND 7499
            THEN 'Low Active (5,000-7,499)'

        WHEN TotalSteps BETWEEN 7500 AND 9999
            THEN 'Somewhat Active (7,500-9,999)'

        ELSE 'Active (10,000+)'

    END AS ActivityLevel,

    COUNT(*) AS NumberOfDays,

    CAST(
        ROUND(
            COUNT(*) * 100.0 /
            (SELECT COUNT(*) FROM dbo.DailyActivity),
            2
        ) AS DECIMAL(5,2)
    ) AS Percentage

FROM dbo.DailyActivity

GROUP BY

    CASE

        WHEN TotalSteps < 5000
            THEN 'Sedentary (<5,000)'

        WHEN TotalSteps BETWEEN 5000 AND 7499
            THEN 'Low Active (5,000-7,499)'

        WHEN TotalSteps BETWEEN 7500 AND 9999
            THEN 'Somewhat Active (7,500-9,999)'

        ELSE 'Active (10,000+)'

    END

ORDER BY NumberOfDays DESC;

GO

/*
Interpretation:

The activity level distribution shows how frequently
daily records fall into each physical activity category.

Business Insight:

This analysis helps Bellabeat understand the proportion
of sedentary, moderately active, and highly active days.

The findings can guide personalized wellness campaigns
and targeted engagement strategies.
*/

/*======================================================================
                STEP 13: WEEKDAY VS WEEKEND ANALYSIS
======================================================================

Objective:
Compare user activity between weekdays and weekends.

Business Reason:
Understanding weekly behaviour patterns helps Bellabeat
schedule marketing campaigns and wellness reminders more
effectively.

======================================================================*/


/*----------------------------------------------------------------------
CHECK 1: WEEKDAY VS WEEKEND

Question:
Do users behave differently during weekdays and weekends?

Business Reason:
Understanding these differences helps optimize customer
engagement strategies.

----------------------------------------------------------------------*/

SELECT

    CASE

        WHEN DATENAME(WEEKDAY, ActivityDate) IN ('Saturday','Sunday')
            THEN 'Weekend'

        ELSE 'Weekday'

    END AS DayType,

    COUNT(*) AS NumberOfRecords,

    ROUND(AVG(CAST(TotalSteps AS FLOAT)),0) AS AvgSteps,

    ROUND(AVG(TotalDistance),2) AS AvgDistanceKm,

    ROUND(AVG(CAST(Calories AS FLOAT)),0) AS AvgCalories,

    ROUND(AVG(CAST(VeryActiveMinutes AS FLOAT)),0) AS AvgVeryActiveMinutes,

    ROUND(AVG(CAST(SedentaryMinutes AS FLOAT)),0) AS AvgSedentaryMinutes

FROM dbo.DailyActivity

GROUP BY

    CASE

        WHEN DATENAME(WEEKDAY, ActivityDate) IN ('Saturday','Sunday')
            THEN 'Weekend'

        ELSE 'Weekday'

    END

ORDER BY DayType;

GO

/*
Result:

Weekdays:
Average Steps             : 7,669
Average Distance          : 5.51 km
Average Calories          : 2,302 kcal
Average Very Active Minutes : 21 mins
Average Sedentary Minutes : 996 mins

Weekends:
Average Steps             : 7,551
Average Distance          : 5.45 km
Average Calories          : 2,310 kcal
Average Very Active Minutes : 21 mins
Average Sedentary Minutes : 977 mins

Interpretation:

User activity remains relatively consistent between
weekdays and weekends. Differences in average daily
steps and distance are small, indicating stable activity
patterns throughout the week.

Weekend records show slightly higher average calories
burned and slightly lower sedentary time, but these
differences are modest.

Business Insight:

Bellabeat should maintain consistent engagement
throughout the week while using personalized
recommendations based on individual activity levels
rather than relying solely on weekday/weekend
differences.
*/

/*======================================================================
                STEP 14: EXECUTIVE BUSINESS RECOMMENDATIONS
======================================================================

Project Objective

Analyze Fitbit smart device usage data to identify
customer behaviour trends and provide data-driven
marketing recommendations for Bellabeat.

======================================================================*/

/*
======================================================================

BUSINESS QUESTION 1

What trends exist in smart device usage?

Findings

1. The dataset contains activity records from 33 users
   over a continuous 31-day period.

2. Users average:

   • 7,638 daily steps

   • 5.49 km walked

   • 2,304 calories burned

3. Only 32.23% of recorded days achieved the
   commonly referenced 10,000-step goal.

4. User activity varies considerably.

   Some users average more than 12,000 steps
   while others average fewer than 3,000.

5. Saturday recorded the highest average steps,
   while Sunday recorded the lowest.

6. Weekday and weekend activity levels are generally
   consistent with only small differences.

Conclusion

Bellabeat users demonstrate moderate activity levels,
but most recorded days fall below the 10,000-step goal,
indicating opportunities to encourage greater
daily movement.

======================================================================
*/

/*
======================================================================

BUSINESS QUESTION 2

How could these trends apply to Bellabeat customers?

Findings

The analysis suggests that Bellabeat customers are
unlikely to have identical activity patterns.

Instead, users naturally fall into different
activity groups ranging from sedentary to highly active.

Implications

Bellabeat should avoid using a one-size-fits-all
fitness strategy.

Instead, personalized experiences should be created
based on individual activity behaviour.

Examples include:

• Personalized daily step goals

• Adaptive coaching

• Progress tracking

• Activity reminders

• Weekly wellness challenges

• Achievement badges

These personalized features are more likely to
increase long-term engagement than generic
fitness recommendations.

======================================================================
*/

/*
======================================================================

BUSINESS QUESTION 3

How could these trends influence Bellabeat's
marketing strategy?

Recommendations

Recommendation 1

Implement personalized activity goals rather than
assigning every user the same daily target.

--------------------------------------------------

Recommendation 2

Target users with lower activity levels using
motivational reminders and progressive walking
challenges.

--------------------------------------------------

Recommendation 3

Reward highly active users through ambassador
programs, achievement badges, and premium
fitness challenges.

--------------------------------------------------

Recommendation 4

Develop marketing campaigns that emphasize
consistent daily movement rather than occasional
high activity.

--------------------------------------------------

Recommendation 5

Use behavioural segmentation to deliver
personalized health insights and recommendations.

======================================================================
*/

/*======================================================================

PROJECT CONCLUSION

This project analyzed Fitbit smart device usage data
using Microsoft SQL Server.

The analysis included:

• Data validation

• Data quality assessment

• Exploratory Data Analysis (EDA)

• User segmentation

• Activity trend analysis

• Executive KPI reporting

The findings indicate that users generally maintain
moderate activity levels, although most daily records
do not achieve the commonly referenced 10,000-step goal.

The analysis also demonstrates that user behaviour
varies considerably, highlighting the importance of
personalized engagement strategies.

Overall, Bellabeat can improve customer engagement
through adaptive coaching, personalized activity goals,
behavioural segmentation, and consistent wellness
campaigns.

======================================================================*/