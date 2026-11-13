using { fleet.db as db } from '../db/schema';

@path: '/fleet'
service FleetService {

  entity Vehicles as projection on db.Vehicles;

  entity Drivers as projection on db.Drivers;

  entity VehicleAssignments as projection on db.VehicleAssignments;

  @odata.draft.enabled
  entity VehicleTrips as projection on db.VehicleTrips;

  entity VehicleDocuments as projection on db.VehicleDocuments;

  entity MaintenanceRecords as projection on db.MaintenanceRecords;

  entity VehicleStatusHistory as projection on db.VehicleStatusHistory;

  entity CapacityUnits as projection on db.CapacityUnits;

  entity VehicleStatusValues as projection on db.VehicleStatusValues;

  entity FuelTypeValues as projection on db.FuelTypeValues;
}