const cds = require('@sap/cds');

const {
  SELECT,
  INSERT,
  UPDATE
} = cds.ql;

const VALID_STATUSES = [
  'Available',
  'Assigned',
  'InTransit',
  'Maintenance'
];

const TRANSITIONS = {
  Available: ['Assigned', 'Maintenance'],
  Assigned: ['InTransit', 'Available', 'Maintenance'],
  InTransit: ['Available', 'Maintenance'],
  Maintenance: ['Available']
};

const EXPIRY_WARNING_DAYS = 30;

module.exports = class FleetService extends cds.ApplicationService {
  async init() {
    const db = await cds.connect.to('db');

    const {
      Vehicles,
      Drivers,
      VehicleAssignments,
      VehicleTrips,
      VehicleDocuments,
      MaintenanceRecords,
      VehicleStatusHistory
    } = this.entities;

    const actor = req => req.user?.id || 'SYSTEM';
    const today = () => new Date().toISOString().slice(0, 10);
    const now = () => new Date().toISOString();

    const dateOnly = value => {
      if (!value) return null;
      return String(value).slice(0, 10);
    };

    const daysUntil = value => {
      const target = new Date(`${dateOnly(value)}T00:00:00Z`);
      const current = new Date(`${today()}T00:00:00Z`);
      return Math.ceil((target - current) / 86400000);
    };

    const expiryStatus = value => {
      if (!value) return 'Missing';
      const days = daysUntil(value);
      if (days < 0) return 'Expired';
      if (days <= EXPIRY_WARNING_DAYS) return 'ExpiringSoon';
      return 'Valid';
    };

    const getExpiryCriticality = value => {
      const status = expiryStatus(value);
      if (status === 'Expired' || status === 'Missing') return 1;
      if (status === 'ExpiringSoon') return 2;
      return 3;
    };

    const getVehicle = async (ID, tx = db) => {
      const vehicle = await tx.run(
        SELECT.one.from(Vehicles).where({ ID })
      );
      if (!vehicle) reqError(404, 'Vehicle not found.');
      return vehicle;
    };

    const getDriver = async (ID, tx = db) => {
      const driver = await tx.run(
        SELECT.one.from(Drivers).where({ ID })
      );
      if (!driver) reqError(404, 'Driver not found.');
      return driver;
    };

    const reqError = (status, message) => {
      const error = new Error(message);
      error.status = status;
      throw error;
    };

    const entityID = req => req.params?.[0]?.ID;

    const addHistory = async (
      vehicleID,
      previousStatus,
      newStatus,
      user,
      remarks,
      tx = db
    ) => {
      await tx.run(INSERT.into(VehicleStatusHistory).entries({
        vehicle_ID: vehicleID,
        previousStatus: previousStatus || null,
        newStatus,
        changedBy: user,
        changedAt: now(),
        remarks: remarks || null
      }));
    };

    const getActiveAssignment = (vehicleID, tx = db) =>
      tx.run(
        SELECT.one.from(VehicleAssignments)
          .where({ vehicle_ID: vehicleID, status: 'Active' })
      );

    const hasActiveTrip = (vehicleID, tx = db) =>
      tx.run(
        SELECT.one.from(VehicleTrips)
          .where({
            vehicle_ID: vehicleID,
            status: { in: ['Assigned', 'InTransit'] }
          })
      );

    const validateVehicleDocuments = async (vehicle, tx = db) => {
      if (expiryStatus(vehicle.insuranceExpiry) !== 'Valid') {
        reqError(400, 'Vehicle insurance must be valid and not near expiry.');
      }

      if (expiryStatus(vehicle.fitnessExpiry) !== 'Valid') {
        reqError(400, 'Vehicle fitness certificate must be valid and not near expiry.');
      }

      if (vehicle.permitNumber &&
          expiryStatus(vehicle.permitExpiry) !== 'Valid') {
        reqError(400, 'Vehicle permit must be valid and not near expiry.');
      }

      const docs = await tx.run(
        SELECT.from(VehicleDocuments)
          .where({ vehicle_ID: vehicle.ID })
      );

      const expiredDoc = docs.find(doc =>
        doc.expiryDate && expiryStatus(doc.expiryDate) === 'Expired'
      );

      if (expiredDoc) {
        reqError(400, `Document ${expiredDoc.documentNumber} has expired.`);
      }
    };

    const changeVehicleStatus = async (
      vehicle,
      newStatus,
      user,
      remarks,
      tx = db
    ) => {
      if (!VALID_STATUSES.includes(newStatus)) {
        reqError(400, `Invalid vehicle status: ${newStatus}`);
      }

      if (vehicle.status === newStatus) return vehicle;

      const allowed = TRANSITIONS[vehicle.status] || [];
      if (!allowed.includes(newStatus)) {
        reqError(
          400,
          `Vehicle status cannot change from ${vehicle.status} to ${newStatus}.`
        );
      }

      if (newStatus === 'Available') {
        if (!vehicle.active) {
          reqError(400, 'An inactive vehicle cannot be Available.');
        }
        await validateVehicleDocuments(vehicle, tx);
      }

      await tx.run(
        UPDATE(Vehicles)
          .set({ status: newStatus })
          .where({ ID: vehicle.ID })
      );

      await addHistory(
        vehicle.ID,
        vehicle.status,
        newStatus,
        user,
        remarks,
        tx
      );

      vehicle.status = newStatus;
      return vehicle;
    };

    // ---------------------------------------------------------
    // Vehicle validations and read enrichment
    // ---------------------------------------------------------

    this.before(['CREATE', 'UPDATE'], 'Vehicles', async req => {
      const data = req.data;
      const creating = req.event === 'CREATE';

      if (creating) {
        const mandatory = [
          'vehicleNumber',
          'vehicleType',
          'manufacturer',
          'model',
          'capacity',
          'capacityUOM',
          'fuelType',
          'registrationDate',
          'insuranceNumber',
          'insuranceProvider',
          'insuranceStartDate',
          'insuranceExpiry',
          'fitnessCertificateNo',
          'fitnessIssueDate',
          'fitnessExpiry'
        ];

        for (const field of mandatory) {
          if (data[field] === undefined ||
              data[field] === null ||
              data[field] === '') {
            req.error(400, `${field} is required.`);
          }
        }

        data.active ??= true;
        data.status ??= 'Available';
      }

      if (data.vehicleNumber) {
        data.vehicleNumber = data.vehicleNumber.trim().toUpperCase();

        if (!/^[A-Z0-9 -]{5,20}$/.test(data.vehicleNumber)) {
          req.error(400, 'Vehicle number must be 5–20 characters using letters, numbers, spaces, or hyphens.');
        }

        const duplicate = await db.run(
          SELECT.one.from(Vehicles)
            .where({ vehicleNumber: data.vehicleNumber })
        );

        if (duplicate && duplicate.ID !== data.ID) {
          req.error(400, 'Vehicle number already exists.');
        }
      }

      if (data.capacity !== undefined && Number(data.capacity) <= 0) {
        req.error(400, 'Vehicle capacity must be greater than zero.');
      }

      if (data.registrationDate &&
          dateOnly(data.registrationDate) > today()) {
        req.error(400, 'Registration date cannot be in the future.');
      }

      const year = new Date().getFullYear();
      if (data.manufacturingYear !== undefined &&
          data.manufacturingYear !== null &&
          (Number(data.manufacturingYear) < 1900 ||
           Number(data.manufacturingYear) > year)) {
        req.error(400, `Manufacturing year must be between 1900 and ${year}.`);
      }

      for (const [startField, expiryField] of [
        ['insuranceStartDate', 'insuranceExpiry'],
        ['fitnessIssueDate', 'fitnessExpiry'],
        ['permitIssueDate', 'permitExpiry']
      ]) {
        if (data[startField] && data[expiryField] &&
            dateOnly(data[expiryField]) < dateOnly(data[startField])) {
          req.error(400, `${expiryField} cannot be before ${startField}.`);
        }
      }

      if (data.status && !VALID_STATUSES.includes(data.status)) {
        req.error(400, 'Invalid vehicle status.');
      }

      if (!creating) {
        const ID = data.ID || entityID(req);
        if (!ID) return;

        const existing = await getVehicle(ID);

        if (data.status && data.status !== existing.status) {
          req.error(400, 'Use the changeStatus action to change vehicle status.');
        }

        if (data.vehicleNumber &&
            data.vehicleNumber !== existing.vehicleNumber) {
          req.error(400, 'Vehicle number cannot be changed after registration.');
        }

        if (data.currentDriver_ID !== undefined &&
            data.currentDriver_ID !== existing.currentDriver_ID) {
          req.error(400, 'Use assignDriver or unassignDriver to change the driver.');
        }

        if (data.capacity !== undefined &&
            Number(data.capacity) !== Number(existing.capacity)) {
          if (existing.status === 'Assigned' ||
              await hasActiveTrip(ID)) {
            req.error(400, 'Capacity cannot be changed while a vehicle is assigned or has an active trip.');
          }
        }

        if (data.active === false && existing.active) {
          if (['Assigned', 'InTransit'].includes(existing.status) ||
              await hasActiveTrip(ID) ||
              await getActiveAssignment(ID)) {
            req.error(400, 'Unassign the vehicle and finish its trips before deactivating it.');
          }
        }
      }
    });

    this.after('READ', 'Vehicles', results => {
      const vehicles = Array.isArray(results) ? results : [results];
      for (const vehicle of vehicles) {
        if (!vehicle) continue;

        vehicle.statusCriticality =
          vehicle.status === 'Available' ? 3 :
          vehicle.status === 'Maintenance' ? 1 :
          ['Assigned', 'InTransit'].includes(vehicle.status) ? 2 : 0;

        vehicle.insuranceExpiryCriticality =
          getExpiryCriticality(vehicle.insuranceExpiry);

        vehicle.fitnessExpiryCriticality =
          getExpiryCriticality(vehicle.fitnessExpiry);
      }
    });

    this.after('CREATE', 'Vehicles', async (vehicle, req) => {
      await addHistory(
        vehicle.ID,
        null,
        vehicle.status || 'Available',
        actor(req),
        'Vehicle created'
      );
    });

    // ---------------------------------------------------------
    // Vehicle actions
    // ---------------------------------------------------------

    this.on('changeStatus', 'Vehicles', async req => {
      const ID = entityID(req);
      const vehicle = await getVehicle(ID);
      const newStatus = req.data.newStatus;

      if (newStatus === 'Assigned') {
        req.error(400, 'Use assignDriver to assign a vehicle.');
      }

      if (newStatus === 'InTransit') {
        req.error(400, 'Use startTrip to put a vehicle InTransit.');
      }

      if (newStatus === 'Maintenance' && await hasActiveTrip(ID)) {
        req.error(400, 'Complete or cancel the active trip before maintenance.');
      }

      return changeVehicleStatus(
        vehicle,
        newStatus,
        actor(req),
        req.data.remarks
      );
    });

    this.on('assignDriver', 'Vehicles', async req => {
      const vehicleID = entityID(req);
      const vehicle = await getVehicle(vehicleID);
      const driver = await getDriver(req.data.driverID);

      if (!vehicle.active) req.error(400, 'Inactive vehicles cannot be assigned.');
      if (vehicle.status !== 'Available') {
        req.error(400, 'Only Available vehicles can be assigned.');
      }
      if (driver.status !== 'Active') req.error(400, 'Driver is not Active.');
      if (driver.licenseExpiry &&
          expiryStatus(driver.licenseExpiry) !== 'Valid') {
        req.error(400, 'Driver license is expired or near expiry.');
      }

      await validateVehicleDocuments(vehicle);

      if (await getActiveAssignment(vehicleID)) {
        req.error(400, 'Vehicle already has an active assignment.');
      }

      const driverAssignment = await db.run(
        SELECT.one.from(VehicleAssignments)
          .where({ driver_ID: driver.ID, status: 'Active' })
      );

      if (driverAssignment) {
        req.error(400, 'Driver is already assigned to another vehicle.');
      }

      const assignment = {
        ID: cds.utils.uuid(),
        assignmentNumber: `ASN-${Date.now()}`,
        vehicle_ID: vehicleID,
        driver_ID: driver.ID,
        assignmentDate: today(),
        startDateTime: now(),
        assignedBy: actor(req),
        reason: req.data.reason || null,
        status: 'Active'
      };

      await db.run(INSERT.into(VehicleAssignments).entries(assignment));

      await db.run(
        UPDATE(Vehicles)
          .set({ currentDriver_ID: driver.ID })
          .where({ ID: vehicleID })
      );

      vehicle.currentDriver_ID = driver.ID;

      await changeVehicleStatus(
        vehicle,
        'Assigned',
        actor(req),
        'Driver assigned'
      );

      return assignment;
    });

    this.on('unassignDriver', 'Vehicles', async req => {
      const vehicleID = entityID(req);
      const vehicle = await getVehicle(vehicleID);

      if (vehicle.status === 'InTransit') {
        req.error(400, 'Cannot unassign a driver while the vehicle is InTransit.');
      }

      const assignment = await getActiveAssignment(vehicleID);
      if (!assignment) req.error(400, 'No active assignment found.');

      await db.run(
        UPDATE(VehicleAssignments)
          .set({
            status: 'Completed',
            endDateTime: now(),
            unassignedBy: actor(req),
            remarks: req.data.remarks || null
          })
          .where({ ID: assignment.ID })
      );

      await db.run(
        UPDATE(Vehicles)
          .set({ currentDriver_ID: null })
          .where({ ID: vehicleID })
      );

      vehicle.currentDriver_ID = null;

      if (vehicle.status === 'Assigned') {
        await changeVehicleStatus(
          vehicle,
          'Available',
          actor(req),
          'Driver unassigned'
        );
      }

      return vehicle;
    });

    this.on('deactivate', 'Vehicles', async req => {
      const ID = entityID(req);
      const vehicle = await getVehicle(ID);

      if (await hasActiveTrip(ID) || await getActiveAssignment(ID)) {
        req.error(400, 'Finish active trips and unassign the driver before deactivation.');
      }

      await db.run(
        UPDATE(Vehicles).set({ active: false }).where({ ID })
      );

      return { ...vehicle, active: false };
    });

    this.on('reactivate', 'Vehicles', async req => {
      const ID = entityID(req);
      const vehicle = await getVehicle(ID);

      await db.run(
        UPDATE(Vehicles).set({ active: true }).where({ ID })
      );

      return { ...vehicle, active: true };
    });

    // ---------------------------------------------------------
    // Trip validations and actions
    // ---------------------------------------------------------

    this.before('CREATE', 'VehicleTrips', async req => {
      const data = req.data;

      if (!data.vehicle_ID || !data.driver_ID) {
        req.error(400, 'Vehicle and driver are required.');
      }

      const vehicle = await getVehicle(data.vehicle_ID);
      const driver = await getDriver(data.driver_ID);

      if (!vehicle.active || vehicle.status !== 'Assigned') {
        req.error(400, 'Trip requires an active vehicle with status Assigned.');
      }

      if (driver.status !== 'Active') {
        req.error(400, 'Driver must be Active.');
      }

      if (vehicle.currentDriver_ID !== driver.ID) {
        req.error(400, 'Selected driver must be assigned to the selected vehicle.');
      }

      await validateVehicleDocuments(vehicle);

      if (driver.licenseExpiry &&
          expiryStatus(driver.licenseExpiry) !== 'Valid') {
        req.error(400, 'Driver license is expired or near expiry.');
      }

      if (Number(data.transportQuantity) <= 0) {
        req.error(400, 'Transport quantity must be greater than zero.');
      }

      if (data.quantityUOM !== vehicle.capacityUOM) {
        req.error(400, 'Trip quantity unit must match the vehicle capacity unit.');
      }

      if (Number(data.transportQuantity) > Number(vehicle.capacity)) {
        req.error(400, 'Transport quantity cannot exceed vehicle capacity.');
      }

      if (await hasActiveTrip(vehicle.ID)) {
        req.error(400, 'Vehicle already has an active trip.');
      }

      if (data.plannedDeparture && data.expectedArrival &&
          new Date(data.expectedArrival) < new Date(data.plannedDeparture)) {
        req.error(400, 'Expected arrival cannot be before planned departure.');
      }

      data.tripNumber ||= `TRIP-${Date.now()}`;
      data.status = 'Assigned';
    });

    this.on('startTrip', 'VehicleTrips', async req => {
      const tripID = entityID(req);
      const trip = await db.run(
        SELECT.one.from(VehicleTrips).where({ ID: tripID })
      );

      if (!trip) req.error(404, 'Trip not found.');
      if (trip.status !== 'Assigned') {
        req.error(400, 'Only Assigned trips can be started.');
      }

      const vehicle = await getVehicle(trip.vehicle_ID);

      if (vehicle.status !== 'Assigned') {
        req.error(400, 'Vehicle must be Assigned before starting the trip.');
      }

      await validateVehicleDocuments(vehicle);

      await db.run(
        UPDATE(VehicleTrips)
          .set({ status: 'InTransit', actualDeparture: now() })
          .where({ ID: tripID })
      );

      await changeVehicleStatus(
        vehicle,
        'InTransit',
        actor(req),
        `Trip ${trip.tripNumber} started`
      );

      return { ...trip, status: 'InTransit', actualDeparture: now() };
    });

    this.on('completeTrip', 'VehicleTrips', async req => {
      const tripID = entityID(req);
      const trip = await db.run(
        SELECT.one.from(VehicleTrips).where({ ID: tripID })
      );

      if (!trip) req.error(404, 'Trip not found.');
      if (trip.status !== 'InTransit') {
        req.error(400, 'Only InTransit trips can be completed.');
      }

      const arrival = now();

      await db.run(
        UPDATE(VehicleTrips)
          .set({ status: 'Completed', actualArrival: arrival })
          .where({ ID: tripID })
      );

      const vehicle = await getVehicle(trip.vehicle_ID);

      await changeVehicleStatus(
        vehicle,
        'Available',
        actor(req),
        `Trip ${trip.tripNumber} completed`
      );

      return { ...trip, status: 'Completed', actualArrival: arrival };
    });

    this.on('cancelTrip', 'VehicleTrips', async req => {
      const tripID = entityID(req);
      const trip = await db.run(
        SELECT.one.from(VehicleTrips).where({ ID: tripID })
      );

      if (!trip) req.error(404, 'Trip not found.');
      if (!['Planned', 'Assigned'].includes(trip.status)) {
        req.error(400, 'Only Planned or Assigned trips can be cancelled.');
      }

      await db.run(
        UPDATE(VehicleTrips)
          .set({
            status: 'Cancelled',
            remarks: req.data.remarks || trip.remarks
          })
          .where({ ID: tripID })
      );

      const vehicle = await getVehicle(trip.vehicle_ID);

      if (vehicle.status === 'Assigned' &&
          !(await hasActiveTrip(vehicle.ID))) {
        await changeVehicleStatus(
          vehicle,
          'Available',
          actor(req),
          `Trip ${trip.tripNumber} cancelled`
        );
      }

      return { ...trip, status: 'Cancelled' };
    });

    // ---------------------------------------------------------
    // Vehicle documents
    // ---------------------------------------------------------

    this.before(['CREATE', 'UPDATE'], 'VehicleDocuments', async req => {
      const data = req.data;

      if (data.issueDate && data.expiryDate &&
          dateOnly(data.expiryDate) < dateOnly(data.issueDate)) {
        req.error(400, 'Document expiry date cannot precede issue date.');
      }

      if (data.documentNumber) {
        const duplicate = await db.run(
          SELECT.one.from(VehicleDocuments)
            .where({ documentNumber: data.documentNumber })
        );

        if (duplicate && duplicate.ID !== data.ID) {
          req.error(400, 'Document number already exists.');
        }
      }
    });

    // ---------------------------------------------------------
    // Maintenance actions
    // ---------------------------------------------------------

    this.on('startMaintenance', 'MaintenanceRecords', async req => {
      const ID = entityID(req);
      const record = await db.run(
        SELECT.one.from(MaintenanceRecords).where({ ID })
      );

      if (!record) req.error(404, 'Maintenance record not found.');
      if (record.status !== 'Scheduled') {
        req.error(400, 'Only Scheduled maintenance can be started.');
      }

      const vehicle = await getVehicle(record.vehicle_ID);

      if (vehicle.status === 'InTransit' || await hasActiveTrip(vehicle.ID)) {
        req.error(400, 'Vehicle has an active trip.');
      }

      if (await getActiveAssignment(vehicle.ID)) {
        req.error(400, 'Unassign the driver before starting maintenance.');
      }

      const startDate = today();

      await db.run(
        UPDATE(MaintenanceRecords)
          .set({ status: 'InProgress', startDate })
          .where({ ID })
      );

      await changeVehicleStatus(
        vehicle,
        'Maintenance',
        actor(req),
        `Maintenance ${record.maintenanceNumber} started`
      );

      return { ...record, status: 'InProgress', startDate };
    });

    this.on('completeMaintenance', 'MaintenanceRecords', async req => {
      const ID = entityID(req);
      const record = await db.run(
        SELECT.one.from(MaintenanceRecords).where({ ID })
      );

      if (!record) req.error(404, 'Maintenance record not found.');
      if (record.status !== 'InProgress') {
        req.error(400, 'Only InProgress maintenance can be completed.');
      }

      const completionDate = today();

      if (record.startDate &&
          completionDate < dateOnly(record.startDate)) {
        req.error(400, 'Completion date cannot be before start date.');
      }

      await db.run(
        UPDATE(MaintenanceRecords)
          .set({
            status: 'Completed',
            actualCompletionDate: completionDate
          })
          .where({ ID })
      );

      const vehicle = await getVehicle(record.vehicle_ID);

      await changeVehicleStatus(
        vehicle,
        'Available',
        actor(req),
        `Maintenance ${record.maintenanceNumber} completed`
      );

      return {
        ...record,
        status: 'Completed',
        actualCompletionDate: completionDate
      };
    });

    this.on('cancelMaintenance', 'MaintenanceRecords', async req => {
      const ID = entityID(req);
      const record = await db.run(
        SELECT.one.from(MaintenanceRecords).where({ ID })
      );

      if (!record) req.error(404, 'Maintenance record not found.');
      if (record.status !== 'Scheduled') {
        req.error(400, 'Only Scheduled maintenance can be cancelled.');
      }

      await db.run(
        UPDATE(MaintenanceRecords)
          .set({
            status: 'Cancelled',
            remarks: req.data.remarks || record.remarks
          })
          .where({ ID })
      );

      return { ...record, status: 'Cancelled' };
    });

    // ---------------------------------------------------------
    // Dashboard
    // ---------------------------------------------------------

    this.on('getDashboard', async () => {
      const vehicles = await db.run(SELECT.from(Vehicles));

      return {
        totalVehicles: vehicles.filter(v => v.active).length,
        available: vehicles.filter(v => v.active && v.status === 'Available').length,
        assigned: vehicles.filter(v => v.active && v.status === 'Assigned').length,
        inTransit: vehicles.filter(v => v.active && v.status === 'InTransit').length,
        maintenance: vehicles.filter(v => v.status === 'Maintenance').length,
        insuranceExpired: vehicles.filter(v => expiryStatus(v.insuranceExpiry) === 'Expired').length,
        fitnessExpired: vehicles.filter(v => expiryStatus(v.fitnessExpiry) === 'Expired').length,
        inactive: vehicles.filter(v => !v.active).length
      };
    });

    return super.init();
  }
};