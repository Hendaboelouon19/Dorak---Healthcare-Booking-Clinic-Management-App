import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NotificationTemplatesScreen extends StatefulWidget {
  const NotificationTemplatesScreen({super.key});

  @override
  State<NotificationTemplatesScreen> createState() =>
      _NotificationTemplatesScreenState();
}

class _NotificationTemplatesScreenState
    extends State<NotificationTemplatesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // ===========================================================================
  // LOAD TEMPLATES
  // ===========================================================================

  Future<void> _loadTemplates() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final snapshot = await _firestore
          .collection('notificationTemplates')
          .orderBy('name')
          .get();

      final templates = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _templates = templates;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'Failed to load notification templates.';
      });
    }
  }

  // ===========================================================================
  // CREATE TEMPLATE
  // ===========================================================================

  Future<void> _createTemplate() async {
    final result = await _showTemplateDialog();

    if (result == null) return;

    try {
      await _firestore
          .collection('notificationTemplates')
          .add({
        'name': result['name'],
        'event': result['event'],
        'title': result['title'],
        'message': result['message'],
        'active': result['active'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadTemplates();

      if (!mounted) return;

      _showMessage(
        'Notification template created successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to create notification template.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // EDIT TEMPLATE
  // ===========================================================================

  Future<void> _editTemplate(
    Map<String, dynamic> template,
  ) async {
    final result = await _showTemplateDialog(
      template: template,
    );

    if (result == null) return;

    try {
      await _firestore
          .collection('notificationTemplates')
          .doc(template['id'])
          .update({
        'name': result['name'],
        'event': result['event'],
        'title': result['title'],
        'message': result['message'],
        'active': result['active'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadTemplates();

      if (!mounted) return;

      _showMessage(
        'Notification template updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update notification template.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // DELETE TEMPLATE
  // ===========================================================================

  Future<void> _deleteTemplate(
    Map<String, dynamic> template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Template?'),
          content: Text(
            'Are you sure you want to delete '
            '"${template['name']}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firestore
          .collection('notificationTemplates')
          .doc(template['id'])
          .delete();

      await _loadTemplates();

      if (!mounted) return;

      _showMessage(
        'Notification template deleted.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete notification template.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // TOGGLE ACTIVE
  // ===========================================================================

  Future<void> _toggleActive(
    Map<String, dynamic> template,
  ) async {
    final currentActive = template['active'] == true;

    try {
      await _firestore
          .collection('notificationTemplates')
          .doc(template['id'])
          .update({
        'active': !currentActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadTemplates();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update template status.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // TEMPLATE DIALOG
  // ===========================================================================

  Future<Map<String, dynamic>?> _showTemplateDialog({
    Map<String, dynamic>? template,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return _TemplateDialog(
          template: template,
        );
      },
    );
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : AppColors.successGreen,
      ),
    );
  }

  // ===========================================================================
  // BACK
  // ===========================================================================

  void _goBack() {
    Navigator.of(context).pop();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: const Text('Notification Templates'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadTemplates,
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _createTemplate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Template'),
      ),
      body: _buildBody(),
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_templates.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          100,
        ),
        children: [
          // -------------------------------------------------------------------
          // INTRO
          // -------------------------------------------------------------------

          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(
                alpha: 0.06,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(
                  alpha: 0.15,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primaryBlue,
                  size: 23,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manage the notification messages used '
                    'for queue alerts, appointment updates, '
                    'and reminders.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // SECTION TITLE
          // -------------------------------------------------------------------

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Templates',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_templates.length} templates',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // TEMPLATES
          // -------------------------------------------------------------------

          ..._templates.map(
            (template) {
              return _TemplateCard(
                template: template,
                onEdit: () {
                  _editTemplate(template);
                },
                onDelete: () {
                  _deleteTemplate(template);
                },
                onToggle: () {
                  _toggleActive(template);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.notifications_none_rounded,
            size: 70,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'No notification templates yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Create your first notification template '
              'to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: _createTemplate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Template'),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TEMPLATE DIALOG
// ============================================================================

class _TemplateDialog extends StatefulWidget {
  const _TemplateDialog({
    this.template,
  });

  final Map<String, dynamic>? template;

  @override
  State<_TemplateDialog> createState() =>
      _TemplateDialogState();
}

class _TemplateDialogState
    extends State<_TemplateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _eventController;
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late bool _active;

  @override
  void initState() {
    super.initState();

    final template = widget.template;

    _nameController = TextEditingController(
      text: template?['name']?.toString() ?? '',
    );

    _eventController = TextEditingController(
      text: template?['event']?.toString() ?? '',
    );

    _titleController = TextEditingController(
      text: template?['title']?.toString() ?? '',
    );

    _messageController = TextEditingController(
      text: template?['message']?.toString() ?? '',
    );

    _active = template?['active'] != false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _eventController.dispose();
    _titleController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'event': _eventController.text.trim(),
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'active': _active,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.template != null;

    return AlertDialog(
      title: Text(
        editing
            ? 'Edit Notification Template'
            : 'Create Notification Template',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============================================================
                // NAME
                // ============================================================

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText:
                        'Appointment Confirmation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a template name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ============================================================
                // EVENT
                // ============================================================

                TextFormField(
                  controller: _eventController,
                  decoration: const InputDecoration(
                    labelText: 'Event',
                    hintText:
                        'appointment_confirmed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the event.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ============================================================
                // TITLE
                // ============================================================

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Title',
                    hintText:
                        'Appointment Confirmed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the notification title.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ============================================================
                // MESSAGE
                // ============================================================

                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notification Message',
                    hintText:
                        'Your appointment has been confirmed successfully.',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the notification message.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // ============================================================
                // ACTIVE
                // ============================================================

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Active',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Use this template for notifications.',
                  ),
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            editing ? 'Save' : 'Create',
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TEMPLATE CARD
// ============================================================================

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final Map<String, dynamic> template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final bool active = template['active'] == true;

    final String name =
        template['name']?.toString() ??
            'Untitled Template';

    final String event =
        template['event']?.toString() ??
            'Unknown event';

    final String title =
        template['title']?.toString() ?? '';

    final String message =
        template['message']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ================================================================
            // HEADER
            // ================================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryBlue.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event,
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.successGreen
                            .withValues(alpha: 0.10)
                        : Colors.grey.withValues(
                            alpha: 0.10,
                          ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: active
                          ? AppColors.successGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================================================================
            // NOTIFICATION PREVIEW
            // ================================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================================================================
            // ACTIONS
            // ================================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggle,
                    icon: Icon(
                      active
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                    ),
                    label: Text(
                      active
                          ? 'Deactivate'
                          : 'Activate',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                  ),
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}