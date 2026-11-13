
using { cuid, managed } from '@sap/cds/common';

namespace fleet.db;

entity Vehicles : cuid, managed {
  vehicleNumber        : String(20) not null;
  vehicleType          : String(40) not null;
  registrationDate     : Date;
  manufacturer         : String(80);
  model                : String(80);
  manufacturingYear    : Integer;
  capacity              : Decimal(13,3);
  capacityUOM           : String(10);
  fuelType              : String(30);
  currentLocation       : String(120);
  active                : Boolean default true;
  status                : String(20) default 'Available';

  insuranceNumber       : String(50);
  insuranceProvider     : String(100);
  insuranceStartDate    : Date;
  insuranceExpiry       : Date;

  fitnessCertificateNo  : String(50);
  fitnessIssueDate      : Date;
  fitnessExpiry         : Date;

  permitNumber          : String(50);
  permitIssueDate       : Date;
  permitExpiry          : Date;

  currentDriver         : Association to Drivers;

  assignments           : Association to many VehicleAssignments
                            on assignments.vehicle = $self;

  documents             : Association to many VehicleDocuments
                            on documents.vehicle = $self;

  maintenanceRecords    : Association to many MaintenanceRecords
                            on maintenanceRecords.vehicle = $self;

  statusHistory         : Association to many VehicleStatusHistory
                            on statusHistory.vehicle = $self;
}

entity Drivers : cuid, managed {
  driverNumber          : String(20) not null;
  driverName            : String(100) not null;
  phone                 : String(30);
  email                 : String(120);
  licenseNumber         : String(50) not null;
  licenseIssueDate      : Date;
  licenseExpiry         : Date;
  status                : String(20) default 'Active';
  address               : String(250);

  assignments           : Association to many VehicleAssignments
                            on assignments.driver = $self;

  trips                 : Association to many VehicleTrips
                            on trips.driver = $self;
}

entity VehicleAssignments : cuid, managed {
  assignmentNumber      : String(30);
  vehicle               : Association to Vehicles not null;
  driver                : Association to Drivers not null;
  assignmentDate        : Date;
  startDateTime         : Timestamp;
  endDateTime           : Timestamp;
  assignedBy            : String(100);
  unassignedBy          : String(100);
  reason                : String(500);
  remarks               : String(500);
  status                : String(20) default 'Active';
}

entity VehicleTrips : cuid, managed {
  tripNumber            : String(30) not null;
  shipmentNumber        : String(50);
  vehicle               : Association to Vehicles not null;
  driver                : Association to Drivers not null;
  source                : String(120) not null;
  destination           : String(120) not null;
  plannedDeparture      : Timestamp;
  expectedArrival       : Timestamp;
  actualDeparture       : Timestamp;
  actualArrival         : Timestamp;
  transportQuantity     : Decimal(13,3) not null;
  quantityUOM           : String(10) not null;
  status                : String(20) default 'Planned';
  remarks               : String(500);
}

entity VehicleDocuments : cuid, managed {
  documentNumber        : String(50) not null;
  vehicle               : Association to Vehicles not null;
  documentType          : String(30) not null;
  provider              : String(100);
  issueDate             : Date;
  expiryDate            : Date;
  issuingAuthority      : String(100);
  remarks               : String(500);
}

entity MaintenanceRecords : cuid, managed {
  maintenanceNumber      : String(30) not null;
  vehicle                : Association to Vehicles not null;
  maintenanceType        : String(50) not null;
  description            : String(500);
  startDate              : Date;
  expectedCompletionDate : Date;
  actualCompletionDate   : Date;
  actualCost             : Decimal(13,2);
  status                 : String(20) default 'Scheduled';
  remarks                : String(500);
}

entity VehicleStatusHistory : cuid, managed {
  vehicle                : Association to Vehicles not null;
  previousStatus         : String(20);
  newStatus              : String(20) not null;
  changedBy              : String(100);
  changedAt              : Timestamp;
  remarks                : String(500);
}

entity CapacityUnits {
  key code : String(10);
      name : String(40);
}

entity VehicleStatusValues {
  key code : String(20);
      name : String(40);
}

entity FuelTypeValues {
  key code : String(30);
      name : String(40);
}