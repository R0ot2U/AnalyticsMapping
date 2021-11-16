public class AnalyticsMapController {
    
    private final List<analyticsmap__Dataflow__c> dataflowList;
    private final List<analyticsmap__Dataflow_Job__c> dataflowJobList; 
    private final String[] myArray;
    private final String[] myArrayOfJobs;
    private String[] myCombindArray;
    
    public AnalyticsMapController() {
        
        //SOQL for Dataflow/Recipe List
        dataflowList = [SELECT Id,Name,analyticsmap__Average_Duration_Minutes__c,analyticsmap__Dataflow_Id__c,analyticsmap__Max_Duration_Seconds__c,
                        analyticsmap__Min_Duration_Seconds__c,analyticsmap__Next_Run_Date__c,analyticsmap__Schedule__c,analyticsmap__Type__c,CreatedDate 
                        FROM analyticsmap__Dataflow__c WHERE analyticsmap__Schedule__c!=null ORDER BY Id ASC NULLS FIRST];
        
        //SOQL for DataflowJob List
        //TODO Limit this to Last 30 days only
        dataflowJobList = [SELECT analyticsmap__Dataflow__r.Name, analyticsmap__Dataflow_Instance_Id__c,analyticsmap__Dataflow__c,analyticsmap__Duration__c,
                           analyticsmap__Executed_DateTime__c,analyticsmap__Job_Type__c,analyticsmap__Label__c,analyticsmap__Message__c,analyticsmap__Nodes_URL__c,
                           analyticsmap__Progress__c,analyticsmap__Start_DateTime__c,analyticsmap__Status__c,Id,Name FROM analyticsmap__Dataflow_Job__c 
                           ORDER BY analyticsmap__Dataflow__c ASC NULLS FIRST LIMIT 500];
        
        system.debug('dataflowList: '+dataflowList);
        
        List<String> colors = new List<String>{'red','yellow','pink','green','orange','purple','blue','grey','white','black'};
            List<String> scheduleList = new List<String>();
        String color;
        myArray = new List<String>();
        myArrayOfJobs = new List<String>();
        myCombindArray = new List<String>();
        Integer i = 0;
        Integer p = 0;
        Integer id;
        String content;
        String startDateTime;
        String endDateTime;
        String type;
        Integer count = null;
        count = 50;
        Id curdataflowRecordId;
        DateTime runDate;
        String cronData;
        
        //build ArrayData for future jobs
        for(analyticsmap__Dataflow__c d : dataflowList){
            
            if(CronHelper.validateCronExp(d.analyticsmap__Schedule__c)) {
                cronData = CronHelper.calculateFutureJobs(d.analyticsmap__Schedule__c,count);
            } else {
                cronData = CronHelper.calculateFutureJobs(CronHelper.convertJsonToCronExp(d.analyticsmap__Schedule__c),count);
            }
            
            scheduleList = cronData.split(',');
            /*
            String response = AnalyticsMapping.makeCallout('cronjob', d.analyticsmap__Schedule__c, count);
            //if response is 500 instead of erroring out we give the response String as 'Invalid Expression or Error' 
            system.debug(response);
            if ( response != 'Invalid Expression or Error'){
                scheduleList = response.split(',');
                system.debug(scheduleList);
            } else {
                System.debug('Callout exception or expression is invalid');
                break;
            } */
            Id = i;
            content = d.Name;
            startDateTime = String.valueOfGmt(d.analyticsmap__Next_Run_Date__c);
            System.debug('d.analyticsmap__Next_Run_Date__c: '+d.analyticsmap__Next_Run_Date__c);
            System.debug('d.analyticsmap__Average_Duration_Minutes__c: '+d.analyticsmap__Average_Duration_Minutes__c);
            System.debug('d.Id :'+d.Id);
            endDateTime = String.valueOfGmt(d.analyticsmap__Next_Run_Date__c.addMinutes((d.analyticsmap__Average_Duration_Minutes__c).intValue()));
            color = colors[p];
            system.debug('color: '+color);
            p++;            
            myArray.add('{id: '+id+', content: \''+content+'\', start: \''+startDateTime+'Z\', end: \''+endDateTime+'Z\', className: \''+color
                              +'\', title: \''+'<table border="1" class="styled-table"> <tr> <td>ItemId</td><td>'+id+'</td></tr> <td>DataflowId</td><td>02K09000000rRqNEAU</td></tr><tr> <td>Duration</td><td>'+d.analyticsmap__Average_Duration_Minutes__c+'</td></tr></table>'+'\'}');
            // we already have the first schedule run done so remove it from the next iterations list
            scheduleList.remove(0);
            i++;
            for (String schedule : scheduleList) {
                Id=i;
                startDateTime = schedule;
                system.debug('startDateTime: '+startDateTime);
                endDateTime = schedule.replace('T',' ');
                DateTime endDateTimeValue = DateTime.valueOfGMT(endDateTime);
                system.debug('Average Duration: '+d.analyticsmap__Average_Duration_Minutes__c);
                endDateTimeValue = endDateTimeValue.addMinutes((d.analyticsmap__Average_Duration_Minutes__c).intValue());
                endDateTime = String.valueOf(endDateTimeValue);
                myArray.add('{id: '+id+', content: \''+content+'\', start: \''+startDateTime+'Z\', end: \''+endDateTime+'Z\', className: \''+color
                              +'\', title: \''+'<table border="1" class="styled-table"><tr> <td>ItemId</td><td>'+id+'</td></tr> <tr> <td>DataflowId</td><td>02K09000000rRqNEAU</td></tr><tr> <td>Duration</td><td>'+d.analyticsmap__Average_Duration_Minutes__c+'</td></tr></table>'+'\'}');
                i++;
            }
        }
        //system.debug(myArray);
        //system.debug(JSON.serialize(myArray));
        
        //build ArrayOfJobsData for past jobs
        p=0;
        for(analyticsmap__Dataflow_Job__c d : dataflowJobList){
            Id = i;
            if(curdataflowRecordId != d.analyticsmap__Dataflow__c){
                if(curdataflowRecordId==null){
                   curdataflowRecordId = d.analyticsmap__Dataflow__c;
                } else {
                    curdataflowRecordId = d.analyticsmap__Dataflow__c;
                    p++;
                    system.debug('incrementing p');
                }
            }
            content = d.analyticsmap__Dataflow__r.Name;
            if(d.analyticsmap__Executed_DateTime__c!=null){
                runDate = d.analyticsmap__Executed_DateTime__c;
            } else {
                runDate = d.analyticsmap__Start_DateTime__c;
            }
            startDateTime = String.valueOfGmt(runDate);
            endDateTime = String.valueOfGmt(runDate.addSeconds((d.analyticsmap__Duration__c).intValue()));
            color = colors[p];
            //system.debug('color: '+color);
			//system.debug('Id: '+Id);
			//system.debug('content: '+content); 
			//system.debug('startDateTime: '+startDateTime); 
			//system.debug('endDateTime: '+endDateTime);
            //system.debug('color: '+color);
            myArrayOfJobs.add('{id: '+id+', content: \''+content+'\', start: \''+startDateTime+'Z\', end: \''+endDateTime+'Z\', className: \''+color
                              +'\', title: \''+'<table border="1" class="styled-table"><tr> <td>ItemId</td><td>'+id+'</td></tr> <tr> <td>DataflowId</td><td>05v09000000TNM7AAO</td></tr><tr> <td>Duration</td><td>181 secs</td></tr></table>'+'\'}');
            i++;
        }
        
        system.debug(myArrayOfJobs);
        system.debug(JSON.serialize(myArrayOfJobs));
        
    }
    
    public List<analyticsmap__Dataflow__c> getDataflowList() {
        return dataflowList;
    }
    
    public String[] getArrayData() {
        return myArray;
    }
    
    public String[] getArrayOfJobsData() {
        return myArrayOfJobs;
    }
    
    public String[] getCombinedArray() {
        myCombindArray.addAll(myArray);
        myCombindArray.addAll(myArrayOfJobs);
        
        return myCombindArray;
    }
    
}
