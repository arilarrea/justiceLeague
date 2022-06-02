public with sharing class AllocationService {

  private static final List <String> TYPE_OF_ROLES = new List<String> 
   {'Developer', 'Consultant', 'Architect', 'Project Manager'};
 
  @AuraEnabled(cacheable=true)
  public static List <ProjectLineItem__c> getRolesWhitoutAssignment (String projectId) {
    String query = 'SELECT '  
                 + 'Id, Role__c, HoursPendingToAssign__c ' 
                 + 'FROM ProjectLineItem__c ' 
                 + 'WHERE ProjectAssigned__c = : projectId '
                 + 'AND HoursPendingToAssign__c > 0 '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery); 
  }
  
  @AuraEnabled(cacheable=true)
  public static List <User> getResourcesByRole (String roleName){

    String query = 'SELECT '
                 + 'Id ,FirstName,LastName,RatePerHour__c,Role__c '
                 + 'FROM User '
                 + 'WHERE  Role__c = : roleName '
                 + 'AND Role__c IN : TYPE_OF_ROLES '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery);    
  }

  @AuraEnabled(cacheable=true)
  public static String allocationCreate(String alocationJson){

    List<TeamProgress__c> teamPList = (List<TeamProgress__c>) JSON.deserialize(alocationJson, List<TeamProgress__c>.class);
    //System.debug('lista de los teamP '+ teamPList);
    List<TeamProgress__c> teamPListWithName = addName(teamPList);
    insert teamPListWithName;

    // List <String> errorList = new List <String>();
    
    //   Database.SaveResult[] srList = Database.insert(teamPListWithName, false);
    //   for(Database.SaveResult sr :srList ){
    //     if(sr.isSuccess() == false){
    //       for(Database.Error err : sr.getErrors()) {
    //         errorList.add(err.getMessage());
    //       }
    //     }
    //   }
    //   if(errorList.size()>0){
    //     return 'Hubo errores ' + errorList;
    //   }else{
    //     return 'Se creo la alocacion con exito';
    //   }
    return 'Se creo la alocacion con exito';
  }

  private static List <TeamProgress__c> addName(List <TeamProgress__c> teamProgressList){
    List <TeamProgress__c> newTeamProgressList = new List <TeamProgress__c>();
    //recorrer la lista para traer los Resource__c
    Set <String> resourcesIdsSet = new Set <String>();
    for(TeamProgress__c teamP : teamProgressList){
    resourcesIdsSet.add(teamP.Resource__c);
    }
    //traer datos de los usuarios
    Map <Id, User> dataUserMap = new Map <Id, User>([SELECT FirstName, LastName, Role__c FROM User WHERE Id IN :resourcesIdsSet]);
    //agrega los nombres a los teamProgress
    for(TeamProgress__c teamP : teamProgressList){
      String teamName = dataUserMap.get(teamP.Resource__c).FirstName + ' - ' + dataUserMap.get(teamP.Resource__c).Role__c;
      teamP.Name = teamName;
      newTeamProgressList.add(teamP);
    }
    return newTeamProgressList;
  }
}
/********************    PRUEBAS EN VENTANA ANONIMA           ********************** 
  METODO getRolesWhitoutAssignment
  Id projectId = [SELECT Id FROM Project__c LIMIT 1][0].Id;
  system.debug(AllocationService.getRolesWhitoutAssignment(projectId));

  METODO getResourcesByRole
  system.debug(AllocationService.getResourcesByRole('Developer'));

  METODO  allocationCreate
AllocationService.allocationCreate('[{"Resource__c" : "0058a00000LWPN6AAP", "Project__c" : "a028a00001KQaM1AAL","startDateAllocated__c" : "2022-05-17","endDateAllocated__c" : "2022-05-18"}]');*/