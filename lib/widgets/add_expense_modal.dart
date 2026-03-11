import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class AddExpenseModal extends StatefulWidget {
  final Group group;
  final AppUser currentUser;
  final void Function(Expense expense) onAdd;

  const AddExpenseModal({
    super.key,
    required this.group,
    required this.currentUser,
    required this.onAdd,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  late String _paidBy;
  late List<String> _splitBetween;
  bool _isRecurring = false;
  int _recurringDay = 1;
  String _category = 'other';

  final List<Map<String, String>> _categories = [
    {'value': 'housing', 'label': '🏠 Logement'},
    {'value': 'streaming', 'label': '🎬 Streaming'},
    {'value': 'utilities', 'label': '⚡ Charges'},
    {'value': 'music', 'label': '🎵 Musique'},
    {'value': 'food', 'label': '🛒 Courses'},
    {'value': 'restaurant', 'label': '🍽️ Restaurant'},
    {'value': 'transport', 'label': '🚗 Transport'},
    {'value': 'other', 'label': '💳 Autre'},
  ];

  @override
  void initState() {
    super.initState();
    _paidBy = widget.currentUser.id;
    _splitBetween = widget.group.members.map((m) => m.id).toList();
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _descController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty &&
        double.tryParse(_amountController.text.replaceAll(',', '.')) != null &&
        _splitBetween.isNotEmpty;
  }

  void _submit() {
    if (!_isValid) return;

    final expense = Expense(
      DateTime.now().millisecondsSinceEpoch.toString(),
      widget.group.id,
      _descController.text.trim(),
      double.parse(_amountController.text.replaceAll(',', '.')),
      _paidBy,
      List<String>.from(_splitBetween),
      DateTime.now(),
      _isRecurring,
      _isRecurring ? _recurringDay : null,
      _isRecurring ? _category : null,
    );

    widget.onAdd(expense);
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
                'Ajouter une dépense',
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
          Text(
            widget.group.name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          _buildLabel('Description'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descController,
            hint: 'Ex: Netflix, Loyer...',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 16),

          // Amount
          _buildLabel('Montant (€)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _amountController,
            hint: '0.00',
            icon: Icons.euro_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),

          // Paid by
          _buildLabel('Payé par'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _paidBy,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              items: widget.group.members.map((member) {
                return DropdownMenuItem<String>(
                  value: member.id,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _paidBy = value);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Split between
          _buildLabel('Partagé entre'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.group.members.map((member) {
              final isSelected = _splitBetween.contains(member.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _splitBetween.remove(member.id);
                    } else {
                      _splitBetween.add(member.id);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBg : AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderMedium,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 14),
                      if (isSelected) const SizedBox(width: 6),
                      Text(
                        member.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Recurring toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isRecurring ? AppColors.primaryBg : AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecurring ? AppColors.primary : AppColors.borderMedium,
                width: _isRecurring ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.refresh_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Dépense récurrente',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryBg,
                ),
              ],
            ),
          ),

          if (_isRecurring) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Jour du mois'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderMedium),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<int>(
                          value: _recurringDay,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          items: List.generate(
                            28,
                            (i) => DropdownMenuItem<int>(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            ),
                          ),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _recurringDay = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Catégorie'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderMedium),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['value']!,
                              child: Text(cat['label']!),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _category = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

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
                          'Ajouter',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 15),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
