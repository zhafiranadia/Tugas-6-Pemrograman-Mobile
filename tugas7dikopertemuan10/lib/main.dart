import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Mahasiswa Validasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FormMahasiswaPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FormMahasiswaPage extends StatefulWidget {
  const FormMahasiswaPage({Key? key}) : super(key: key);

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController(text: 'Zhafira Nadia Veranita');
  final _emailController = TextEditingController();
  final _nomorHPController = TextEditingController();

  // Data
  String? _selectedJurusan;
  double _semester = 1;
  final Map<String, bool> _hobi = {
    'Membaca': false,
    'Olahraga': false,
    'Musik': false,
    'Gaming': false,
    'Traveling': false,
  };
  bool _persetujuan = false;

  final List<String> _jurusanList = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Elektro',
    'Teknik Mesin',
    'Manajemen',
    'Akuntansi',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nomorHPController.dispose();
    super.dispose();
  }

  String? _validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateNomorHP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor HP harus 10-13 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor HP hanya boleh angka';
    }
    return null;
  }

  String? _validateJurusan() {
    if (_selectedJurusan == null) {
      return 'Pilih jurusan terlebih dahulu';
    }
    return null;
  }

  String? _validateHobi() {
    if (!_hobi.values.any((element) => element)) {
      return 'Pilih minimal satu hobi';
    }
    return null;
  }

  String? _validatePersetujuan() {
    if (!_persetujuan) {
      return 'Anda harus menyetujui syarat dan ketentuan';
    }
    return null;
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _validateNama(_namaController.text) == null &&
            _validateEmail(_emailController.text) == null &&
            _validateNomorHP(_nomorHPController.text) == null;
      case 1:
        return _validateJurusan() == null && _validateHobi() == null;
      case 2:
        return _validatePersetujuan() == null;
      default:
        return false;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _persetujuan) {
      final selectedHobi = _hobi.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Mahasiswa'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama: ${_namaController.text}'),
                Text('Email: ${_emailController.text}'),
                Text('Nomor HP: ${_nomorHPController.text}'),
                Text('Jurusan: $_selectedJurusan'),
                Text('Semester: ${_semester.toInt()}'),
                Text('Hobi: ${selectedHobi.join(', ')}'),
                Text('Persetujuan: ${_persetujuan ? "Ya" : "Tidak"}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Data Pribadi'),
        content: Column(
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: _validateNama,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomorHPController,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: _validateNomorHP,
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Data Akademik'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedJurusan,
              decoration: const InputDecoration(
                labelText: 'Jurusan',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: _jurusanList.map((jurusan) {
                return DropdownMenuItem(
                  value: jurusan,
                  child: Text(jurusan),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJurusan = value;
                });
              },
              validator: (value) => _validateJurusan(),
            ),
            const SizedBox(height: 24),
            Text(
              'Semester: ${_semester.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _semester,
              min: 1,
              max: 8,
              divisions: 7,
              label: _semester.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _semester = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Hobi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ..._hobi.keys.map((hobi) {
              return CheckboxListTile(
                title: Text(hobi),
                value: _hobi[hobi],
                onChanged: (value) {
                  setState(() {
                    _hobi[hobi] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
            if (_validateHobi() != null && _currentStep == 1)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  _validateHobi()!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Konfirmasi'),
        content: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Data:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildSummaryRow('Nama', _namaController.text),
                    _buildSummaryRow('Email', _emailController.text),
                    _buildSummaryRow('Nomor HP', _nomorHPController.text),
                    _buildSummaryRow('Jurusan', _selectedJurusan ?? '-'),
                    _buildSummaryRow('Semester', _semester.toInt().toString()),
                    _buildSummaryRow(
                      'Hobi',
                      _hobi.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .join(', ') ??
                          '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Saya menyetujui syarat dan ketentuan'),
              value: _persetujuan,
              onChanged: (value) {
                setState(() {
                  _persetujuan = value;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_validatePersetujuan() != null && !_persetujuan)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  _validatePersetujuan()!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Mahasiswa Validasi'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              if (_validateStep(_currentStep)) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                String errorMessage = '';
                if (_currentStep == 0) {
                  errorMessage = 'Lengkapi data pribadi dengan benar';
                } else if (_currentStep == 1) {
                  if (_validateJurusan() != null) {
                    errorMessage = _validateJurusan()!;
                  } else if (_validateHobi() != null) {
                    errorMessage = _validateHobi()!;
                  }
                }
                _showValidationError(errorMessage);
              }
            } else {
              if (_persetujuan) {
                _submitForm();
              } else {
                _showValidationError(_validatePersetujuan()!);
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 2 ? 'Submit' : 'Lanjut'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
