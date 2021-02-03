public without sharing class AnalyticsMapping {
    
    // some list vars for comparisons of accepts dataflow types and jobTypes
    public static List<String> jobTypeList = new List<String>{'user','recipe','recipe_v3'};
        public static List<String> typeList = new List<String>{'dataflows','recipes'};
            
            // makeCallout() accepts a string of type and a passedId or null Id value and returns the json 
            // in a string for further processing in parser methods
            public static String makeCallout(String type, Id passedId) {
                
                String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
                String restAPIURL = sfdcURL + '/services/data/v50.0/wave/';
                
                if(type == 'dataflowJobs') {
                    restAPIURL += type;
                    if(passedId != null) {
                        restAPIURL += '/' + passedId;
                    } else {
                        //System.debug('passedId is null');
                    }
                    // for handling dataflows/recipes endpoints directly
                } else if(typeList.contains(type)){
                    restAPIURL += type;
                } else {
                    System.debug('No type provided');
                }
                
                HttpRequest httpRequest = new HttpRequest();  
                httpRequest.setMethod('GET');   
                // looks like we might want to used named credentials for this per Apex PMD validation
                httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                httpRequest.setEndpoint(restAPIURL);  
                String response = '';
                
                
                try {  
                    Http http = new Http();   
                    HttpResponse httpResponse = http.send(httpRequest);  
                    if (httpResponse.getStatusCode() == 200 ) {  
                        response = httpResponse.getBody();
                        return response;   
                    } else {  
                        System.debug(' httpResponse ' + httpResponse.getBody() );  
                        throw new CalloutException( httpResponse.getBody() );  
                    }   
                } catch( System.Exception e) {  
                    System.debug('ERROR: '+ e);  
                    throw e;  
                }  
            }
    
    // this one is for the cronExpression endpoint to give future dates, count is optional
    public static String makeCallout(String type, String cronExp, Integer count) {
        
        String restAPIURL = 'http://www.cronmaker.com/rest/sampler?expression=';
        
        if(type == 'cronjob'){
            system.debug('cronExp: '+cronExp);
            cronExp = cronExp.replace(' ', '%20');
            system.debug(cronExp);
            restAPIURL += cronExp;
            if (count !=null) {
                restAPIURL += '&count='+count;
            }
            system.debug(restAPIURL);
        } else {
            System.debug('No type provided');
        }
        
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        // looks like we might want to used named credentials for this per Apex PMD validation
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpRequest.setEndpoint(restAPIURL);  
        String response = '';
        
        
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                response = httpResponse.getBody();
                return response;   
            } else if (httpResponse.getStatusCode() == 500) {
                response = 'Invalid Expression or Error';
				return response;                
            } else {    
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }   
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        }  
    }
    
    // Method for creating Dataflows/Recipes 
    public static void createDataflowsAndRecipes() {
        
        List<analyticsmap__Dataflow__c> dataflowsToInsert = new List<analyticsmap__Dataflow__c>();
        
        dataflowsToInsert.addAll(parseDataflowsAndRecipes(makeCallout('dataflows',null),'dataflows'));
        dataflowsToInsert.addAll(parseDataflowsAndRecipes(makeCallout('recipes',null),'recipes'));
        
        // upsert allows us to ensure the dataflow records are always up to date based on the dataflowId 
        // insert had some issues with duplicate values because of the dataflowId being unique
        upsert dataflowsToInsert analyticsmap__Dataflow_Id__c;
    }
    
    // Method for creating DataflowJobs
    public static void createDataflowJobs() {
        List<analyticsmap__Dataflow_Job__c> dataflowJobsToInsert = new List<analyticsmap__Dataflow_Job__c>();
        
        dataflowJobsToInsert.addAll(parseDataflowJobs(makeCallout('dataflowJobs', null),'dataflowJobs'));
        
        for(Integer i=0;i<dataflowJobsToInsert.size();i++) {
            system.debug('dataflowJobToInsert: '+dataflowJobsToInsert[i]);
        }
        
        upsert dataflowJobsToInsert analyticsmap__Dataflow_Instance_Id__c; 
        
    }
    
    // used with createDataflowsAndRecipes() to parse the dataflows/recipes response and returns the list of analyticsmap__Dataflow__c SObjects
    public static List<analyticsmap__Dataflow__c> parseDataflowsAndRecipes(String input, String type) {
        
        Map<String,Object> jsonParsed =(Map<String,Object> ) JSON.deserializeUntyped(input);
        List<analyticsmap__Dataflow__c> dataflowsToInsert = new List<analyticsmap__Dataflow__c>();
        
        if(typeList.contains(type)) {
            List<Object> entriesArray =( List<Object> ) jsonParsed.get(type);
            
            for(Object inidividualEntries : entriesArray){
                Map<String,Object> ind = (Map<String,Object> )inidividualEntries;
                analyticsmap__Dataflow__c dataflow = new analyticsmap__Dataflow__c();
                
                Id dataflowId = ind.get('id').toString();
                String label = ind.get('label').toString();
                String name = ind.get('name').toString();
                String dataflowType = ind.get('type').toString();
                String schedule;
                String nextRunDateValue;
                Datetime nextRunDate;
                
                if(ind.containsKey('scheduleAttributes')) {
                    schedule = ind.get('scheduleAttributes').toString().unescapeXml();
                    nextRunDateValue = ind.get('nextScheduledDate').toString();
                    nextRunDate = (DateTime)JSON.deserialize('"' + nextRunDateValue + '"', DateTime.class);
                } else if (ind.containsKey('schedule')) {
                    schedule = ind.get('schedule').toString();
                    nextRunDateValue = ind.get('nextScheduledDate').toString();
                    nextRunDate = (DateTime)JSON.deserialize('"' + nextRunDateValue + '"', DateTime.class);
                } else {
                    schedule = null;
                }
                
                //hardcoding dataflow schedules for demo only
                //TODO Replace with CronHelper class handling
                switch on String.valueOf(dataflowId) {
                    when '02K09000000rRqeEAE' {		// when block 1
                        schedule='0 15 4 ? * 1,3,5,6,7';
                    }	
                    when '02K09000000rRqNEAU' {		// when block 2
                        schedule='0 0 0 ? * 1,3,5,6,7,2,4';
                    }
                    when '02K09000000rRqdEAE' {		// when block 3
                        schedule='0 0 0 ? * 1,3,5,6,7,2';
                    }
                    when else {		  // default block, optional
                        // do nothing
                    }
                }
                
                // create the dataflow records of dataflows and recipes
                dataflow = new analyticsmap__Dataflow__c(
                    Name = label,
                    analyticsmap__Type__c = dataflowType,
                    analyticsmap__Dataflow_Id__c = dataflowId,
                    analyticsmap__Schedule__c = schedule,
                    analyticsmap__Next_Run_Date__c = nextRunDate
                );
                system.debug('dataflow: '+dataflow);
                dataflowsToInsert.add(dataflow);
            }
            
        }
        return dataflowsToInsert;
    }
    
    // parseDataflowJobs() takes input json string and request type and outputs DataflowJobs, 
    // no return value
    public static List<analyticsmap__Dataflow_Job__c> parseDataflowJobs(String input, String type) {
        
        List<analyticsmap__Dataflow_Job__c> dataflowJobsToInsert = new List<analyticsmap__Dataflow_Job__c>();
        Map<String,Object> jsonParsed =(Map<String,Object> ) JSON.deserializeUntyped(input);
        
        if(type == 'dataflowJobs') {
            List<Object> entriesArray =( List<Object> ) jsonParsed.get(type);
            List<analyticsmap__Dataflow__c> curDataflowsList = [SELECT Id, Name, analyticsmap__Dataflow_Id__c 
                                                                FROM analyticsmap__Dataflow__c];
            for(Object inidividualEntries : entriesArray){
                Map<String,Object> ind = (Map<String,Object> )inidividualEntries;
                analyticsmap__Dataflow_Job__c dataflowJob = new analyticsmap__Dataflow_Job__c();
                
                Id dataflowRecordId;
                String label;
                String startDateTimeValue;
                String executedDateTimeValue;
                String message;
                Datetime startDateTime;
                Datetime executedDateTime;
                Id runId = ind.get('id').toString();
                String jobType = ind.get('jobType').toString();
                
                if(ind.containsKey('label') && jobTypeList.contains(jobType)) {
                    label = ind.get('label').toString();
                    if(!curDataflowsList.isEmpty()) {
                        for(analyticsmap__Dataflow__c d : curDataflowsList){
                            
                            /* for debugging specific dataflowJobIds
                            if(runId == '03C0900000265EkEAI'){
                                system.debug('label: '+label);
                            	system.debug('d.Name: '+d.Name);
                            }
							*/
                            if(d.Name == label || d.Name+'_recipe' == label || label+' Recipe' == d.Name){
                                //system.debug('contains label');
                                //system.debug('d.Id: '+d.id);
                                dataflowRecordId = d.Id;
                                break;
                            } else {
                                //system.debug('doesn\'t contain label');
                            }
                        }
                    } else {
                        //If there aren't any dataflows, don't do anything
                        system.debug('No Dataflows Exist');
                        break;
                    }
                } else {
                    //We shoud never be here
                    label = null;
                }
                
                if(ind.containsKey('startDate')){
                    startDateTimeValue = ind.get('startDate').toString();
                    startDateTime = (DateTime)JSON.deserialize('"' + startDateTimeValue + '"', DateTime.class);
                } else {
                    startDateTime = null;
                }
                
                if(ind.containsKey('executedDate')){
                    executedDateTimeValue = ind.get('executedDate').toString();
                    executedDateTime = (DateTime)JSON.deserialize('"' + executedDateTimeValue + '"', DateTime.class);
                } else {
                    executedDateTime = null;
                }
                
                if(ind.containsKey('message')){
                    message = ind.get('message').toString();
                } else {
                    message = null;
                }          
                
                if(jobTypeList.contains(jobType)){
                    dataflowJob = new analyticsmap__Dataflow_Job__c(
                        analyticsmap__Dataflow_Instance_Id__c = runId,
                        analyticsmap__label__c = label,
                        analyticsmap__Dataflow__c = dataflowRecordId,
                        analyticsmap__Duration__c = Integer.valueOf(ind.get('duration')),
                        analyticsmap__Start_DateTime__c = startDateTime,
                        analyticsmap__Executed_DateTime__c = executedDateTime,
                        analyticsmap__Job_Type__c = jobType,
                        analyticsmap__Status__c = ind.get('status').toString(),
                        analyticsmap__message__c = message,
                        analyticsmap__Nodes_URL__c = ind.get('nodesUrl').toString(),
                        analyticsmap__Progress__c = Double.valueOf(ind.get('progress'))
                    );
                    dataflowJobsToInsert.add(dataflowJob);
                }
            }
        }
        return dataflowJobsToInsert;
    }
}