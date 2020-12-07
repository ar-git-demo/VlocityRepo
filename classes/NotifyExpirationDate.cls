/**
 * This class is used by the Salesforce scheduler to generate an email notification to admin users
 * when an org is close to expiring.  The frequency of the emails is determined by the scheduled job
 * in Salesforce.
 
 * @author  Duane Nelson (dnelson@vlocity.com)/Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 
 
 * History
 * -------
 * 06-18-2019 - Initial Version
 
 */
global class NotifyExpirationDate implements Schedulable {
    
    static final Integer NOTIFICATION_THRESHOLD = 14;  // notify if org is within 14 days of expiration
    
    /**
     * This method is called by the Salesforce scheduler
     * 
     * @param sc  The schedulable context information (ignored currently)
     */
    global void execute(SchedulableContext sc) {
        
        RunNotify rn = new RunNotify();
        rn.notify();
    }
   
    /**
     * Inner class to handle notifications     
     */
    global class RunNotify {
    
        /**
         * Determines if the org is about to expire and generates an email notification
         * 
         */
        public void notify() {
            
            // get the org expiry date and determine if we are close to expiry
            Organization orglookup = [SELECT TrialExpirationDate, Name, Id FROM Organization];
            Integer daysLeft = Math.abs(orglookup.TrialExpirationDate.date().daysBetween(Date.Today()));

            // If we are close to expiry, generate the email notification
            if (daysLeft <= NOTIFICATION_THRESHOLD) {
            
                // Assemble the email addresses
                List<String> toAddresses = new List<String>();
                for (User AdminUsersWithEmailNotifications : [SELECT Email FROM User WHERE isActive=true AND ReceivesAdminInfoEmails=true]) {
                    
                    String emailAddress = AdminUsersWithEmailNotifications.Email; 
                    if (!toAddresses.contains(emailAddress)) toAddresses.add(emailAddress);
                }
                
                // Build the email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject('Environment Expiration Warning');
                mail.setPlainTextBody('Hi there. Your demo environment @ ' + orglookup.Name + ' (Id:' + orglookup.Id + ', Domain:' + URL.getSalesforceBaseUrl().getHost() + ') is set to expire in ' + daysLeft + ' days. If you wish to extend it, you can create a case of type \'trialorg extension\' at partner.salesforce.com, or contact your Vlocity demo team for assistance.');

                // Send the Email and Check results
                System.debug('Sending email to ' + toAddresses);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                for (Messaging.SendEmailResult res : results) {

                    if (res.isSuccess()) System.debug('Email sent successfully');
                    else System.debug('The following errors occurred : ' + res.getErrors());
                }
            }
            
            else System.debug('Demo Environment Expires in ' + daysLeft + ' days.');
        }
    }
}