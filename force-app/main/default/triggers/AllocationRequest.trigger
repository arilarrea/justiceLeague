trigger AllocationRequest on TeamProgress__c (before insert) {
    List <TeamProgress__c> teamProgressBadList = AllocationRequestHelper.validateTeamProgress(Trigger.new);

    if (teamProgressBadList.size()>0){
        for(TeamProgress__c teamProgressBad : teamProgressBadList){
            teamProgressBad.addError(
                'NO PUEDE ALOCAR EL RECURSO ' 
                + teamProgressBad.Name
                + ' EN LA FECHA INDICADA ' 
                + teamProgressBad.StartDateAllocated__c + ' - ' 
                + teamProgressBad.EndDateAllocated__c);
        }
   }
}