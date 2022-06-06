public with sharing class AllocationRequestHelper {

    public static List <TeamProgress__c> teamProgressBadList = new List <TeamProgress__c>();
    public static List <TeamProgress__c> teamProgressApproved = new List <TeamProgress__c>();

    public static List <TeamProgress__c> validateTeamProgress (List <TeamProgress__c> TeamProRequestedList ){

        // recorrer el alocationList y llenar el set de ids
        Set <String> resourcesIdsSet = new Set <String>();
        for(TeamProgress__c teamP : TeamProRequestedList){
        resourcesIdsSet.add(teamP.Resource__c);
        }

        //Se traen todos los TeamProgress de los usuarios
        List<TeamProgress__c> teamProgressList = [SELECT  Resource__c, StartDateAllocated__c, EndDateAllocated__c, Project__c FROM  TeamProgress__c WHERE Resource__c IN  :resourcesIdsSet];

        //recorrer Lista de TeamProRequestedList (todos los usuarios y fechas que se solicita alocar)
        for(TeamProgress__c teamPR :TeamProRequestedList){
            //recorrer el TeamProgress (Todos los teamProgress existentes en relacion a los ids de usuario)
            Integer repetidos =0;
            for(TeamProgress__c teamP : teamProgressList){
                //validar si existe algun TeamProgress que se cruce con la fecha solicitada
                if(teamP.Resource__c == teamPR.Resource__c ){
                  Boolean approved = validateHelper(teamP, teamPR);
                   if(approved == false){repetidos += 1;}
                }
            }
            if(repetidos <= 0){
                //si no hay teamP que se crucen que se agregue a la lista de aprovados
                teamProgressApproved.add(teamPR);
            }
        }

        if(teamProgressApproved.size() >0){
            //updateProjectLI(teamProgressApproved);
        }
        
        return teamProgressBadList;
    }

    private static Boolean validateHelper(TeamProgress__c teamP, TeamProgress__c teamPR){
        Boolean response = true;
          if (teamPR.StartDateAllocated__c <= teamP.StartDateAllocated__c && teamPR.EndDateAllocated__c >= teamP.StartDateAllocated__c) {
            teamProgressBadList.add(teamPR);
            response = false;
          } else if(teamPR.StartDateAllocated__c >= teamP.StartDateAllocated__c && teamPR.EndDateAllocated__c >= teamP.StartDateAllocated__c && teamPR.StartDateAllocated__c <= teamP.EndDateAllocated__c) {
            teamProgressBadList.add(teamPR);
            response = false;
          }
          return response;
    }

    private static void updateProjectLI(List<TeamProgress__c> teamProgressApproved){
        // recorrer el teamProgressApproved y llenar el set de ids
        Set <String> resourcesIdsSet = new Set <String>();
        for(TeamProgress__c teamP : teamProgressApproved){
        resourcesIdsSet.add(teamP.Resource__c);
        }
        //Se traen todos los roles de los usuarios
        Map <Id, User> userIdAndRoleMap = New Map<Id,User>([SELECT  Role__c FROM  User WHERE Id IN  :resourcesIdsSet]);
        //System.debug('El mapa userIdAndRoleMap esta asi: ->'+ userIdAndRoleMap );

        id projectId = teamProgressApproved[0].Project__c;
        Map <String, ProjectLineItem__c> roleAndPliMap = new Map <String, ProjectLineItem__c>();
        
        //llenar mapa de roleAndPliMap
        List <ProjectLineItem__c> currentPLIList = [SELECT Role__c, QuantityHoursAllocated__c FROM ProjectLineItem__c WHERE ProjectAssigned__c = : projectId];
        for ( ProjectLineItem__c currentPLI : currentPLIList ){
            roleAndPliMap.put(currentPLI.Role__c, currentPLI);
        }
        System.debug('El mapa roleAndPliMap esta asi: ->'+ roleAndPliMap );

        Map <String, TeamProgress__c> userRoleNameAndTeamP = new Map <String, TeamProgress__c>();


        //agregar las horas calculadas a los team y al mapa
        for(TeamProgress__c teamPA : teamProgressApproved){
            String Role = userIdAndRoleMap.get(teamPA.Resource__c).Role__c;

            teamPA.QuantityHoursAllocated__c= calculateWorkingDays(teamPA.StartDateAllocated__c, teamPA.EndDateAllocated__c);
            userRoleNameAndTeamP.put((userIdAndRoleMap.get(teamPA.Resource__c).Role__c),teamPA );
            // pliRoleAndPLIAllocatedHours.put(Role, roleAndPliMap.get(Role).QuantityHoursAllocated__c);

        //     String Role = userIdAndRoleMap.get(teamPA.Resource__c).Role__c;
        //     System.debug('String Role es -> '+ Role );
        //     Decimal currentHoursAllocatedPLI = roleAndPliMap.get(Role).QuantityHoursAllocated__c;
        //    System.debug('currentHoursAllocatedPLI es -> '+ currentHoursAllocatedPLI );  
        }
        System.debug('El mapa userRoleNameAndTeamP esta asi: ->'+ userRoleNameAndTeamP );
        System.debug('El mapa roleAndPliMap esta asi: ->'+ roleAndPliMap );

        Decimal hoursDeveloper=0,hoursArchitect =0, hoursConsultor =0, hoursProjectManager =0;

        //recorrer mapa userRoleNameAndTeamP y sumar por rol
        for(String roleName : userRoleNameAndTeamP.keySet() ){
            if(roleName == 'Developer'){
                System.debug('es developer');
                hoursDeveloper += userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c;
            }
            if(roleName == 'Architect'){
                
                hoursArchitect+=userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c;
                System.debug('es architect CON HORAS ->' +hoursArchitect + ' y '+ userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c );
            }
            if(roleName == 'ProjectManager'){
                System.debug('es pm');
                hoursProjectManager+=userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c;

            }
            if(roleName == 'Consultor'){
                System.debug('es consultor');
                hoursConsultor+=userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c;
            }
            System.debug( 'Prueba '+userRoleNameAndTeamP.get(roleName).QuantityHoursAllocated__c);
        }

        List<ProjectLineItem__c> pliForUpdate = new List <ProjectLineItem__c>();
        for(String roleName : roleAndPliMap.keySet() ){
            ProjectLineItem__c newPL = new ProjectLineItem__c();
            if(roleName == 'Developer'){
                newPL = roleAndPliMap.get(roleName);
                System.debug('newPL  '+ newPL);
                //System.debug('newPL.QuantityHoursAllocated__c  '+ newPL.QuantityHoursAllocated__c);
                //newPL.QuantityHoursAllocated__c += hoursArchitect;
                System.debug('hoursArchitect  '+ hoursArchitect);
                System.debug('newPL.QuantityHoursAllocated__c  '+ newPL.QuantityHoursAllocated__c);
                
            }
            // else if(roleName == 'Developer'){
            //     newPL =roleAndPliMap.get(roleName);
            //     newPL.QuantityHoursAllocated__c += hoursDeveloper;
            // }
            // else if(roleName == 'ProjectManager'){
            //     newPL =roleAndPliMap.get(roleName);
            //     newPL.QuantityHoursAllocated__c += hoursProjectManager;
            // }
            // else if(roleName == 'Consultor'){
            //     newPL =roleAndPliMap.get(roleName);
            //     newPL.QuantityHoursAllocated__c += hoursConsultor;
            // }
            pliForUpdate.add(newPL);
        }

        System.debug('Los nuevos seran ' +pliForUpdate);

    }

    public static Integer calculateWorkingDays(Date startDate, Date endDate){          
         
        Integer workingDays = 0;  
         
        for(integer i=0; i <= startDate.daysBetween(endDate); i++){  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday'){  
                workingDays = workingDays + 1;  
            }     
        }  
              
        System.debug('--Working days'+workingDays);  
        return workingDays;  
    }  
}