import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/folder.dart';
import '../models/health_data.dart';
import '../models/user_health_data.dart';
import '../repo/folder_repo.dart';
import '../repo/user_health_data_repo.dart';
import '../utils/calculator.dart';
import '../utils/validator.dart';
import 'folder_management_screen.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  void _showHealthIndexDefinition() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Що таке ІФЗ?'),
          content: const SingleChildScrollView(
            child: Text(
              'Індекс фізичного здоров\'я (ІФЗ) — це комплексний показник, який використовується для оцінки загального стану фізичного здоров\'я людини. '
              'Він враховує такі параметри, як вік, зріст, вага, частота серцевих скорочень та артеріальний тиск. '
              'ІФЗ допомагає визначити рівень фізичної підготовки, виявити можливі ризики для здоров\'я та сприяти плануванню заходів для покращення фізичного стану.\n\n'
              'Зверніть увагу, що ІФЗ є індикативним показником і не замінює професійної медичної консультації. '
              'Для отримання детальної інформації про ваше здоров\'я зверніться до лікаря.',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Закрити'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Очистити форму?'),
          content: const Text('Ви дійсно хочете очистити всі поля?'),
          actions: [
            TextButton(
              child: const Text('Відміна'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Очистити'),
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState?.reset();
                _ageController.clear();
                _heightController.clear();
                _weightController.clear();
                _heartRateController.clear();
                _systolicBPController.clear();
                _diastolicBPController.clear();
                _firstNameController.clear();
                _lastNameController.clear();
                _selectedFolder = _defaultFolder;
                _selectedActivityLevel = null;
              },
            ),
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  // Контролери для полів введення
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  ActivityLevel? _selectedActivityLevel;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final UserHealthDataRepo _usersRepo = UserHealthDataRepo();
  final FolderRepo _folderRepo = FolderRepo();
  List<Folder> _folders = [];
  late Folder _defaultFolder;
  Folder? _selectedFolder;
  bool _saveData = false;

  @override
  void initState() {
    super.initState();
    _loadFolders(); // Load folders and preselect a default
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.fetchFolders();
    var defaultFolder = folders.firstWhere(
      (folder) => folder.name == FolderRepo.defaultFolderName,
      orElse: () => folders.first,
    );
    setState(() {
      _folders = folders;
      _defaultFolder = defaultFolder;
      _selectedFolder = _selectedFolder != null && _folders.contains(_selectedFolder)
          ? _selectedFolder // Keep the previously selected folder if it's still valid
          : defaultFolder;
    });
  }

  void _navigateToFolderManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FolderManagementScreen()),
    );
    await _loadFolders();
  }

  @override
  void dispose() {
    // Звільняємо ресурси
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      try {
        final data = HealthData(
          age: int.parse(_ageController.text),
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          heartRate: int.parse(_heartRateController.text),
          systolicBP: int.parse(_systolicBPController.text),
          diastolicBP: int.parse(_diastolicBPController.text),
          activityLevel: _selectedActivityLevel != null ? ActivityLevel.values.indexOf(_selectedActivityLevel!) + 1 : 1,
        );

        final healthIndex = calculateHealthIndex(data);

        if (_saveData) {
          final userHealthData = UserHealthData(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            healthData: data,
            healthIndex: healthIndex.index,
            folderId: _selectedFolder?.id,
            recordedAt: DateTime.now(),
          );
          _save(userHealthData);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(healthIndex: healthIndex),
          ),
        );
      } catch (e) {
        // Відображення повідомлення про помилку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка розрахунку: ${e.toString()}')),
        );
      }
    }
  }

  void _save(UserHealthData userHealthData) async {
    try {
      await _usersRepo.insertRecord(userHealthData);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дані успішно збережено')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка збереження: ${e.toString()}'),
          duration: const Duration(minutes: 10),
        ),
      );
    }
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allow only numerical input
      ],
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо кольорову схему з теми
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Верхній банер
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 48,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  // Додаємо Row для розміщення тексту та іконки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Розрахунок ІФЗ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Додаємо іконку знака питання
                      GestureDetector(
                        onTap: _showHealthIndexDefinition,
                        child: Icon(
                          Icons.info_outline,
                          color: colorScheme.onPrimary.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Карта з формою
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name fields
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Ім\'я',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: validateName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Прізвище',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: validateLastName,
                        ),
                        const SizedBox(height: 16),
                        // folder selection
                        DropdownButtonFormField<Folder>(
                          value: _selectedFolder,
                          dropdownColor: Theme.of(context).inputDecorationTheme.fillColor,
                          items: _folders.map((folder) {
                            return DropdownMenuItem<Folder>(
                              value: folder,
                              child: Text(folder.name),
                            );
                          }).toList(),
                          onChanged: (folder) {
                            setState(() {
                              _selectedFolder = folder;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Тека',
                            prefixIcon: Icon(Icons.group),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Зберегти дані'),
                                value: _saveData,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _saveData = value ?? false;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _navigateToFolderManagement,
                                  child: const Text('Управління теками'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Arrange numerical fields in a grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double widthLimit = 200;
                            int numOfColumns = 3;
                            final fieldWidth =
                                (constraints.maxWidth - 32) / numOfColumns; // Adjust for padding and spacing
                            final List<Widget> fields = [
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _ageController,
                                  label: 'Вік',
                                  hint: 'Введіть ваш вік (років)',
                                  icon: Icons.cake,
                                  validator: validateAge,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _heightController,
                                  label: 'Зріст',
                                  hint: 'Введіть ваш зріст (см)',
                                  icon: Icons.height,
                                  validator: validateHeight,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _weightController,
                                  label: 'Вага',
                                  hint: 'Введіть вашу вагу (кг)',
                                  icon: Icons.monitor_weight,
                                  validator: validateWeight,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _heartRateController,
                                  label: 'ЧСС',
                                  hint: 'Введіть ЧСС (уд/хв)',
                                  icon: Icons.favorite,
                                  validator: validateHeartRate,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _systolicBPController,
                                  label: 'Систолічний АТ',
                                  hint: 'Введіть систолічний АТ (мм рт. ст.)',
                                  icon: Icons.arrow_upward,
                                  validator: validateSystolicBP,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth > widthLimit ? fieldWidth : widthLimit,
                                child: _buildCompactTextField(
                                  controller: _diastolicBPController,
                                  label: 'Діастолічний АТ',
                                  hint: 'Введіть діастолічний АТ (мм рт. ст.)',
                                  icon: Icons.arrow_downward,
                                  validator: validateDiastolicBP,
                                ),
                              ),
                              DropdownButtonFormField<ActivityLevel>(
                                value: _selectedActivityLevel,
                                isExpanded: true,
                                dropdownColor: Theme.of(context).inputDecorationTheme.fillColor,
                                items: ActivityLevel.values.map((ActivityLevel level) {
                                  return DropdownMenuItem<ActivityLevel>(
                                    value: level,
                                    child: Text(activityLevelDescriptions[level]!),
                                  );
                                }).toList(),
                                onChanged: (ActivityLevel? newValue) {
                                  setState(() {
                                    _selectedActivityLevel = newValue;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Рівень рухової активності',
                                  prefixIcon: Icon(Icons.fitness_center),
                                ),
                                validator: (value) => value == null ? 'Будь ласка, виберіть рівень активності' : null,
                              ),
                            ];

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: fields,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Buttons at the bottom of the form
                        Row(
                          children: [
                            // Кнопка "Розрахувати"
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _calculate,
                                icon: const Icon(Icons.calculate),
                                label: const Text(
                                  'Розрахувати',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size.fromHeight(56),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Кнопка очищення форми
                            Tooltip(
                              message: 'Очистити форму',
                              child: ElevatedButton(
                                onPressed: _clearForm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(56, 56),
                                ),
                                child: const Icon(Icons.delete),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
