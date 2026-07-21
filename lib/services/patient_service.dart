import '../models/user_profile.dart';
import '../models/family_member.dart';
import '../models/patient.dart';

class PatientService {
  List<Patient> getPatients(UserProfile user, List<FamilyMember> familyMembers) {
    return [
      Patient(
        id: 'self',
        name: user.name,
        relationLabel: 'diri sendiri',
      ),
      ...familyMembers.map((m) => Patient(
            id: m.id,
            name: m.name,
            relationLabel: m.relation,
          )),
    ];
  }
}
