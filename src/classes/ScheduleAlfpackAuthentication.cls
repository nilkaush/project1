global class ScheduleAlfpackAuthentication implements Schedulable {
   global void execute(SchedulableContext SC) {
      database.executeBatch(new AlfaPackAuthentication_Batch());   
   }
}