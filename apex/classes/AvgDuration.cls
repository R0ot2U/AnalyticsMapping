public class AvgDuration {
    public static void avgDuration (){
        
        Set<Id> dataflowIds = new Set<Id>();
        List<analyticsmap__Dataflow__c> dataflowToUpdate = new List<analyticsmap__Dataflow__c>();
        List<analyticsmap__Dataflow_Job__c> dataflowJobs = Trigger.isInsert || Trigger.isUpdate ? Trigger.New : Trigger.Old;
        for(analyticsmap__Dataflow_Job__c dj : dataflowJobs){
            dataflowIds.add(dj.analyticsmap__Dataflow__c);
        }
        
        for(AggregateResult ag : [SELECT analyticsmap__Dataflow__c, AVG(analyticsmap__Duration__c) avg FROM 
                                  analyticsmap__Dataflow_Job__c GROUP BY analyticsmap__Dataflow__c]){
            dataflowToUpdate.add(new analyticsmap__Dataflow__c(
                Id = (Id)ag.get('analyticsmap__Dataflow__c'),
                analyticsmap__Average_Duration_Minutes__c = ((Decimal)ag.get('avg') / 60)
            ));
        }
        
        if(dataflowToUpdate.size() > 0){
            
            for(Integer i=0;i<dataflowToUpdate.size();i++) {  
                
                //hardcoding dataflow schedules for demo only
                //TODO remove as this shouldn't be needed in a real life scenario
                system.debug('dataflowToUpdate[i].Id: '+dataflowToUpdate[i].Id);
                switch on String.valueOf(dataflowToUpdate[i].Id) {
                    when 'a0309000001c2SGAAY' {		// when block 1
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 900;
                    }	
                    when 'a0309000001c2SEAAY' {		// when block 2
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 650;
                    }
                    when 'a0309000001c2SFAAY' {		// when block 3
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 450;
                    }
                    when 'a0309000001cfOoAAI' {		// when block 3
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 500;
                    }
                    when 'a0309000001c2SIAAY' {		// when block 3
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 310;
                    }
                    when 'a0309000001c2SHAAY' {		// when block 3
                        dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 190;
                    }
                    when else {		  // default block, optional
                        // do nothing
                        // fixing for null values
                        if(dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c == null){
                            dataflowToUpdate[i].analyticsmap__Average_Duration_Minutes__c = 0;
                        }
                    }
                }
            }
            
            update dataflowToUpdate;
        }
    }
}
