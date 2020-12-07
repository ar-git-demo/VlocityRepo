<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>HealthCloudGA__goal_progress</fullName>
        <field>HealthCloudGA__Progress__c</field>
        <formula>0</formula>
        <name>goal progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>HealthCloudGA__progress update</fullName>
        <actions>
            <name>HealthCloudGA__goal_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HealthCloudGA__CarePlanGoal__c.HealthCloudGA__Progress__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>