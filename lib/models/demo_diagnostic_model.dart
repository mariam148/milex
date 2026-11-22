import 'car_model.dart';

class DemoDiagnosticItem {
  const DemoDiagnosticItem(
    this.name,
    this.status,
    this.action, {
    this.warning = false,
  });
  final String name, status, action;
  final bool warning;
}

class DemoDiagnosticModel {
  DemoDiagnosticModel.forCar(CarModel car)
    : carId = car.id,
      items = [
        DemoDiagnosticItem(
          'Engine Oil',
          car.fuelType == 'Electric'
              ? 'Not applicable (electric)'
              : 'Sample service reminder',
          car.fuelType == 'Electric'
              ? 'No engine oil in this simulated electric vehicle.'
              : 'Demo recommendation: review the sample service schedule.',
          warning: car.fuelType != 'Electric',
        ),
        const DemoDiagnosticItem(
          'Battery',
          'Sample low charge warning',
          'Demo recommendation: arrange a battery inspection.',
          warning: true,
        ),
        const DemoDiagnosticItem(
          'Engine',
          'Sample normal status',
          'No issue in this simulated example.',
        ),
        DemoDiagnosticItem(
          'Tires',
          car.category == 'Sports'
              ? 'Sample low pressure warning'
              : 'Sample normal pressure',
          'Demo recommendation: inspect tires using the vehicle manual.',
          warning: car.category == 'Sports',
        ),
      ];
  final String carId;
  final List<DemoDiagnosticItem> items;
}
