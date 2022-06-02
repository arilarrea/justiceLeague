public with sharing class AllocationRequestHelper {

    public static List <TeamProgress__c> teamProgressBadList = new List <TeamProgress__c>();

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
            for(TeamProgress__c teamP : teamProgressList){
                //validar si existe algun TeamProgress que se cruce con la fecha solicitada
                if(teamP.Resource__c == teamPR.Resource__c ){
                    validateHelper(teamP, teamPR);
                }
            }
        }
        return teamProgressBadList;
    }

    private static void validateHelper(TeamProgress__c teamP, TeamProgress__c teamPR){
          if (teamPR.StartDateAllocated__c <= teamP.StartDateAllocated__c && teamPR.EndDateAllocated__c >= teamP.StartDateAllocated__c) {
            teamProgressBadList.add(teamPR);
          } else if(teamPR.StartDateAllocated__c >= teamP.StartDateAllocated__c && teamPR.EndDateAllocated__c >= teamP.StartDateAllocated__c && teamPR.StartDateAllocated__c <= teamP.EndDateAllocated__c) {
            teamProgressBadList.add(teamPR);
          }
    }
}