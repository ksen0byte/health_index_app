String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ім\'я не може бути порожнім'; // 'Name cannot be empty'
  }
  return null;
}

String? validateLastName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Прізвище не може бути порожнім'; // 'Last Name cannot be empty'
  }
  return null;
}

String? validateAge(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть вік'; // 'Please enter an age'
  }
  final age = int.tryParse(value);
  if (age == null || age <= 0 || age < 13 || age > 59) {
    return 'Вік повинен бути між 13 і 59 роками'; // 'Age must be between 13 and 59 years'
  }
  return null;
}

String? validateHeight(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть зріст'; // 'Please enter height'
  }
  final height = double.tryParse(value);
  if (height == null || height <= 0 || height < 120 || height > 220) {
    return 'Зріст повинен бути між 120 і 220 см'; // 'Height must be between 120 and 220 cm'
  }
  return null;
}

String? validateWeight(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть вагу'; // 'Please enter weight'
  }
  final weight = double.tryParse(value);
  if (weight == null || weight <= 0 || weight < 30 || weight > 150) {
    return 'Вага повинна бути між 30 і 150 кг'; // 'Weight must be between 30 and 150 kg'
  }
  return null;
}

String? validateHeartRate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть частоту пульсу'; // 'Please enter heart rate'
  }
  final heartRate = int.tryParse(value);
  if (heartRate == null || heartRate <= 0 || heartRate < 40 || heartRate > 140) {
    return 'Частота пульсу повинна бути між 40 і 140 уд./хв.'; // 'Heart rate must be between 40 and 140 bpm'
  }
  return null;
}

String? validateSystolicBP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть систолічний тиск'; // 'Please enter systolic BP'
  }
  final systolicBP = int.tryParse(value);
  if (systolicBP == null || systolicBP <= 0 || systolicBP < 80 || systolicBP > 160) {
    return 'Систолічний тиск повинен бути між 80 і 160 мм рт. ст.'; // 'Systolic BP must be between 80 and 160 mmHg'
  }
  return null;
}

String? validateDiastolicBP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть діастолічний тиск'; // 'Please enter diastolic BP'
  }
  final diastolicBP = int.tryParse(value);
  if (diastolicBP == null || diastolicBP <= 0 || diastolicBP < 50 || diastolicBP > 110) {
    return 'Діастолічний тиск повинен бути між 50 і 110 мм рт. ст.'; // 'Diastolic BP must be between 50 and 110 mmHg'
  }
  return null;
}

String? validateActivityLevel(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть рівень рухової активності'; // 'Please enter activity level'
  }
  final diastolicBP = int.tryParse(value);
  if (diastolicBP == null || diastolicBP <= 0 || diastolicBP < 1 || diastolicBP > 7) {
    return 'Рівень рухової активності повинен бути між 1 та 7 балів'; // 'Activity level must be between 1 and 7 points'
  }
  return null;
}
