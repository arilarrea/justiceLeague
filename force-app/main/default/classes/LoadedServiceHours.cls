public with sharing class LoadedServiceHours {
    private static final List <String> STATUS_TASK = new List<String> 
   {'In Progress','Not Started'};
   

    @AuraEnabled(cacheable=true)
    public static List <Task__c> getPendingTaskbyResourceAndProject (String userId, String projectId) {
    return [SELECT  
            Id, Name, Status__c, EstimatedHours__c,RecordHours__c, StartTaskDate__c
            //AssignedResource__r.Resource__c,
            //AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id 
            FROM Task__c 
            WHERE Status__c in : (STATUS_TASK) 
            AND AssignedResource__r.Resource__c = : userId
            AND AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id = : projectId 
            ORDER BY Status__c DESC, StartTaskDate__c ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getPendingTaskbyResourceCount(String userId) {
            //Trae un array de AggregateResult
            List<AggregateResult> ls = [
            SELECT AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Name, Count(Task__c.Id),
                   AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.id 
            FROM   Task__c
            WHERE  Status__c in : STATUS_TASK
            AND    AssignedResource__r.Resource__c = : userId 
            Group by Task__c.AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Name, Task__c.AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id
            ];

            //System.debug('Respuesta: --->'+ ls);
            return ls;
    }

    @AuraEnabled(cacheable=false)
    public static String updateTaskStatus(String taskId, String newStatus) {

        Task__c taskToUpdate = [SELECT Id, Status__c 
                                FROM Task__c 
                                WHERE Id = : taskId][0];

        taskToUpdate.Status__c = newStatus;
        update taskToUpdate;
            return 'Successfully Updated';
    }

    @AuraEnabled(cacheable=true)
    public static String addTaskRecordHours(String taskId, Integer numberHours) {

        Task__c taskToUpdate = [SELECT Id, RecordHours__c 
                                FROM Task__c 
                                WHERE Id = : taskId][0];

        taskToUpdate.RecordHours__c += numberHours;
        update taskToUpdate;

            return 'Successfully Added';
    }
}


/* 


System.debug('Esta es la lista de task' + JSON.serializePretty( tl ));



SELECT Id, Name, Status__c, EstimatedHours__c,RecordHours__c, StartTaskDate__c, AssignedResource__r.Resource__c,
AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id
FROM Task__c
WHERE Status__c in ('In Progress','Not Started')
AND AssignedResource__r.Resource__c = '0058c00000BiaBWAAZ'
AND AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id = 'a028c00000ZLAUrAAP'
ORDER BY Status__c DESC, StartTaskDate__c 



SELECT Status__c, Count(Task__c.Id) numberPendingTask
FROM Task__c
WHERE Status__c in ('In Progress','Not Started')
AND AssignedResource__r.Resource__c = '0058c00000BiaBWAAZ'
Group by Task__c.Status__c


DEVELOPER CONSOLE

METODO getPendingTaskbyResourceAndProject
List<Task__c> tl = [SELECT Id, Name, Status__c, EstimatedHours__c,RecordHours__c, 
AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id
FROM Task__c ];

__________  METODO getPendingTaskbyResourceCount  __________________________________________
 List <String> STATUS_TASK = new List<String> {'In Progress','Not Started'};
       String userId = '0058c00000BiaBWAAZ';

List<AggregateResult> ls = [SELECT AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Name, Count(Task__c.Id), AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.id FROM Task__c
            WHERE Status__c in : STATUS_TASK
            AND AssignedResource__r.Resource__c = : userId 
            Group by Task__c.AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Name, Task__c.AssignedResource__r.ProjectLineItem__r.ProjectAssigned__r.Id
            ];

System.debug('Result -> '+ ls[0].get('Name') + '  , ' + ls[0].get('expr0') + ' , '   + ls[0].get('Id'));


anonima-> 
String userId = '0058c00000BiaBWAAZ';
System.debug(LoadedServiceHours.getPendingTaskbyResourceCount(userId));

________________________________________________________________________________

__________  METODO updateTaskStatus  __________________________________________
String newStatus = 'Not Started';
String taskId = 'a038c00001fRMkVAAW';
System.debug(LoadedServiceHours.updateTaskStatus(taskId, newStatus));
*/