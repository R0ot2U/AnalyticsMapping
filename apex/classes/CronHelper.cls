// we need a class to validate, correct and convert schedules into cron expressions that our 
// scheduling endpoint can use to create a list of future scheduled dataflow/recipe runs
// Good guide for understanding cron expression syntax http://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html
// endpoint we are using http://www.cronmaker.com/help/rest-api-help.html

public without sharing class CronHelper {
    
    // Flag
    public static Boolean flag = false;
    
    // Days
    // Days map Sun>Sat / String Key to String Value
    public static Map<String, String> daysMap = new Map<String, String>{
        'Sunday' => 'Sunday',
            'Monday' => 'Monday',
            'Tuesday' => 'Tuesday',
            'Wednesday' => 'Wednesday',
            'Thursday' => 'Thursday',
            'Friday' => 'Friday',
            'Saturday' => 'Saturday'
            };
                
                // Days map Sun>Sat / 1>7 String Key to Integer Value
                public static Map<String, Integer> daysMap2 = new Map<String, Integer>{
                    'Sunday' => 1,
                        'Monday' => 2,
                        'Tuesday' => 3,
                        'Wednesday' => 4,
                        'Thursday' => 5,
                        'Friday' => 6,
                        'Saturday' => 7
                        };
                            
                            // Day of week Mon>Sun / 0>6 String Key to Integer value
                            static map<string,integer> dowMap = new map<string,integer>{
                                'Monday'=>0,
                                    'Tuesday'=>1,
                                    'Wednesday'=>2,
                                    'Thursday'=>3,
                                    'Friday'=>4,
                                    'Saturday'=>5,
                                    'Sunday'=>6
                                    }; 
                                        
                                        // Day of week Sun>Sat / 1>7 Integer Key to String value
                                        static map<Integer,String> dowMap2 = new map<Integer,String>{
                                            1=>'Sunday',
                                                2=>'Monday',
                                                3=>'Tuesday',
                                                4=>'Wednesday',
                                                5=>'Thursday',
                                                6=>'Friday',
                                                7=>'Saturday'
                                                };     
                                                    
                                                    // Creates a list of the days of the week Sun > Sat
                                                    public static List<String> daysList = daysMap.values();
    
    // Creates a list of the days of the week Sun > Sat and their integer equivilant
    public static List<Integer> daysList2 = daysMap2.values();
    
    // Months
    Integer January = 0;
    Integer February = 1;
    Integer March = 2;
    Integer April = 3;
    Integer May = 4;
    Integer June = 5;
    Integer July = 6;
    Integer August = 7;
    Integer September = 8;
    Integer October = 9;
    Integer November = 10;
    Integer December = 11;
    
    // CronExpression Values
    Integer seconds = 0;
    Integer minutes = 1;
    Integer hours = 2;
    Integer days = 3;
    Integer months = 4;
    
    
    //	validate the cronExpression   
    public static boolean isValid(String cronExp) {
        boolean valid = false;
        
        if(valid){
            return valid;
        } 
        return valid;
    }
    
    //	convert scheduleAttributes of dataflows to cron expression value instead
    /*
Example formart we are dealing with
{
"scheduleType": "hourly",
"hourlyInterval": 3,
"timeZone": "Europe/Dublin",
"startTime": { "hour": 13, "minute": 0 },
"daysOfWeek": ["Sunday", "Monday", "Tuesday", "Thursday", "Friday"]
}

scheduleType - daily, hourly, weekly, monthly
hourlyInterval - integer 1-24 (24 may be invalid though as I've seen)
startTime is only hour and minutes as we don't allow seconds so 00 for seconds
daysOfWeek convert to integer value Sunday - Saturday / 1-7

for the cronExp we don't need to set seconds, 
minutes are set but won't have any modifier 
hours are set and can have recuring value set for repeating
days can be set
days of week can be set
*/
    public static String convertJsonToCronExp(String input) {
        
        String cronExp = '';
        // 0 30 0/6 ? * 1,2,3,4,5,7
        // 'ss' 'mm' 'hh' 'DD' 'MM' 'DAY of Week'
        List<String> cronExpList = new List<String>{'*','*','*','*','*','*'};
            String regExp = '\"|\\]|\\[';
        
        
        System.debug('JsonString: '+input);      
        
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(input);
        Map<String, Object> startTime = (Map<String, Object>)jsonMap.get('startTime');
        
        System.debug('jsonMap: '+jsonMap);
        System.debug('scheduledType: '+jsonMap.get('scheduleType'));
        System.debug('hourlyInterval: '+jsonMap.get('hourlyInterval'));
        System.debug('timeZone: '+jsonMap.get('timeZone'));
        System.debug('startTime: '+jsonMap.get('startTime'));
        System.debug('daysOfWeek: '+jsonMap.get('daysOfWeek')); 
        System.debug('startTime hour: '+startTime.get('hour'));
        System.debug('startTime minute: '+startTime.get('minute'));
        System.debug('daysOfMonth: '+jsonMap.get('daysOfMonth'));
        
        // Seconds
        // Don't need to do anything with seconds so skip first list var
        cronExpList[0] = '*';
        
        // Minutes
        cronExpList[1] = JSON.serialize(startTime.get('minute'));
        
        // Hours
        cronExpList[2] = JSON.serialize(startTime.get('hour'));
        
        // Day of Month
        if(jsonMap.get('scheduleType') == 'monthly') {
            cronExpList[3] = '*';
            if (jsonMap.get('daysOfMonth') != 'null') {
                System.debug('inside if');
                String daysOfTheMonth = (JSON.serialize(jsonMap.get('daysOfMonth')).replace('"','')).replace('[','');
                daysOfTheMonth = daysOfTheMonth.replaceAll(regExp,'');
                system.debug('daysOfTheMonth: '+daysOfTheMonth);
                cronExpList[3] = daysOfTheMonth;
            } 
        } else {
            cronExpList[3] = '?';
        }
        
        // Month
        cronExpList[4] = '*';
        
        // Day of Week
        if(jsonMap.get('scheduleType') == 'monthlyrelative') {
            String dayInWeek = JSON.serialize(jsonMap.get('dayInWeek'));
            system.debug('dayInWeek: '+dayInWeek);
            dayInWeek = dayInWeek.replace('"','');
            
            switch on dayInWeek {
                when 'Sunday' {
                    dayInWeek = daysList[0];
                }	
                when 'Monday' {
                    dayInWeek = daysList[1];
                }
                when 'Tuesday' {
                    dayInWeek = daysList[2];
                }
                when 'Wednesday' {
                    dayInWeek = daysList[3];
                }
                when 'Thursday' {
                    dayInWeek = daysList[4];
                }
                when 'Friday' {
                    dayInWeek = daysList[5];
                }
                when 'Saturday' {
                    dayInWeek = daysList[6];
                }
                when else {
                    System.debug('Error!');
                }
            }
            
            String weekInMonth = JSON.serialize(jsonMap.get('weekInMonth'));
            weekInMonth = weekInMonth.replace('"','');
            system.debug('weekInMonth: '+weekInMonth);
            if(weekInMonth == 'L'){
                cronExpList[5] = dayInWeek + weekInMonth; 
            } else {
                cronExpList[5] = dayInWeek + '#' + weekInMonth; 
            }
            
            
        } else {
            String daysOfTheWeek = (JSON.serialize(jsonMap.get('daysOfWeek')).replace('"','')).replace('[','');
            daysOfTheWeek = daysOfTheWeek.replaceAll(regExp,'');
            system.debug('daysOfTheWeek: '+daysOfTheWeek);
            if(daysOfTheWeek != 'null'){
                cronExpList[5] = daysOfTheWeek;
            } else {
                cronExpList[5] = '?';
            }
        }
        
        //build the CronExpression        
        for(String cronPart : cronExpList) {
            if(cronPart != null){
                cronExp += cronPart + ' ';
            }
        }
        
        system.debug('cronExp Return value: '+cronExp);
        return cronExp;
    }
    
    //	for some reason having an increment of 24 on hours of a cronExpression isn't handled by 
    //	the endpoint we use to get the future dates so we need to convert it to 0 as in every day
    
    public static String convertInvalidCronExp(String cronExpIn) {
        String cronExpOut;
        
        List<String> cronExpList = cronExpIn.split(' ');
        System.debug(cronExpList);
        
        System.debug(cronExpList[2]);
        //Get last two characters of hour and if it's 24 convert to 0
        
        
        String cronExpHours = cronExpList[2];
        String cronExpHoursFix = cronExpHours.splitByCharacterType()[2];
        
        system.debug('cronExpHours: '+cronExpHours);
        system.debug('cronExpHoursFix: '+cronExpHoursFix);
        /*
if(cronExpHoursFix == '24') {
cronExpHours = cronExpHours.substring(0, cronExpHours.length()-2); 
cronExpHours += '0';
system.debug('cronExpHours: '+cronExpHours);
}

cronExpList.set(2,cronExpHours); 
cronExpOut = String.join(cronExpList,' ');
*/
        system.debug('cronExpOut: '+cronExpOut);
        
        return cronExpOut;
    }
    
    public static boolean validateCronExp(String cronExpIn) {
        // do some stuff to check cronExp is valid and return true or false based on the validity
        
        Pattern cronExpPattern = pattern.compile('^((((\\d+,)+\\d+|(\\d+(\\/|-|#)\\d+)|\\d+L?|\\*(\\/\\d+)?|L(-\\d+)?|\\?|[A-Z]{3}(-[A-Z]{3})?) ?){5,7})$|(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\\d+(ns|us|µs|ms|s|m|h))+)');
        Matcher cronExpMatcher = cronExpPattern.matcher(cronExpIn);
        
        return cronExpMatcher.matches();
    }
    
    public static String calculateFutureJobs(String cronExpIn, Integer count) {
        // calculate the next n number of dates based on an input cronExpression variable by count support up to 50 
        String futureDatesString;
        List<String> futureDatesList = new List<String>();
        List<String> cronExpList = cronExpIn.split(' ');
        
        system.debug('cronExpList: '+cronExpList);
        
        List<String> cronSecond = cronExpList[0].splitByCharacterType();
        List<String> cronMinute = cronExpList[1].splitByCharacterType();
        List<String> cronHour = cronExpList[2].splitByCharacterType();
        List<String> cronDayOfMonth = cronExpList[3].split(',');
        List<String> cronMonth = cronExpList[4].splitByCharacterType();
        List<String> cronDayOfWeek = cronExpList[5].split(',');
        
        if(cronDayOfWeek.size()==1){
            cronDayOfWeek = cronExpList[5].splitByCharacterType();
        }
        Integer DayOfWeek;
        Integer WeekNum;
        
        system.debug('cronMinute: '+cronMinute);
        system.debug('cronHour: '+cronHour);
        system.debug('cronDayOfMonth: '+cronDayOfMonth);
        system.debug('cronMonth: '+cronMonth);
        system.debug('cronDayofWeek: '+cronDayOfWeek);
        
        Integer incrementMinute = 0;
        Integer incrementHour = 0;
        Integer startCronHour = 0;
        Integer endCronHour = 23;
        DateTime startingRunForDay = DateTime.now();
        DateTime now = DateTime.now();
        String currentYear = String.valueOf(startingRunForDay.yearGMT());
        String currentMonth = String.valueOf(startingRunForDay.monthGMT());
        String currentDay = String.valueOf(startingRunForDay.dayGMT());
        String currentHour = String.valueOf(startingRunForDay.hourGMT());
        String currentMinute = String.valueOf(startingRunForDay.minuteGMT());
        String currentSecond = String.valueOf(startingRunForDay.secondGMT());
        String startingMinute = cronExpList[1].splitByCharacterType()[0];
        String startingHour = cronExpList[2].splitByCharacterType()[0];
        
        Integer currentMonthInt;
        Integer currentYearInt;
        
        if(cronMinute.size()>1){
            incrementMinute = Integer.valueOf(cronMinute[2]);
            if(cronHour.size()>1 && cronHour[1] == '-'){
                startCronHour = Integer.valueOf(cronHour[0]);
                endCronHour = Integer.valueOf(cronHour[2]);
            }
        } else if(cronHour.size()>1){
            if(cronHour[2]=='0') {
                incrementHour = 24;
            } else {
                incrementHour = Integer.valueOf(cronHour[2]);
            }
        } else if(cronMinute.size()==1 && cronHour.size()==1) {
            incrementHour = 24;
        } else {
            //system.debug('should not be here');
        }
        
        // UTC only no timezone modification
        // TODO 
        //    Support timezone
        //    Support First/Last day of month e.g. 0 30 0 1 * ?  AND 0 45 4 L * ?
        startingRunForDay = DateTime.valueOfgmt(currentYear + '-' + currentMonth + '-' + currentDay + ' ' + startingHour + ':' + startingMinute +  ':' + '00');
        Integer i = 0;
        
        // Day of Month evaluation
        
        if(cronDayOfMonth.size() > 1 && cronDayOfMonth[0] != '?' ){ // First is for multiple selected days
            system.debug('HERE NOW');
            
            do{
                for(String day : cronDayOfMonth){  
                    startingRunForDay = DateTime.valueOfgmt(currentYear + '-' + currentMonth + '-' + cronDayOfMonth[i] + ' ' + startingHour + ':' + startingMinute +  ':' + '00');
                    system.debug('day: '+day);
                    system.debug('startingRunForDay.day(): '+startingRunForDay.day());
                    system.debug('If evaluation: '+(startingRunForDay.day() == Integer.valueOf(day) && startingRunForDay<=now && futureDatesList.size()<count));
                    if(startingRunForDay.day() == Integer.valueOf(day) && startingRunForDay<=now && futureDatesList.size()<count) {
                        i++;
                        continue;
                    } else {
                        // List value to return
                        futureDatesList.add(String.valueOfGMT(startingRunForDay));
                        
                        // String of dates to return 
                        if(String.isBlank(futureDatesString)){
                            futureDatesString = String.valueOfGMT(startingRunForDay);
                        } else {
                            futureDatesString +=','+ String.valueOfGMT(startingRunForDay);                                  
                        }
                        i++;
                    }
                }
                // reset the day of month list reference
                i = 0;
                currentMonthInt = Integer.valueOf(currentMonth);
                currentMonthInt++;
                currentMonth = String.valueOf(currentMonthInt);
                if(Integer.valueOf(currentMonth) > 12){
                    currentMonth = '1';
                    currentYearInt = Integer.valueOf(currentYear);
                    currentYearInt++;
                    currentYear = String.valueOf(currentYearInt);
                }
                
            } while (futureDatesList.size()<count || futureDatesList.size()<12);
            flag = true;
        } else if (cronDayOfMonth.size()==1 && cronDayOfMonth[0]=='L' && cronDayOfMonth[0] != '?') { // last of the month
            do{
                
            } while (futureDatesList.size()<count || futureDatesList.size()<12);            
        } else if (cronDayOfMonth.size()==1 && cronDayOfMonth[0]=='1' && cronDayOfMonth[0] != '?') { // first of the month or single day
            do{
                
            } while (futureDatesList.size()<count || futureDatesList.size()<12);            
        } else {
            // Might be * if performance saving is needed cut this out earlier
            System.debug('cronDayOfMonth[0]: '+cronDayOfMonth[0]);
            System.debug('SHOULD NOT BE HERE');
        }
        
        //nth day of nth week in month 
        if(cronDayOfWeek.size() > 1 && (cronDayOfWeek[1] == 'L' || cronDayOfWeek[1] == '#')){
            
            system.debug('Nth calcualtion');
            
            DayOfWeek = Integer.valueOf(cronDayOfWeek[0]);
            String DayOfWeekString = dowMap2.get(DayOfWeek);
            //system.debug('DayOfWeek: '+DayOfWeek);
            //system.debug('DayOfWeekString: '+DayOfWeekString);
            
            Integer currentMonthForNth = Integer.valueOf(currentMonth);
            Integer currentYearForNth = Integer.valueOf(currentYear);
            Integer startingHourForNth = Integer.valueOf(startingHour);
            Integer startingMinuteForNth = Integer.valueOf(startingMinute);
            
            //system.debug('startingHourForNth: '+startingHourForNth);
            //system.debug('startingMinuteForNth: '+startingMinuteForNth);
            
            do{
                // gets list of dates for the month for the nth day will be from 4-6
                // 
                //system.debug('Nth calcualtion'); 
                //system.debug('currentMonthForNth: '+currentMonthForNth);
                //system.debug('currentYearForNth: '+currentYearForNth);
                //system.debug('DayOfWeekString: '+DayOfWeekString);
                
                
                List<Date> singleMonthOfDates = myDateClass.getMyDates(DayOfWeekString, currentMonthForNth, currentYearForNth);
                //system.debug('singleMonthOfDates: '+singleMonthOfDates);
                
                // cover Last day of month or defined day 1-4
                if(cronDayOfWeek[1]=='L'){
                    //system.debug('L');
                    WeekNum = singleMonthOfDates.size()-1;
                } else {
                    //system.debug('#');
                    WeekNum = Integer.valueOf(cronDayOfWeek[2])-1;
                    //system.debug('WeekNum: '+WeekNum);
                }
                
                // List value to return
                futureDatesList.add(String.valueOf(
                    DateTime.newInstance(singleMonthOfDates[WeekNum].year(),
                                         singleMonthOfDates[WeekNum].month(),
                                         singleMonthOfDates[WeekNum].day(),
                                         startingHourForNth,
                                         startingMinuteForNth,
                                         0)));
                
                // String of dates to return, if it's empty add the first value if it's not then add , and value
                if(String.isBlank(futureDatesString)){
                    futureDatesString = String.valueOf(
                        DateTime.newInstance(singleMonthOfDates[WeekNum].year(),
                                             singleMonthOfDates[WeekNum].month(),
                                             singleMonthOfDates[WeekNum].day(),
                                             startingHourForNth,
                                             startingMinuteForNth,
                                             0));
                } else {
                    futureDatesString +=','+ String.valueOf(
                        DateTime.newInstance(singleMonthOfDates[WeekNum].year(),
                                             singleMonthOfDates[WeekNum].month(),
                                             singleMonthOfDates[WeekNum].day(),
                                             startingHourForNth,
                                             startingMinuteForNth,
                                             0));                                  
                }
                
                // iterate the month for the count if it goes over 12 reset back to month 1 and increment the year
                currentMonthForNth++;
                if(currentMonthForNth > 12){
                    currentMonthForNth = 1;
                    currentYearForNth++;
                }
                
                
                
                
            } while (futureDatesList.size()<count || futureDatesList.size()<12);
            flag = true;
        } else if(cronMinute.size()>1 || cronHour.size()>1 || flag == false) {
            //hour/minute increments
            system.debug('hour / minute calcualtion');             
            do {
                system.debug('hour / minute calcualtion');
                system.debug('cronExpIn: '+cronExpIn);
                system.debug('startingRunForDay: '+startingRunForDay);
                system.debug('now: '+now);
                system.debug('startingRunForDay.hourGmt(): '+startingRunForDay.hourGmt());
                system.debug('startCronHour: '+startCronHour);
                system.debug('endCronHour: '+endCronHour);
                system.debug('String.valueOf(daysMap2.get(startingRunForDay.formatGmt(\'EEEE\'))): '+String.valueOf(daysMap2.get(startingRunForDay.formatGmt('EEEE'))));
                system.debug('String.valueOf(daysMap.get(startingRunForDay.formatGmt(\'EEEE\'))): '+String.valueOf(daysMap.get(startingRunForDay.formatGmt('EEEE'))));
                system.debug('cronDayOfWeek: '+cronDayOfWeek);
                system.debug('cronDayOfWeek.contains(String.valueOf(daysMap2.get(startingRunForDay.formatGmt(\'EEEE\')))): '+cronDayOfWeek.contains(String.valueOf(daysMap2.get(startingRunForDay.formatGmt('EEEE')))));
                system.debug('incrementHour: '+incrementHour);
                system.debug('incrementMinute: '+incrementMinute);
                
                
                
                startingRunForDay = startingRunForDay.addHours(incrementHour);
                startingRunForDay = startingRunForDay.addMinutes(incrementMinute);
                system.debug('i: '+i);             
                if(startingRunForDay>=now && startingRunForDay.hourGmt() >= startCronHour && startingRunForDay.hourGmt() <= endCronHour 
                   &&  (cronDayOfWeek.contains(String.valueOf(daysMap2.get(startingRunForDay.formatGmt('EEEE')))) || cronDayOfWeek.contains(String.valueOf(daysMap.get(startingRunForDay.formatGmt('EEEE')))))){
                       
                       // List value to return
                       futureDatesList.add(String.valueOfGMT(startingRunForDay));
                       
                       // String of dates to return 
                       if(String.isBlank(futureDatesString)){
                           futureDatesString = String.valueOfGMT(startingRunForDay);
                       } else {
                           futureDatesString +=','+ String.valueOfGMT(startingRunForDay);                                  
                       }
                       
                       //System.debug(i);
                       //System.debug('incremental datetime: '+startingRunForDay);
                       i++; 
                   } else {
                       //system.debug('Should not be here');
                   }
                
            } while (i < count);
        }
        
        
        system.debug('futureDatesList: '+futureDatesList);
        system.debug('futureDatesString: '+futureDatesString);
        
        return futureDatesString;
    }
    
}
