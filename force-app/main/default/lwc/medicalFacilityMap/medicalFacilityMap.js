import { LightningElement, wire, track } from 'lwc';
import getMedicalFacilityData from '@salesforce/apex/MedicalFacilityController.getMedicalFacilityData';

export default class MedicalFacilityMap extends LightningElement {
    @track medicalFacilities = [];
    @track error;
    @track mapMarkers = [];
    @track center;

    @wire(getMedicalFacilityData)
    wiredFacilities({ error, data }) {
        if (data) {
            this.medicalFacilities = data;
            this.mapMarkers = data.map(facility => ({
                location: {
                    Street: facility.Address__Street__s,
                    City: facility.Address__City__s,
                    PostalCode: facility.Address__PostalCode__s
                },
                title: facility.Name
            }));

            if (this.mapMarkers.length > 0) {
                this.center = this.mapMarkers[0].location;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.medicalFacilities = undefined;
            this.mapMarkers = [];
        }
    }
}
