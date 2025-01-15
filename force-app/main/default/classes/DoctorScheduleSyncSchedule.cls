public with sharing class DoctorScheduleSyncSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new DoctorScheduleSync());
    }

    public static void scheduleJob() {
        String cron = '0 0 5 * * ?';
        String jobName = 'Daily Doctor Schedule Update';
        System.schedule(jobName, cron, new DoctorScheduleSyncSchedule());
    }
}