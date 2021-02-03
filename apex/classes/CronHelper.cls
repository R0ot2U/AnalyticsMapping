// we need a class to validate, correct and convert schedules into cron expressions that our 
// scheduling endpoint can use to create a list of future scheduled dataflow/recipe runs
// Good guide for understanding cron expression syntax http://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html
// endpoint we are using http://www.cronmaker.com/help/rest-api-help.html

public without sharing class CronHelper {
    
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

		scheduleType - daily, hourly, weekly
		hourlyInterval - integer 1-24 (24 may be invalid though as I've seen)
		startTime is only hour and minutes as we don't allow seconds so 00 for seconds
		daysOfWeek convert to integer value Sunday - Saturday / 1-7
     */
    public static String convertJsonToCronExp(String input) {
    	
        String cronExp;
        
        return cronExp;
    }
    
    //	for some reason having an increment of 24 on hours of a cronExpression isn't handled by 
    //	the endpoint we use to get the future dates so we need to convert it to 0 as in every day
    public static String convertInvalidCronExp(String cronExpIn) {
        String cronExpOut;
        
        return cronExpOut;
    }
    
}