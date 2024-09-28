import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/health_index.dart';
import '../models/user_health_data.dart';
import '../repo/group_repo.dart';
import '../repo/user_health_data_repo.dart';
import '../utils/calculator.dart';
import 'result_screen.dart';

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

  Future<void> _loadGroups() async {
    final groups = await _groupRepo.fetchGroups();
    setState(() {
      _groups = groups;
    });
  }

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

  void _viewUserResult(HealthIndex healthIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(healthIndex: healthIndex),
      ),
    );
  }

  void _addGroup() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Додати групу'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва групи'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Відміна'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _groupRepo.insertGroup(Group(name: name));
                  await _loadGroups();
                  Navigator.pop(context);
                }
              },
              child: const Text('Додати'),
            ),
          ],
        );
      },
    );
  }

  void _editGroup(Group group) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: group.name);
        return AlertDialog(
          title: const Text('Редагувати групу'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Назва групи'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Відміна'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _groupRepo.updateGroup(Group(id: group.id, name: name));
                  await _loadGroups();
                  Navigator.pop(context);
                }
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(Group group) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердіть видалення'),
        content: Text('Ви впевнені, що хочете видалити групу "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Відміна'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.redAccent)),
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
      await _loadGroups();
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
              'Управління групами',
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final users = _groupedUsers[group.id] ?? [];
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
                                color: colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    group.name != GroupRepo.defaultGroupName
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: colorScheme.primary),
                                onPressed: () => _editGroup(group),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deleteGroup(group),
                              ),
                            ],
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                children: users.map((user) {
                  var healthIndex = calculateHealthIndex(user.healthData);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${user.firstName} ${user.lastName}'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: healthIndex.healthIndexLevelResult.color,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            healthIndex.index.toStringAsFixed(2),
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
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
                    contentPadding: const EdgeInsets.only(left: 40.0, right: 16.0),
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
