public with sharing class AllocationService {

  private static final List <String> TYPE_OF_ROLES = new List<String> 
   {'Developer', 'Consultant', 'Architect', 'Project Manager'};
 
  @AuraEnabled(cacheable=true)
  public static List <ProjectLineItem__c> getRolesWhitoutAssignment (String projectId) {
    String query = 'SELECT '  
                 + 'Id, Role__c, HoursPendingToAssign__c, QuantityHours__c, QuantityHoursAllocated__c ' 
                 + 'FROM ProjectLineItem__c ' 
                 + 'WHERE ProjectAssigned__c = : projectId '
                 + 'AND HoursPendingToAssign__c > 0 '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery); 
  }

  @AuraEnabled(cacheable=true)
  public static List <ProjectLineItem__c> getTeamProgressesByProject (String projectId) {
    String query = 'SELECT '  
                 + 'Resource__r.Fullname__c, ' 
                 + 'Resource__r.Role__c, '
                 + 'QuantityHoursAllocated__c '
                 + 'FROM teamProgress__c ' 
                 + 'WHERE ProjectLineItem__r.ProjectAssigned__c = : projectId '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery); 
  }

  @AuraEnabled(cacheable=true)
  public static List <ProjectLineItem__c> getHoursPendingToAssignByRole (String projectId, String RoleName) {
    String query = 'SELECT '  
                 + 'HoursPendingToAssign__c ' 
                 + 'FROM ProjectLineItem__c ' 
                 + 'WHERE ProjectAssigned__c = : projectId '
                 + 'AND HoursPendingToAssign__c > 0 '
                 + 'AND Role__c = : RoleName '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery); 
  }
  
  @AuraEnabled(cacheable=true)
  public static List <User> getResourcesByRole (String roleName){

    String query = 'SELECT '
                 + 'Id ,FirstName,LastName,RatePerHour__c,Role__c,FullName__c '
                 + 'FROM User '
                 + 'WHERE  Role__c = : roleName '
                 + 'AND Role__c IN : TYPE_OF_ROLES '
                 + 'WITH SECURITY_ENFORCED ';
    String finalQuery = String.escapeSingleQuotes(query);             
    return Database.query(finalQuery);    
  }

  @AuraEnabled
  public static String allocationCreate(String alocationJson, String projectID){

    List<TeamProgress__c> teamPList = (List<TeamProgress__c>) JSON.deserialize(alocationJson, List<TeamProgress__c>.class);
    System.debug('Que recibe ??   lista-> '+ teamPList + '   project id -->' + projectID);
    List<TeamProgress__c> teamPListWithName = addName(teamPList);
    List<TeamProgress__c> teamPListWithPLI = addProjectLI(teamPListWithName,projectID);
    System.debug('Esta es la lista de teamProgress completos' +  teamPListWithPLI);

    insert teamPListWithPLI;

    return 'Se creo la alocacion con exito';
  }
  
  private static List <TeamProgress__c> addProjectLI(List <TeamProgress__c> teamProgressList, String projectID){
    //1. Tenemos una lista de teamP sin su respectivo PLI  OK----
    List <TeamProgress__c> newTeamProgressList = new List <TeamProgress__c>();
    //2. Necesitamos traer el id del project  OK ---
    System.debug('Este es el id del project DESDE EL METODO ADD: '+ projectID);
    //3. Necesitamos traer la lista de los PLI asociados a ese proyecto
    Map <String,ProjectLineItem__c> roleNamePLIAndPLIObject= new Map<String, ProjectLineItem__c>();
    //llenar el mapa
    List<ProjectLineItem__c> pliList = [SELECT Id, Role__c FROM ProjectLineItem__c WHERE ProjectAssigned__c =: projectID];
    for(ProjectLineItem__c pli : pliList){
      roleNamePLIAndPLIObject.put(pli.Role__c, pli);
    }
    //4. Necesitamos traer el role por resource del TeamProgress
    Set <String> resourcesIdsSet = new Set <String>();
    for(TeamProgress__c teamP : teamProgressList){
    resourcesIdsSet.add(teamP.Resource__c);
    }
    //traer datos de los usuarios
    Map <Id, User> dataUserMap = new Map <Id, User>([SELECT FirstName, LastName, Role__c FROM User WHERE Id IN :resourcesIdsSet]);
    //. Necesitamos agregar el PLI a cada TeamP
    for(TeamProgress__c teamP : teamProgressList){
      //nos traermos el nombre del rol del current teapP
      String userRoleName = dataUserMap.get(teamP.Resource__c).Role__c;
      String pliID = roleNamePLIAndPLIObject.get(userRoleName).Id;
      teamP.ProjectLineItem__c = pliID;
      //String teamName = dataUserMap.get(teamP.Resource__c).FirstName + ' - ' + dataUserMap.get(teamP.Resource__c).Role__c;
      //teamP.Name = teamName;
      newTeamProgressList.add(teamP);
    }
    return newTeamProgressList;
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
AllocationService.allocationCreate('[{"Resource__c" : "0058a00000LWPN6AAP", "Project__c" : "a028a00001KQaM1AAL","startDateAllocated__c" : "2022-05-17","endDateAllocated__c" : "2022-05-18"}]');

*/