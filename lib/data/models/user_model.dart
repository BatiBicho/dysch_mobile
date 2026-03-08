class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String companyName;
  final String branchName;
  final String departmentName;
  final String jobPositionTitle;
  final String employeeCode;
  final int vacationDaysAvailable;
  final bool isRemoteWorkAllowed;
  final String curp;
  final String rfc;
  final String contractType;
  final bool isActive;
  final String? token;
  final String role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.companyName,
    required this.branchName,
    required this.departmentName,
    required this.jobPositionTitle,
    required this.employeeCode,
    required this.vacationDaysAvailable,
    required this.isRemoteWorkAllowed,
    required this.curp,
    required this.rfc,
    required this.contractType,
    required this.isActive,
    this.token,
    this.role = 'EMPLOYEE',
  });

  String get fullName => '$firstName $lastName';

  // De JSON (API) a Objeto Dart - Para login
  factory UserModel.fromLoginJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    final tokensData = json['tokens'] as Map<String, dynamic>;

    return UserModel(
      id: userData['id'] ?? '',
      firstName: userData['first_name'] ?? '',
      lastName: userData['last_name'] ?? '',
      email: userData['email'] ?? '',
      phoneNumber: userData['phone_number'] ?? '',
      companyName: '',
      branchName: '',
      departmentName: '',
      jobPositionTitle: '',
      employeeCode: '',
      vacationDaysAvailable: 0,
      isRemoteWorkAllowed: false,
      curp: '',
      rfc: '',
      contractType: '',
      isActive: userData['is_active'] ?? true,
      token: tokensData['access'],
      role: userData['role'] ?? 'EMPLOYEE',
    );
  }

  // De JSON (API) a Objeto Dart - Para perfil de empleado
  factory UserModel.fromEmployeeJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      companyName: json['company_name'] ?? '',
      branchName: json['branch_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      jobPositionTitle: json['job_position_title'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      vacationDaysAvailable: json['vacation_days_available'] ?? 0,
      isRemoteWorkAllowed: json['is_remote_work_allowed'] ?? false,
      curp: json['curp'] ?? '',
      rfc: json['rfc'] ?? '',
      contractType: json['contract_type'] ?? '',
      isActive: json['is_active'] ?? true,
      role: 'EMPLOYEE',
    );
  }

  // De Objeto Dart a JSON (Para mandar a la API)
  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
  };
}
