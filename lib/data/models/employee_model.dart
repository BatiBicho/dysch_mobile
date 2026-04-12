
class EmployeeModel {
    final String id;
    final String userId;
    final String companyId;
    final String companyName;
    final String? branchId;
    final String? branchName;
    final String? departmentId;
    final String? departmentName;
    final String? jobPositionId;
    final String? jobPositionTitle;
    final String employeeCode;
    final String firstName;
    final String lastName;
    final String email;
    final String? phoneNumber;
    final String role;
    final bool isActive;

    EmployeeModel({
        required this.id,
        required this.userId,
        required this.companyId,
        required this.companyName,
        this.branchId,
        this.branchName,
        this.departmentId,
        this.departmentName,
        this.jobPositionId,
        this.jobPositionTitle,
        required this.employeeCode,
        required this.firstName,
        required this.lastName,
        required this.email,
        this.phoneNumber,
        required this.role,
        required this.isActive,
    });

    String get fullName => '$firstName $lastName';

    factory EmployeeModel.fromJson(Map<String, dynamic> json) {
        return EmployeeModel(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        companyId: json['company_id'] ?? '',
        companyName: json['company_name'] ?? '',
        branchId: json['branch_id'],
        branchName: json['branch_name'],
        departmentId: json['department_id'],
        departmentName: json['department_name'],
        jobPositionId: json['job_position_id'],
        jobPositionTitle: json['job_position_title'],
        employeeCode: json['employee_code'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'],
        role: json['role'] ?? 'EMPLOYEE',
        isActive: json['is_active'] ?? true,
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'company_id': companyId,
        'employee_code': employeeCode,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
        'is_active': isActive,
    };
}

// Listado de empleados:
class EmployeesListModel {
    final List<EmployeeModel> employees;
    EmployeesListModel({required this.employees});

    factory EmployeesListModel.fromJson(List<dynamic> json) {
        return EmployeesListModel(
            employees: json.map((e) => EmployeeModel.fromJson(e)).toList(),
        );
    }
}