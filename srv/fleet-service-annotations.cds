using FleetService from './fleet-service';

annotate FleetService.Vehicles with @(
    UI.HeaderInfo                : {
        TypeName      : 'Vehicle',
        TypeNamePlural: 'Vehicles',
        Title         : {Value: vehicleNumber},
        Description   : {Value: vehicleType}
    },
    UI.SelectionFields           : [
        vehicleNumber,
        vehicleType,
        status,
        fuelType,
        currentLocation,
        active
    ],
    UI.LineItem                  : [
        {
            Value: vehicleNumber,
            Label: 'Vehicle Number'
        },
        {
            Value: vehicleType,
            Label: 'Vehicle Type'
        },
        {
            Value      : status,
            Label      : 'Status',
            Criticality: statusCriticality
        },
        {
            Value: fuelType,
            Label: 'Fuel Type'
        },
        {
            Value: currentLocation,
            Label: 'Current Location'
        },
        {
            Value: active,
            Label: 'Active'
        },
        {
            Value: capacity,
            Label: 'Capacity'
        },
        {
            Value: capacityUOM,
            Label: 'Capacity Unit'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.changeStatus',
            Label : 'Change Status'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.assignDriver',
            Label : 'Assign Driver'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.unassignDriver',
            Label : 'Unassign Driver'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.deactivate',
            Label : 'Deactivate'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.reactivate',
            Label : 'Reactivate'
        }
    ],
    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Vehicle Details',
            Target: '@UI.FieldGroup#VehicleDetails'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Insurance',
            Target: '@UI.FieldGroup#Insurance'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Fitness Certificate',
            Target: '@UI.FieldGroup#Fitness'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Permit',
            Target: '@UI.FieldGroup#Permit'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Driver Assignments',
            Target: 'assignments/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Documents',
            Target: 'documents/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Maintenance Records',
            Target: 'maintenanceRecords/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Status History',
            Target: 'statusHistory/@UI.LineItem'
        }
    ],
    UI.FieldGroup #VehicleDetails: {Data: [
        {Value: vehicleNumber},
        {Value: vehicleType},
        {Value: manufacturer},
        {Value: model},
        {Value: manufacturingYear},
        {Value: registrationDate},
        {Value: capacity},
        {Value: capacityUOM},
        {Value: fuelType},
        {Value: currentLocation},
        {Value: active},
        {Value: status}
    ]},
    UI.FieldGroup #Insurance     : {Data: [
        {Value: insuranceNumber},
        {Value: insuranceProvider},
        {Value: insuranceStartDate},
        {Value: insuranceExpiry}
    ]},
    UI.FieldGroup #Fitness       : {Data: [
        {Value: fitnessCertificateNo},
        {Value: fitnessIssueDate},
        {Value: fitnessExpiry}
    ]},
    UI.FieldGroup #Permit        : {Data: [
        {Value: permitNumber},
        {Value: permitIssueDate},
        {Value: permitExpiry}
    ]}


    UI.FieldGroup #VehicleDetails: {
        Data:[{
            $Type:'UI.DataField', Value : vehicleNumber, Label : 'Vehicle Number'
        }
        ,{
            $Type:'UI.DataField', Value : vehicleType, Label : 'Vehicle Type'
        },{
            $Type : 'UI.DataField', Value : manufacturer, Label : 'Manufacturer'
        }, {
            $Type : 'UI.DataField', Value : model, Label : 'Model'
        }, {
            $Type : 'UI.DataField', Value : manufacturingYear, Label : 'Manufacturing Year'
        }, {
            $Type : 'UI.DataField', Value : registrationDate, Label : 'Registration Date'
        }, {
            $Type : 'UI.DataField', Value : capacity, Label : 'Capacity'
        }, {
            $Type : 'UI.DataField', Value : capacityUOM, Label : 'Capacity Unit'
        }, {
            $Type : 'UI.DataField', Value : fuelType, Label : 'Fuel Type'
        }, {
            $Type : 'UI.DataField', Value : currentLocation, Label : 'Current Location'
        }, {
            $Type : 'UI.DataField', Value : active, Label : 'Active'
        }, {
            $Type : 'UI.DataField', Value : status, Label : 'Vehicle Status'
        }]
    }, UI.FieldGroup #Insurance : {
        Data : [{
            $Type : 'UI.DataField', Value : insuranceNumber, Label : 'Insurance Number'
        }, {
            $Type : 'UI.DataField', Value : insuranceProvider, Label : 'Insurance Provider'
        }, {
            $Type : 'UI.DataField', Value : insuranceStartDate, Label : 'Insurance Start Date'
        }, {
            $Type : 'UI.DataField', Value : insuranceExpiry, Label : 'Insurance Expiry Date'
        }]
    }, UI.FieldGroup #Fitness : {
        Data : [{
            $Type : 'UI.DataField', Value : fitnessCertificateNo, Label : 'Fitness Certificate Number'
        }, {
            $Type : 'UI.DataField', Value : fitnessIssueDate, Label : 'Fitness Issue Date'
        }, {
            $Type : 'UI.DataField', Value : fitnessExpiry, Label : 'Fitness Expiry Date'
        }]
    }, UI.FieldGroup #Permit : {
        Data : [{
            $Type : 'UI.DataField', Value : permitNumber, Label : 'Permit Number'
        }, {
            $Type : 'UI.DataField', Value : permitIssueDate, Label : 'Permit Issue Date'
        }, {
            $Type : 'UI.DataField', Value : permitExpiry, Label : 'Permit Expiry Date'
        }]
    });



UI.FieldGroup #Insurance : {
Data : [{
    $Type : 'UI.DataField', Value : insuranceNumber, Label : 'Insurance Number'
}, {
    $Type : 'UI.DataField', Value : insuranceProvider, Label : 'Insurance Provider'
}, {
    $Type : 'UI.DataField', Value : insuranceStartDate, Label : 'Insurance Start Date'
}, {
    $Type : 'UI.DataField', Value : insuranceExpiry, Label : 'Insurance Expiry Date'
}]
},

UI.FieldGroup #Fitness : {
Data : [{
    $Type : 'UI.DataField', Value : fitnessCertificateNo, Label : 'Fitness Certificate Number'
}, {
    $Type : 'UI.DataField', Value : fitnessIssueDate, Label : 'Fitness Issue Date'
}, {
    $Type : 'UI.DataField', Value : fitnessExpiry, Label : 'Fitness Expiry Date'
}]
},

UI.FieldGroup #Permit : {
Data : [{
    $Type : 'UI.DataField', Value : permitNumber, Label : 'Permit Number'
}, {
    $Type : 'UI.DataField', Value : permitIssueDate, Label : 'Permit Issue Date'
}, {
    $Type : 'UI.DataField', Value : permitExpiry, Label : 'Permit Expiry Date'
}]
});


// { $Type: 'UI.DataField', Value: vehicleNumber, Label: 'Vehicle Number' },
// { $Type: 'UI.DataField', Value: vehicleType, Label: 'Vehicle Type' },
// { $Type: 'UI.DataField', Value: registrationDate, Label: 'Registration Date' },
// { $Type: 'UI.DataField', Value: manufacturer, Label: 'Manufacturer' },
// { $Type: 'UI.DataField', Value: model, Label: 'Model' },
// { $Type: 'UI.DataField', Value: manufacturingYear, Label: 'Manufacturing Year' },
// { $Type: 'UI.DataField', Value: capacity, Label: 'Capacity' },
// { $Type: 'UI.DataField', Value: capacityUOM, Label: 'Capacity Unit' },
// { $Type: 'UI.DataField', Value: fuelType, Label: 'Fuel Type' },
// { $Type: 'UI.DataField', Value: currentLocation, Label: 'Current Location' },
// { $Type: 'UI.DataField', Value: active, Label: 'Active' },
// { $Type: 'UI.DataField', Value: status, Label: 'Vehicle Status' },
// { $Type: 'UI.DataField', Value: insuranceNumber, Label: 'Insurance Number' },
// { $Type: 'UI.DataField', Value: insuranceProvider, Label: 'Insurance Provider' },
// { $Type: 'UI.DataField', Value: insuranceStartDate, Label: 'Insurance Start Date' },
// { $Type: 'UI.DataField', Value: insuranceExpiry, Label: 'Insurance Expiry Date' },
// { $Type: 'UI.DataField', Value: fitnessCertificateNo, Label: 'Fitness Certificate Number' },
// { $Type: 'UI.DataField', Value: fitnessIssueDate, Label: 'Fitness Issue Date' },
// { $Type: 'UI.DataField', Value: fitnessExpiry, Label: 'Fitness Expiry Date' },
// { $Type: 'UI.DataField', Value: permitNumber, Label: 'Permit Number' },
// { $Type: 'UI.DataField', Value: permitIssueDate, Label: 'Permit Issue Date' },
// { $Type: 'UI.DataField', Value: permitExpiry, Label: 'Permit Expiry Date' },
// { $Type: 'UI.DataField', Value: currentDriver_ID, Label: 'Current Driver' }


// { $Type: 'UI.DataField', Value: driverNumber, Label: 'Driver Number' },
// { $Type: 'UI.DataField', Value: driverName, Label: 'Driver Name' },
// { $Type: 'UI.DataField', Value: phone, Label: 'Phone Number' },
// { $Type: 'UI.DataField', Value: email, Label: 'Email Address' },
// { $Type: 'UI.DataField', Value: licenseNumber, Label: 'Driving Licence Number' },
// { $Type: 'UI.DataField', Value: licenseIssueDate, Label: 'Licence Issue Date' },
// { $Type: 'UI.DataField', Value: licenseExpiry, Label: 'Licence Expiry Date' },
// { $Type: 'UI.DataField', Value: status, Label: 'Driver Status' },
// { $Type: 'UI.DataField', Value: address, Label: 'Address' }


// { $Type: 'UI.DataField', Value: assignmentNumber, Label: 'Assignment Number' },
// { $Type: 'UI.DataField', Value: vehicle_ID, Label: 'Vehicle' },
// { $Type: 'UI.DataField', Value: driver_ID, Label: 'Driver' },
// { $Type: 'UI.DataField', Value: assignmentDate, Label: 'Assignment Date' },
// { $Type: 'UI.DataField', Value: startDateTime, Label: 'Start Date and Time' },
// { $Type: 'UI.DataField', Value: endDateTime, Label: 'End Date and Time' },
// { $Type: 'UI.DataField', Value: assignedBy, Label: 'Assigned By' },
// { $Type: 'UI.DataField', Value: unassignedBy, Label: 'Unassigned By' },
// { $Type: 'UI.DataField', Value: reason, Label: 'Reason' },
// { $Type: 'UI.DataField', Value: remarks, Label: 'Remarks' },
// { $Type: 'UI.DataField', Value: status, Label: 'Assignment Status' }


// { $Type: 'UI.DataField', Value: tripNumber, Label: 'Trip Number' },
// { $Type: 'UI.DataField', Value: shipmentNumber, Label: 'Shipment Number' },
// { $Type: 'UI.DataField', Value: vehicle_ID, Label: 'Vehicle' },
// { $Type: 'UI.DataField', Value: driver_ID, Label: 'Driver' },
// { $Type: 'UI.DataField', Value: source, Label: 'Source Location' },
// { $Type: 'UI.DataField', Value: destination, Label: 'Destination' },
// { $Type: 'UI.DataField', Value: plannedDeparture, Label: 'Planned Departure' },
// { $Type: 'UI.DataField', Value: expectedArrival, Label: 'Expected Arrival' },
// { $Type: 'UI.DataField', Value: actualDeparture, Label: 'Actual Departure' },
// { $Type: 'UI.DataField', Value: actualArrival, Label: 'Actual Arrival' },
// { $Type: 'UI.DataField', Value: transportQuantity, Label: 'Transport Quantity' },
// { $Type: 'UI.DataField', Value: quantityUOM, Label: 'Quantity Unit' },
// { $Type: 'UI.DataField', Value: status, Label: 'Trip Status' },
// { $Type: 'UI.DataField', Value: remarks, Label: 'Remarks' }


// { $Type: 'UI.DataField', Value: documentNumber, Label: 'Document Number' },
// { $Type: 'UI.DataField', Value: vehicle_ID, Label: 'Vehicle' },
// { $Type: 'UI.DataField', Value: documentType, Label: 'Document Type' },
// { $Type: 'UI.DataField', Value: provider, Label: 'Provider' },
// { $Type: 'UI.DataField', Value: issueDate, Label: 'Issue Date' },
// { $Type: 'UI.DataField', Value: expiryDate, Label: 'Expiry Date' },
// { $Type: 'UI.DataField', Value: issuingAuthority, Label: 'Issuing Authority' },
// { $Type: 'UI.DataField', Value: remarks, Label: 'Remarks' }


// { $Type: 'UI.DataField', Value: maintenanceNumber, Label: 'Maintenance Number' },
// { $Type: 'UI.DataField', Value: vehicle_ID, Label: 'Vehicle' },
// { $Type: 'UI.DataField', Value: maintenanceType, Label: 'Maintenance Type' },
// { $Type: 'UI.DataField', Value: description, Label: 'Description' },
// { $Type: 'UI.DataField', Value: startDate, Label: 'Start Date' },
// { $Type: 'UI.DataField', Value: expectedCompletionDate, Label: 'Expected Completion Date' },
// { $Type: 'UI.DataField', Value: actualCompletionDate, Label: 'Actual Completion Date' },
// { $Type: 'UI.DataField', Value: actualCost, Label: 'Actual Cost' },
// { $Type: 'UI.DataField', Value: status, Label: 'Maintenance Status' },
// { $Type: 'UI.DataField', Value: remarks, Label: 'Remarks' }


// { $Type: 'UI.DataField', Value: vehicle_ID, Label: 'Vehicle' },
// { $Type: 'UI.DataField', Value: previousStatus, Label: 'Previous Status' },
// { $Type: 'UI.DataField', Value: newStatus, Label: 'New Status' },
// { $Type: 'UI.DataField', Value: changedBy, Label: 'Changed By' },
// { $Type: 'UI.DataField', Value: changedAt, Label: 'Changed On' },
// { $Type: 'UI.DataField', Value: remarks, Label: 'Remarks' }

annotate FleetService.Drivers with @(
    UI.HeaderInfo               : {
        TypeName      : 'Driver',
        TypeNamePlural: 'Drivers',
        Title         : {Value: driverName},
        Description   : {Value: driverNumber}
    },
    UI.SelectionFields          : [
        driverNumber,
        driverName,
        status,
        licenseNumber
    ],
    UI.LineItem                 : [
        {
            Value: driverNumber,
            Label: 'Driver Number'
        },
        {
            Value: driverName,
            Label: 'Driver Name'
        },
        {
            Value: phone,
            Label: 'Phone'
        },
        {
            Value: licenseNumber,
            Label: 'License Number'
        },
        {
            Value: licenseExpiry,
            Label: 'License Expiry'
        },
        {
            Value: status,
            Label: 'Status'
        }
    ],
    UI.FieldGroup #DriverDetails: {Data: [
        {Value: driverNumber},
        {Value: driverName},
        {Value: phone},
        {Value: email},
        {Value: address},
        {Value: licenseNumber},
        {Value: licenseIssueDate},
        {Value: licenseExpiry},
        {Value: status}
    ]},
    UI.Facets                   : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Driver Details',
        Target: '@UI.FieldGroup#DriverDetails'
    }]
);

annotate FleetService.VehicleAssignments with @(
    UI.HeaderInfo                   : {
        TypeName      : 'Vehicle Assignment',
        TypeNamePlural: 'Vehicle Assignments',
        Title         : {Value: assignmentNumber}
    },
    UI.SelectionFields              : [
        assignmentNumber,
        status,
        assignmentDate
    ],
    UI.LineItem                     : [
        {
            Value: assignmentNumber,
            Label: 'Assignment Number'
        },
        {
            Value: vehicle.vehicleNumber,
            Label: 'Vehicle'
        },
        {
            Value: driver.driverName,
            Label: 'Driver'
        },
        {
            Value: assignmentDate,
            Label: 'Assignment Date'
        },
        {
            Value: status,
            Label: 'Status'
        },
        {
            Value: assignedBy,
            Label: 'Assigned By'
        },
        {
            Value: unassignedBy,
            Label: 'Unassigned By'
        }
    ],
    UI.FieldGroup #AssignmentDetails: {Data: [
        {Value: assignmentNumber},
        {Value: vehicle.vehicleNumber},
        {Value: driver.driverName},
        {Value: assignmentDate},
        {Value: startDateTime},
        {Value: endDateTime},
        {Value: status},
        {Value: assignedBy},
        {Value: unassignedBy},
        {Value: reason},
        {Value: remarks}
    ]},
    UI.Facets                       : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Assignment Details',
        Target: '@UI.FieldGroup#AssignmentDetails'
    }]
);

annotate FleetService.VehicleTrips with @(
    UI.HeaderInfo             : {
        TypeName      : 'Vehicle Trip',
        TypeNamePlural: 'Vehicle Trips',
        Title         : {Value: tripNumber},
        Description   : {Value: shipmentNumber}
    },
    UI.SelectionFields        : [
        tripNumber,
        shipmentNumber,
        status
    ],
    UI.LineItem               : [
        {
            Value: tripNumber,
            Label: 'Trip Number'
        },
        {
            Value: shipmentNumber,
            Label: 'Shipment Number'
        },
        {
            Value: vehicle.vehicleNumber,
            Label: 'Vehicle'
        },
        {
            Value: driver.driverName,
            Label: 'Driver'
        },
        {
            Value: source,
            Label: 'Source'
        },
        {
            Value: destination,
            Label: 'Destination'
        },
        {
            Value: transportQuantity,
            Label: 'Transport Quantity'
        },
        {
            Value: quantityUOM,
            Label: 'Unit'
        },
        {
            Value: status,
            Label: 'Status'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.startTrip',
            Label : 'Start Trip'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.completeTrip',
            Label : 'Complete Trip'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.cancelTrip',
            Label : 'Cancel Trip'
        }
    ],
    UI.FieldGroup #TripDetails: {Data: [
        {Value: tripNumber},
        {Value: shipmentNumber},
        {Value: vehicle.vehicleNumber},
        {Value: driver.driverName},
        {Value: source},
        {Value: destination},
        {Value: plannedDeparture},
        {Value: expectedArrival},
        {Value: actualDeparture},
        {Value: actualArrival},
        {Value: transportQuantity},
        {Value: quantityUOM},
        {Value: status},
        {Value: remarks}
    ]},
    UI.Facets                 : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Trip Details',
        Target: '@UI.FieldGroup#TripDetails'
    }]
);

annotate FleetService.VehicleDocuments with @(
    UI.HeaderInfo     : {
        TypeName      : 'Vehicle Document',
        TypeNamePlural: 'Vehicle Documents',
        Title         : {Value: documentNumber}
    },
    UI.SelectionFields: [
        documentNumber,
        documentType,
        expiryDate
    ],
    UI.LineItem       : [
        {
            Value: documentNumber,
            Label: 'Document Number'
        },
        {
            Value: vehicle.vehicleNumber,
            Label: 'Vehicle'
        },
        {
            Value: documentType,
            Label: 'Document Type'
        },
        {
            Value: provider,
            Label: 'Provider'
        },
        {
            Value: issueDate,
            Label: 'Issue Date'
        },
        {
            Value: expiryDate,
            Label: 'Expiry Date'
        },
        {
            Value: issuingAuthority,
            Label: 'Issuing Authority'
        }
    ]
);

annotate FleetService.MaintenanceRecords with @(
    UI.HeaderInfo     : {
        TypeName      : 'Maintenance Record',
        TypeNamePlural: 'Maintenance Records',
        Title         : {Value: maintenanceNumber}
    },
    UI.SelectionFields: [
        maintenanceNumber,
        maintenanceType,
        status
    ],
    UI.LineItem       : [
        {
            Value: maintenanceNumber,
            Label: 'Maintenance Number'
        },
        {
            Value: vehicle.vehicleNumber,
            Label: 'Vehicle'
        },
        {
            Value: maintenanceType,
            Label: 'Maintenance Type'
        },
        {
            Value: startDate,
            Label: 'Start Date'
        },
        {
            Value: expectedCompletionDate,
            Label: 'Expected Completion'
        },
        {
            Value: actualCompletionDate,
            Label: 'Actual Completion'
        },
        {
            Value: actualCost,
            Label: 'Actual Cost'
        },
        {
            Value: status,
            Label: 'Status'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.startMaintenance',
            Label : 'Start Maintenance'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.completeMaintenance',
            Label : 'Complete Maintenance'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'FleetService.cancelMaintenance',
            Label : 'Cancel Maintenance'
        }
    ]
);

annotate FleetService.VehicleStatusHistory with @(
    UI.HeaderInfo     : {
        TypeName      : 'Vehicle Status History',
        TypeNamePlural: 'Vehicle Status History',
        Title         : {Value: newStatus}
    },
    UI.SelectionFields: [
        newStatus,
        changedBy,
        changedAt
    ],
    UI.LineItem       : [
        {
            Value: vehicle.vehicleNumber,
            Label: 'Vehicle'
        },
        {
            Value: previousStatus,
            Label: 'Previous Status'
        },
        {
            Value: newStatus,
            Label: 'New Status'
        },
        {
            Value: changedBy,
            Label: 'Changed By'
        },
        {
            Value: changedAt,
            Label: 'Changed At'
        },
        {
            Value: remarks,
            Label: 'Remarks'
        }
    ]
);

annotate FleetService.Vehicles with {
    capacityUOM                @Common.ValueList: {
        CollectionPath: 'CapacityUnits',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: capacityUOM,
                ValueListProperty: 'code'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name'
            }
        ]
    };

    status                     @Common.ValueList: {
        CollectionPath: 'VehicleStatusValues',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: status,
                ValueListProperty: 'code'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name'
            }
        ]
    };

    fuelType                   @Common.ValueList: {
        CollectionPath: 'FuelTypeValues',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: fuelType,
                ValueListProperty: 'code'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name'
            }
        ]
    };

    statusCriticality          @UI.Hidden;
    insuranceExpiryCriticality @UI.Hidden;
    fitnessExpiryCriticality   @UI.Hidden;
};

annotate FleetService.VehicleTrips with {
    driver @Common.ValueList: {
        CollectionPath: 'Drivers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: driver_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'driverName'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'licenseNumber'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'status'
            }
        ]
    };
};
