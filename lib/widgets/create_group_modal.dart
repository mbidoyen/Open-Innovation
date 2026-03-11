import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class CreateGroupModal extends StatefulWidget {
  final AppUser currentUser;
  final void Function(Group group) onCreate;

  const CreateGroupModal({
    super.key,
    required this.currentUser,
    required this.onCreate,
  });

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends State<CreateGroupModal> {
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  late List<AppUser> _selectedMembers;
  String? _memberError;

  @override
  void initState() {
    super.initState();
    _selectedMembers = [widget.currentUser];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _selectedMembers.isNotEmpty;

  void _addMember() {
    final input = _memberController.text.trim().toLowerCase();
    if (input.isEmpty) return;

    // Check in mock users
    final user = MockData.users.where((u) {
      return u.email.toLowerCase() == input ||
          u.name.toLowerCase() == input;
    }).firstOrNull;

    if (user == null) {
      setState(() => _memberError = 'Utilisateur introuvable : "$input"');
      return;
    }

    if (_selectedMembers.any((m) => m.id == user.id)) {
      setState(() => _memberError = '${user.name} est déjà dans le groupe.');
      return;
    }

    setState(() {
      _selectedMembers.add(user);
      _memberController.clear();
      _memberError = null;
    });
  }

  void _removeMember(AppUser user) {
    if (user.id == widget.currentUser.id) return;
    setState(() => _selectedMembers.remove(user));
  }

  void _submit() {
    if (!_isValid) return;

    final group = Group(
      DateTime.now().millisecondsSinceEpoch.toString(),
      _nameController.text.trim(),
      List<AppUser>.from(_selectedMembers),
      DateTime.now(),
    );

    widget.onCreate(group);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Créer un groupe',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Créez un groupe et invitez des membres.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Group name
          _buildLabel('Nom du groupe'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Ex: Colocation, Voyage...',
                hintStyle:
                    TextStyle(color: AppColors.textMuted, fontSize: 15),
                prefixIcon: Icon(Icons.group_rounded,
                    color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Members
          _buildLabel('Membres'),
          const SizedBox(height: 12),

          // Current members chips
          if (_selectedMembers.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedMembers.asMap().entries.map((entry) {
                final member = entry.value;
                final isCurrentUser = member.id == widget.currentUser.id;
                final colors = AppColors.getAvatarColor(
                    MockData.users.indexWhere((u) => u.id == member.id)
                        .clamp(0, 4));

                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: colors['bg'],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors['border']!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          color: colors['text'],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isCurrentUser) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeMember(member),
                          child: Icon(
                            Icons.close_rounded,
                            color: colors['text'],
                            size: 14,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star_rounded,
                          color: colors['text'],
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Add member input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _memberError != null
                          ? AppColors.errorBorder
                          : AppColors.borderMedium,
                    ),
                  ),
                  child: TextField(
                    controller: _memberController,
                    onChanged: (_) =>
                        setState(() => _memberError = null),
                    onSubmitted: (_) => _addMember(),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Email ou nom du membre',
                      hintStyle: TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.person_add_outlined,
                          color: AppColors.textMuted, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addMember,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),

          if (_memberError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Text(
                  _memberError!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12),
                ),
              ],
            ),
          ],

          const SizedBox(height: 6),
          Text(
            'Essayez : marie@exemple.com, thomas@exemple.com, sophie@exemple.com',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: const Center(
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _isValid ? _submit : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isValid ? 1.0 : 0.5,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Créer le groupe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
