public class BotField {
//Check Merge Changes
    @AuraEnabled public String name { get;set; }
    @AuraEnabled public String value { get;set; }
    @AuraEnabled public String linkURL { get;set; }
    //Commit Changes
    public BotField(String name, String value) {
        this.name = name;
        this.value = value;
    }
    //Test Comment
    public BotField(String name, String value, string linkURL) {
        this.name = name;
        this.value = value;
        this.linkURL = linkURL;
    }
//EOline
}