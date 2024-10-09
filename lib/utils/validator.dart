String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ім\'я не може бути порожнім'; // 'Name cannot be empty'
  }
  return null;
}

String? validateAge(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть вік'; // 'Please enter an age'
  }
  final age = int.tryParse(value);
  if (age == null || age <= 0 || age < 13 || age > 100) {
    return 'Вік повинен бути між 13 і 100 роками'; // 'Age must be between 13 and 100 years'
  }
  return null;
}

String? validateHeight(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть зріст'; // 'Please enter height'
  }
  final height = double.tryParse(value);
  if (height == null || height <= 0 || height < 50 || height > 300) {
    return 'Зріст повинен бути між 50 і 300 см'; // 'Height must be between 50 and 300 cm'
  }
  return null;
}

String? validateWeight(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть вагу'; // 'Please enter weight'
  }
  final weight = double.tryParse(value);
  if (weight == null || weight <= 0 || weight < 20 || weight > 500) {
    return 'Вага повинна бути між 20 і 500 кг'; // 'Weight must be between 20 and 500 kg'
  }
  return null;
}

String? validateHeartRate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть частоту пульсу'; // 'Please enter heart rate'
  }
  final heartRate = int.tryParse(value);
  if (heartRate == null || heartRate <= 0 || heartRate < 30 || heartRate > 220) {
    return 'Частота пульсу повинна бути між 30 і 220 уд./хв.'; // 'Heart rate must be between 30 and 220 bpm'
  }
  return null;
}

String? validateSystolicBP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть систолічний тиск'; // 'Please enter systolic BP'
  }
  final systolicBP = int.tryParse(value);
  if (systolicBP == null || systolicBP <= 0 || systolicBP < 90 || systolicBP > 250) {
    return 'Систолічний тиск повинен бути між 90 і 250 мм рт. ст.'; // 'Systolic BP must be between 90 and 250 mmHg'
  }
  return null;
}

String? validateDiastolicBP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введіть діастолічний тиск'; // 'Please enter diastolic BP'
  }
  final diastolicBP = int.tryParse(value);
  if (diastolicBP == null || diastolicBP <= 0 || diastolicBP < 60 || diastolicBP > 150) {
    return 'Діастолічний тиск повинен бути між 60 і 150 мм рт. ст.'; // 'Diastolic BP must be between 60 and 150 mmHg'
  }
  return null;
}
