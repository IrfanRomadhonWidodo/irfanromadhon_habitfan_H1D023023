import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/icon_picker.dart';

/// Page for adding or editing a habit
class AddHabitPage extends StatefulWidget {
  final String? editHabitId;

  const AddHabitPage({
    super.key,
    this.editHabitId,
  });

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = '🎯';
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  bool get isEditing => widget.editHabitId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final viewModel = context.read<HabitViewModel>();
    final habit = viewModel.getHabitById(widget.editHabitId!);
    if (habit != null) {
      _nameController.text = habit.name;
      _selectedIcon = habit.icon;
      _reminderEnabled = habit.reminderEnabled;
      if (habit.reminderHour != null && habit.reminderMinute != null) {
        _reminderTime = TimeOfDay(
          hour: habit.reminderHour!,
          minute: habit.reminderMinute!,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kebiasaan' : 'Tambah Kebiasaan'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconSection(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildReminderSection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ikon Kebiasaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedIcon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih ikon yang mewakili kebiasaanmu',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showIconPicker,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Ganti Ikon'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Kebiasaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: Olahraga 30 menit',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(
                Icons.edit_note,
                color: AppTheme.accentColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama kebiasaan tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Nama minimal 3 karakter';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pengingat Harian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
                },
                activeColor: AppTheme.accentColor,
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Waktu Pengingat',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _reminderTime.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu akan menerima notifikasi pengingat setiap hari pada waktu yang dipilih',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isEditing ? 'Simpan Perubahan' : 'Tambah Kebiasaan',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showIconPicker() async {
    final selectedIcon = await showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(
        initialIcon: _selectedIcon,
      ),
    );

    if (selectedIcon != null) {
      setState(() => _selectedIcon = selectedIcon);
    }
  }

  void _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() => _reminderTime = pickedTime);
    }
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<HabitViewModel>();
    final name = _nameController.text.trim();

    if (isEditing) {
      viewModel.updateHabit(
        id: widget.editHabitId!,
        name: name,
        icon: _selectedIcon,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderEnabled ? _reminderTime.hour : null,
        reminderMinute: _reminderEnabled ? _reminderTime.minute : null,
      );
    } else {
      viewModel.addHabit(
        name: name,
        icon: _selectedIcon,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderEnabled ? _reminderTime.hour : null,
        reminderMinute: _reminderEnabled ? _reminderTime.minute : null,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Kebiasaan berhasil diperbarui!'
              : 'Kebiasaan berhasil ditambahkan!',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
