public with sharing class AlocationService {

  Class AlocationWrapper{ //clase plantilla de la informacion de la alocacion
    Date startDateAllocated;
    Date endDateAllocated;
    String userId;
    Boolean validation;
  }

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
  public static List <User> getResourcesByRol (String roleName){

    String query = 'SELECT '
                 + 'Id ,FirstName,LastName,RatePerHour__c,Role__c '
                 + 'FROM User '
                 + 'WHERE  Role__c = : roleName '
                 + 'AND Role__c IN : TYPE_OF_ROLES '
                 + 'AND isActive = True '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery);    
  }

  public static String allocationCreateByUser(String userId, String projectId, Date startDateR, Date endDateR){
    Boolean validationUser = validateAvailabilityByUser (userId, startDateR, endDateR);
    if(validationUser != true){
      return 'El recurso no esta disponible en las fechas solicitadas';
    }

    User resourceData = [SELECT FirstName, LastName, Role__c FROM User WHERE id = :userId][0];
    String teamName = resourceData.FirstName + ' ' + resourceData.LastName + ' - ' + resourceData.Role__c;
    // creamos un objeto tipo TeamProgress__c
    TeamProgress__c newTeamP = new TeamProgress__c(
                                Name = teamName,
                                Resource__c = userId,
                                Project__c = projectId,
                                StartDateAllocated__c = startDateR,
                                EndDateAllocated__c = endDateR
    );

    insert newTeamP;
    return 'Se creo la alocacion con exito';
  }

  @AuraEnabled(cacheable=true)
  public static Boolean validateAvailabilityByUser (String userId, Date startDateR, Date endDateR) {

    Boolean response = true;

    String query = 'SELECT '
                 + 'StartDateAllocated__c, EndDateAllocated__c, Project__c '
                 + 'FROM  TeamProgress__c  '
                 + 'WHERE Resource__c = : userId '
                 + 'WITH SECURITY_ENFORCED ';

    String finalQuery = String.escapeSingleQuotes(query);             

    List<TeamProgress__c> teamProgressList = Database.query(finalQuery);
    
    for (TeamProgress__c teamP : teamProgressList) {
      if (startDateR < teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c) {
        return response = false;
      } else if(startDateR > teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c && startDateR < teamP.EndDateAllocated__c) {
        return response = false;
      }
    }
    return response;

  }

  @AuraEnabled(cacheable=true)
  public static List <AlocationWrapper> validateAvailabilityByRole (String alocationJson) {
    List<AlocationWrapper> alocationList = (List<AlocationWrapper>) JSON.deserialize(alocationJson, List<AlocationWrapper>.class);
    
    // recorrer el alocationList y llenar el set de ids
    Set <String> resourcesIdsSet = new Set <String>();
    for(AlocationWrapper al :alocationList){
      resourcesIdsSet.add(al.userId);
    }

    //Se traen todos los TeamProgress de los usuarios
    List<TeamProgress__c> teamProgressList = [SELECT  Resource__c, StartDateAllocated__c, EndDateAllocated__c, Project__c FROM  TeamProgress__c WHERE Resource__c IN  :resourcesIdsSet];

    //recorrer Lista de AlocationWrapper (todos los usuarios y fechas que se solicita alocar)
    for(AlocationWrapper alocationWrapper :alocationList){
      //recorrer el TeamProgress (Todos los teamProgress existentes en relacion a los ids de usuario en el AlocationWrapper)
      for(TeamProgress__c tp : teamProgressList){
        //validar si existe algun TeamProgress que se cruce con la fecha solicitada
        if(String.valueOf(tp.Resource__c) == alocationWrapper.userId ){
          alocationWrapper.validation = validateHelper(tp, alocationWrapper.startDateAllocated, alocationWrapper.endDateAllocated);
        }
      }
    }
    return alocationList;
  }

  private static Boolean validateHelper(TeamProgress__c teamP, Date startDateR, Date endDateR){
    Boolean response = true;
      if (startDateR < teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c) {
        return response = false;
      } else if(startDateR > teamP.StartDateAllocated__c && endDateR > teamP.StartDateAllocated__c && startDateR < teamP.EndDateAllocated__c) {
        return response = false;
      }
    return response;
  }
}

/********************    PRUEBAS EN VENTANA ANONIMA           ********************** 

METODO getRolesWhitoutAssignment
   Id projectId = [SELECT Id FROM Project__c LIMIT 1][0].Id;
  system.debug(AlocationService.getRolesWhitoutAssignment(projectId));

METODO getResourcesByRol
system.debug(AlocationService.getResourcesByRol('Developer'));

METODO  validateAvailabilityByUser
  id userId = [SELECT id FROM User WHERE FirstName = 'Coqui'][0].id;
  String stringedId = String.valueOf(userId);
  Date startDateReq = Date.newInstance(2022,05,13);
  Date endDateReq = Date.newInstance(2022,05,15);
  system.debug(AlocationService.validateAvailabilityByUser(stringedId, startDateReq, endDateReq));

  METODO JSON validateAvailabilityByUser
  String recordTestJson = '[{"startDateAllocated" : "2022-06-02","endDateAllocated" : "2022-06-06","userId" : "0058a00000LWPN6AAP"}, {"startDateAllocated" : "2022-06-10","endDateAllocated" : "2022-06-12","userId" : "0058a00000LWPN6AAP"}]';
  system.debug(AlocationService.validateAvailabilityByRole(recordTestJson));
*/