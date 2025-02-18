public with sharing class MedicalFacilitiesSyncSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new MedicalFacilitiesSync());
    }

    public static void scheduleJob() {
        String cron = '0 0 5 * * ?';
        String jobName = 'Daily Medical Facilities Update';
        System.schedule(jobName, cron, new MedicalFacilitiesSyncSchedule());
    }
}