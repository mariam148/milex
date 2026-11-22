class DemoAssistanceRequest {
  const DemoAssistanceRequest({
    required this.carId,
    required this.service,
    required this.problem,
    required this.location,
  });
  final String? carId;
  final String service, problem, location;
}
