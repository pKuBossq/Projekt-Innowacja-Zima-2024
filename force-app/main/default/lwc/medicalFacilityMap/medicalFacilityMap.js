import { LightningElement, wire, api } from 'lwc';
import getMedicalFacility from '@salesforce/apex/MedicalFacilityController.getMedicalFacility';

export default class MedicalFacilityMap extends LightningElement {
    @api recordId;
    mapMarkers = [];

    get hasMarkers() {
        console.log(this.mapMarkers.length);
        return this.mapMarkers.length > 0;
    }

    @wire(getMedicalFacility, {facilityId : '$recordId'})
    wiredMap({ error, data }) {
        console.log(this.recordId);
        if(data) {
            console.log(data);
            this.mapMarkers = [
                {
                    location: {
                        Street: data.Address__Street__s,
                        City: data.Address__City__s,
                        PostalCode: data.Address__PostalCode__s
                    },
                    title: data.Name,
                    description:
                        data.Address__City__s + ', ul.' + data.Address__Street__s + '. Kod pocztowy: ' + data.Address__PostalCode__s,
                },
            ];
        }
        else if(error) {
            console.error(error);
        }
    }
}