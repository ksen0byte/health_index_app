// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:health_index_app/utils/export.dart';

import '../models/group.dart';
import '../models/health_index.dart';
import '../models/user_health_data.dart';
import '../repo/group_repo.dart';
import '../repo/user_health_data_repo.dart';
import '../utils/calculator.dart';
import '../utils/csv_generator.dart';
import 'result_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GroupManagementScreenState createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final UserHealthDataRepo _usersRepo = UserHealthDataRepo();
  final GroupRepo _groupRepo = GroupRepo();

  List<Group> _groups = [];
  Map<int, List<UserHealthData>> _groupedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadGroupsAndUsers();
  }

  /// Loads both groups and users, grouping users by their group IDs.
  Future<void> _loadGroupsAndUsers() async {
    final groups = await _groupRepo.fetchGroups();
    final users = await _usersRepo.fetchRecords();

    // Group users by groupId
    Map<int, List<UserHealthData>> groupedUsers = {};
    for (var group in groups) {
      groupedUsers[group.id!] = [];
    }
    for (var user in users) {
      if (user.groupId != null && groupedUsers.containsKey(user.groupId)) {
        groupedUsers[user.groupId!]!.add(user);
      } else {
        // If groupId is null or not found, assign to default group
        final defaultGroup = await _groupRepo.getDefaultGroup();
        user.groupId = defaultGroup.id;
        groupedUsers[defaultGroup.id!]!.add(user);
      }
    }

    setState(() {
      _groups = groups;
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

  /// Displays a dialog to add a new group.
  void _addGroup() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Додати групу'), // 'Add Group'
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва групи'), // 'Group Name'
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
                  await _groupRepo.insertGroup(Group(name: name));
                  await _loadGroupsAndUsers();
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

  /// Displays a dialog to edit an existing group's name.
  void _editGroup(Group group) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: group.name);
        return AlertDialog(
          title: const Text('Редагувати групу'), // 'Edit Group'
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва групи'), // 'Group Name'
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
                  await _groupRepo.updateGroup(Group(id: group.id, name: name));
                  await _loadGroupsAndUsers();
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

      String csvData = await generateUserDataCSV(await _usersRepo.fetchRecordsByGroups([]));

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

  // Export data for a specific group
  void _exportGroupData(Group group) async {
    try {
      var saveLocation = await chooseSaveLocation("group_${group.name.replaceAll(' ', '_')}");
      if (saveLocation == null) {
        // Operation was canceled by the user.
        return;
      }

      String csvData = await generateUserDataCSV(await _usersRepo.fetchRecordsByGroups([group.id!]));

      await saveCsv(saveLocation, csvData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дані для групи "${group.name}" успішно експортовано до ${saveLocation.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося експортувати дані: $e')),
      );
    }
  }

  /// Deletes a group after confirmation, transferring its users to the default group.
  void _deleteGroup(Group group) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердіть видалення'), // 'Confirm Deletion'
        content: Text(
            'Ви впевнені, що хочете видалити групу "${group.name}"?'), // 'Are you sure you want to delete the group "${group.name}"?'
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
      // Transfer users to default group
      final defaultGroup = await _groupRepo.getDefaultGroup();
      await _usersRepo.transferUsersToDefaultGroup(group.id!, defaultGroup.id!);

      // Delete the group
      await _groupRepo.deleteGroup(group.id!);
      await _loadGroupsAndUsers();
    }
  }

  void _editUser(UserHealthData user) {
    showDialog(
      context: context,
      builder: (context) {
        final firstNameController = TextEditingController(text: user.firstName);
        final lastNameController = TextEditingController(text: user.lastName);
        Group? selectedGroup = _groups.firstWhere((group) => group.id == user.groupId, orElse: () => _groups.first);

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
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Прізвище'), // 'Last Name'
                ),
                DropdownButtonFormField<Group>(
                  value: selectedGroup,
                  items: _groups.map((group) {
                    return DropdownMenuItem<Group>(
                      value: group,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (group) {
                    selectedGroup = group;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Група', // 'Group'
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
                  user.groupId = selectedGroup?.id;
                  await _usersRepo.updateRecord(user);
                  await _loadGroupsAndUsers();
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
      await _loadGroupsAndUsers();
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
              'Управління групами', // 'Group Management'
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
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final users = _groupedUsers[group.id] ?? [];
          final isNotDefaultGroup = group.name != GroupRepo.defaultGroupName;
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
                    // Group name with user count
                    RichText(
                      text: TextSpan(
                        text: group.name,
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
                    // Edit/Delete buttons for groups (except default group)
                    // Actions for the group
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _editGroup(group);
                            } else if (value == 'delete') {
                              _deleteGroup(group);
                            } else if (value == 'export') {
                              _exportGroupData(group);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (isNotDefaultGroup)
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: colorScheme.primary),
                                  title: const Text('Редагувати групу'), // 'Edit Group'
                                ),
                              ),
                            PopupMenuItem<String>(
                              value: 'export',
                              child: ListTile(
                                leading: Icon(Icons.download, color: colorScheme.primary),
                                title: const Text('Експортувати дані'), // 'Export Data'
                              ),
                            ),
                            if (isNotDefaultGroup)
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.redAccent),
                                  title: Text('Видалити групу'), // 'Delete Group'
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Users in each group
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
                      backgroundColor: colorScheme.surface,
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
        onPressed: _addGroup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
