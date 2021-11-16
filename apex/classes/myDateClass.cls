public class myDateClass{
    
    static map<string,integer> dowMap = new map<string,integer>{'Monday'=>0,
        'Tuesday'=>1,
        'Wednesday'=>2,
        'Thursday'=>3,
        'Friday'=>4,
        'Saturday'=>5,
        'Sunday'=>6};                                                           
            
            public static list<date> getMyDates(string dayOfWeekName, integer month, integer year){
                list<date> returnList = new list<date>();
                date d = date.newInstance(year,month,1);
                d=d.addDays(math.mod(7-dayOfWeek(d)+dowMap.get(dayOfWeekName),7));//brings you to the first instance of the specified dayOfWeekName of the month
                
                do{
                    returnList.add(d);
                    d=d.addDays(7);
                } while(d.month()==month);
                
                return returnList;
            }
    
    public static integer dayOfWeek(date d){
        return math.mod(date.newInstance(1900,1,8).daysBetween(d),7); 
    }
}
