// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:health_index_app/utils/export.dart';

import '../models/folder.dart';
import '../models/health_index.dart';
import '../models/user_health_data.dart';
import '../repo/folder_repo.dart';
import '../repo/user_health_data_repo.dart';
import '../utils/calculator.dart';
import '../utils/csv_generator.dart';
import 'result_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class FolderManagementScreen extends StatefulWidget {
  const FolderManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FolderManagementScreenState createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  final UserHealthDataRepo _usersRepo = UserHealthDataRepo();
  final FolderRepo _folderRepo = FolderRepo();

  List<Folder> _folders = [];
  Map<int, List<UserHealthData>> _groupedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadFoldersAndUsers();
  }

  /// Loads both fodlers and users, grouping users by their folder IDs.
  Future<void> _loadFoldersAndUsers() async {
    final folders = await _folderRepo.fetchFolders();
    final users = await _usersRepo.fetchRecords();

    // Group users by folderId
    Map<int, List<UserHealthData>> groupedUsers = {};
    for (var folder in folders) {
      groupedUsers[folder.id!] = [];
    }
    for (var user in users) {
      if (user.folderId != null && groupedUsers.containsKey(user.folderId)) {
        groupedUsers[user.folderId!]!.add(user);
      } else {
        // If folderId is null or not found, assign to default folder
        final defaultFolder = await _folderRepo.getDefaultFolder();
        user.folderId = defaultFolder.id;
        groupedUsers[defaultFolder.id!]!.add(user);
      }
    }

    setState(() {
      _folders = folders;
      _groupedUsers = groupedUsers;
    });
  }

  /// Navigates to the result screen to display detailed health index information.
  void _viewUserResult(HealthIndex healthIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(healthIndex: healthIndex),
      ),
    );
  }

  /// Displays a dialog to add a new folder.
  void _addFolder() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Додати теку'), // 'Add Folder'
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва теки'), // 'Folder Name'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Відміна'), // 'Cancel'
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _folderRepo.insertFolder(Folder(name: name));
                  await _loadFoldersAndUsers();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Додати'), // 'Add'
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to edit an existing folder's name.
  void _editFolder(Folder folder) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: folder.name);
        return AlertDialog(
          title: const Text('Редагувати теку'), // 'Edit Folder'
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва теки'), // 'Folder Name'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Відміна'), // 'Cancel'
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _folderRepo.updateFolder(Folder(id: folder.id, name: name));
                  await _loadFoldersAndUsers();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Зберегти'), // 'Save'
            ),
          ],
        );
      },
    );
  }

  // Export all data
  void _exportAllData() async {
    try {
      var saveLocation = await chooseSaveLocation("all_data");
      if (saveLocation == null) {
        // Operation was canceled by the user.
        return;
      }

      String csvData = await generateUserDataCSV(await _usersRepo.fetchRecordsByFolders([]));

      await saveCsv(saveLocation, csvData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дані успішно експортовано до ${saveLocation.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося експортувати дані: $e')),
      );
    }
  }

  // Export data for a specific folder
  void _exportFolderData(Folder folder) async {
    try {
      var saveLocation = await chooseSaveLocation("folder_${folder.name.replaceAll(' ', '_')}");
      if (saveLocation == null) {
        // Operation was canceled by the user.
        return;
      }

      String csvData = await generateUserDataCSV(await _usersRepo.fetchRecordsByFolders([folder.id!]));

      await saveCsv(saveLocation, csvData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дані теки "${folder.name}" успішно експортовано до ${saveLocation.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося експортувати дані: $e')),
      );
    }
  }

  /// Deletes a folder after confirmation, transferring its users to the default folder.
  void _deleteFolder(Folder folder) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердіть видалення'), // 'Confirm Deletion'
        content: Text(
            'Ви впевнені, що хочете видалити теку "${folder.name}"?'), // 'Are you sure you want to delete the folder "${folder.name}"?'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Відміна'), // 'Cancel'
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.redAccent)), // 'Delete'
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Transfer users to default folder
      final defaultFolder = await _folderRepo.getDefaultFolder();
      await _usersRepo.transferUsersToDefaultFolder(folder.id!, defaultFolder.id!);

      // Delete the folder
      await _folderRepo.deleteFolder(folder.id!);
      await _loadFoldersAndUsers();
    }
  }

  void _editUser(UserHealthData user) {
    showDialog(
      context: context,
      builder: (context) {
        final firstNameController = TextEditingController(text: user.firstName);
        final lastNameController = TextEditingController(text: user.lastName);
        Folder? selectedFolder = _folders.firstWhere((folder) => folder.id == user.folderId, orElse: () => _folders.first);
        const spacing = 8.0;

        return AlertDialog(
          title: const Text('Редагувати користувача'), // 'Edit User'
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Ім\'я'), // 'First Name'
                ),
                const SizedBox(height: spacing),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Прізвище'), // 'Last Name'
                ),
                const SizedBox(height: spacing),
                DropdownButtonFormField<Folder>(
                  value: selectedFolder,
                  items: _folders.map((folder) {
                    return DropdownMenuItem<Folder>(
                      value: folder,
                      child: Text(folder.name),
                    );
                  }).toList(),
                  onChanged: (folder) {
                    selectedFolder = folder;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Тека', // 'Folder'
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Відміна'), // 'Cancel'
            ),
            TextButton(
              onPressed: () async {
                final firstName = firstNameController.text.trim();
                final lastName = lastNameController.text.trim();
                if (firstName.isNotEmpty && lastName.isNotEmpty) {
                  user.firstName = firstName;
                  user.lastName = lastName;
                  user.folderId = selectedFolder?.id;
                  await _usersRepo.updateRecord(user);
                  await _loadFoldersAndUsers();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Зберегти'), // 'Save'
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(UserHealthData user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердіть видалення'), // 'Confirm Deletion'
        content: Text(
            'Ви впевнені, що хочете видалити користувача "${user.firstName} ${user.lastName}"?'), // 'Are you sure you want to delete the user "FirstName LastName"?'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Відміна'), // 'Cancel'
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.redAccent)), // 'Delete'
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _usersRepo.softDeleteRecord(user.id!);
      await _loadFoldersAndUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Row(
          children: [
            Icon(
              Icons.group,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'Управління теками', // 'Folder Management'
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Експортувати всі дані', // 'Export All Data'
            child: IconButton(
              icon: const Icon(Icons.download),
              color: colorScheme.onPrimary,
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              onPressed: _exportAllData,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          final users = _groupedUsers[folder.id] ?? [];
          final isNotDefaultFolder = folder.name != FolderRepo.defaultFolderName;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.group, color: colorScheme.primary),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Folder name with user count
                    RichText(
                      text: TextSpan(
                        text: folder.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        children: [
                          TextSpan(
                            text: ' (${users.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit/Delete buttons for folders (except default folder)
                    // Actions for the folder
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _editFolder(folder);
                            } else if (value == 'delete') {
                              _deleteFolder(folder);
                            } else if (value == 'export') {
                              _exportFolderData(folder);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (isNotDefaultFolder)
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: colorScheme.primary),
                                  title: const Text('Редагувати теку'), // 'Edit folder'
                                ),
                              ),
                            PopupMenuItem<String>(
                              value: 'export',
                              child: ListTile(
                                leading: Icon(Icons.download, color: colorScheme.primary),
                                title: const Text('Експортувати дані'), // 'Export Data'
                              ),
                            ),
                            if (isNotDefaultFolder)
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.redAccent),
                                  title: Text('Видалити теку'), // 'Delete folder'
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Users in each folder
                children: users.sorted((a, b) {
                  int lastNameComparison = a.lastName.compareTo(b.lastName);
                  if (lastNameComparison != 0) return lastNameComparison;

                  int firstNameComparison = a.firstName.compareTo(b.firstName);
                  if (firstNameComparison != 0) return firstNameComparison;

                  // For descending order of recordedAt, reverse the comparison
                  return b.recordedAt.compareTo(a.recordedAt);
                }).map((user) {
                  var healthIndex = calculateHealthIndex(user.healthData);

                  // Format the recorded date
                  String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(user.recordedAt);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, color: colorScheme.onSurface.withOpacity(0.7), size: 20),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User's full name
                        Text(
                          '${user.lastName} ${user.firstName}',
                          style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.9)),
                        ),
                        // Health index display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: healthIndex.healthIndexLevelResult.color.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            healthIndex.index.toStringAsFixed(2),
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '$formattedDate | '
                      '${user.healthData.age} років, ${user.healthData.height} см, ${user.healthData.weight} кг, '
                      '${user.healthData.heartRate} уд/хв, ${user.healthData.systolicBP}/${user.healthData.diastolicBP} мм.рт.ст., '
                      'РРА: ${user.healthData.activityLevel} балів',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'edit') {
                          _editUser(user);
                        } else if (value == 'delete') {
                          _deleteUser(user);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: colorScheme.primary),
                            title: const Text('Редагувати'), // 'Edit'
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.redAccent),
                            title: Text('Видалити'), // 'Delete'
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.only(left: 56.0, right: 8.0),
                    onTap: () => _viewUserResult(healthIndex),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
