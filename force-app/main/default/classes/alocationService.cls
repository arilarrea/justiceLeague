public class alocationService {

   private static final List <String> typeOfRoles = new List<String> 
   {'Developer', 'Consultant', 'Architect', 'Project Manager'};



  public static List <ProjectLineItem__c> getRolesWhitoutAssignment (String projectId) {

    return [SELECT Id,
     Role__c,
     HoursPendingToAssign__c 
     FROM ProjectLineItem__c 
     WHERE ProjectAssigned__c = : projectId 
     AND HoursPendingToAssign__c > 0 ];

  }
  
  public static List <User> getResourcesByRol (String roleName){

    return [
    SELECT Id,
    FirstName,
    LastName,
    RatePerHour__c,
    Role__c FROM User
    WHERE  Role__c = : roleName
    AND Role__c IN : typeOfRoles
    AND isActive = True
    ];
  
  }

public static Boolean validateAvailabilityByUser (String userId, Date startDateR, Date endDateR) {

  Boolean response = true;

  List<TeamProgress__c> TeamProgressList = [
    SELECT StartDateAllocated__c, EndDateAllocated__c, Project__c
    FROM TeamProgress__c  
    WHERE Resource__c = : userId
  ];
  
  for (TeamProgress__c teamP : TeamProgressList) {
    
      if (startDateR < teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c) {
      return response = false;
    } else if(startDateR > teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c && startDateR < teamP.EndDateAllocated__c) {
      
    return response = false;
    }
    }


 // System.debug(TeamProgressList);

  return response;

}

}


   /*
   Id projectId = [SELECT Id FROM Project__c LIMIT 1][0].Id;
   
system.debug(alocationService.getRolesWhitoutAssignment(projectId));
   */

