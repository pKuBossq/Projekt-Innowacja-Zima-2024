import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import OPENING_HOURS_FIELD from '@salesforce/schema/Medical_Facility__c.Opening_Hours__c';

export default class MedicalFacilityOpeningHours extends LightningElement {
    @api recordId;
    parsedHours;

    @wire(getRecord, { recordId: '$recordId', fields: [OPENING_HOURS_FIELD] })
    wiredMedicalFacility({ error, data }) {
        if (data) {
            const openingHours = getFieldValue(data, OPENING_HOURS_FIELD);
            if (openingHours) {
                this.parseOpeningHours(openingHours);
            }
        } else if (error) {
            console.error('Error loading opening hours:', error);
        }
    }

    parseOpeningHours(hoursString) {
        if (!hoursString) return;
        const lines = hoursString.split('\n');
        this.parsedHours = lines.map(line => {
            const [name, hoursWithQuotes] = line.split(/:(.*)/s);
            const hours = hoursWithQuotes.replace(/"/g, '').trim();
            return {
                name: name.trim(),
                hours: hours
            };
        });
    }
}