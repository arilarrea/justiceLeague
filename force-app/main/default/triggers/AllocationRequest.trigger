trigger AllocationRequest on TeamProgress__c (before insert) {
    List <TeamProgress__c> teamProgressBadList = AllocationRequestHelper.validateTeamProgress(Trigger.new);

    if (teamProgressBadList.size()>0){
        for(TeamProgress__c teamProgressBad : teamProgressBadList){
            teamProgressBad.addError(
                'You Can not Allocate the resource ' 
                + teamProgressBad.Name
                + ' on the indicated date ' 
                + teamProgressBad.StartDateAllocated__c + ' - ' 
                + teamProgressBad.EndDateAllocated__c);
        }
   }
}