import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hyer/features/auth/data/auth_repository.dart';
import 'package:hyer/features/jobs/domain/models/job_model.dart';
import 'package:hyer/features/jobs/presentation/controllers/business_job_controller.dart';
import 'package:hyer/features/jobs/presentation/screens/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rateController = TextEditingController();
  final _addressController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  
  Position? _currentPosition;
  bool _gettingLocation = false;

  // Yeni: İş türü seçimi (varsayılan: ücretli)
  JobType _selectedJobType = JobType.paid;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    
    try {
      // İzin kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi')));
          setState(() => _gettingLocation = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni kalıcı olarak engellendi.')));
         setState(() => _gettingLocation = false);
         return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _addressController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)} (Koordinat)";
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum alınamadı: $e')));
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tarih aralığı seçin')));
      return;
    }
    if (_currentPosition == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen konum bilgisi alın')));
       return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    // Tarih ve Saati birleştir
    final startDateTime = DateTime(
      _startDate!.year, _startDate!.month, _startDate!.day,
      _startTime.hour, _startTime.minute,
    );
    
    final endDateTime = DateTime(
      _endDate!.year, _endDate!.month, _endDate!.day,
      _endTime.hour, _endTime.minute,
    );

    // Gönüllü ise hourly_rate = 0
    final double? hourlyRate = _selectedJobType == JobType.volunteer
        ? 0
        : double.tryParse(_rateController.text);

    final job = JobModel(
      id: '0', 
      businessId: user.id,
      title: _titleController.text,
      description: _descriptionController.text,
      hourlyRate: hourlyRate,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      addressText: _addressController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      status: JobStatus.open,
      jobType: _selectedJobType,
    );

    try {
      await ref.read(businessJobControllerProvider.notifier).createJob(job);
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla yayınlandı!')));
         context.pop(); 
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(e.toString().replaceAll('Exception: ', '')),
             backgroundColor: Colors.red,
             duration: const Duration(seconds: 5),
           ),
         );
      }
    }
  }

  Future<void> _pickDateTimeRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
  
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(businessJobControllerProvider).isLoading;
    final isPaid = _selectedJobType == JobType.paid;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İlan Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── İş Türü Seçimi (SegmentedButton) ──
              SegmentedButton<JobType>(
                segments: const [
                  ButtonSegment<JobType>(
                    value: JobType.paid,
                    label: Text('Ücretli İş'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                  ButtonSegment<JobType>(
                    value: JobType.volunteer,
                    label: Text('Gönüllü'),
                    icon: Icon(Icons.volunteer_activism),
                  ),
                ],
                selected: {_selectedJobType},
                onSelectionChanged: (Set<JobType> newSelection) {
                  setState(() {
                    _selectedJobType = newSelection.first;
                    // Gönüllü seçildiğinde ücret alanını temizle
                    if (_selectedJobType == JobType.volunteer) {
                      _rateController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İş Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // ── Saatlik Ücret (Sadece Ücretli İş için göster) ──
              if (isPaid) ...[
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'Saatlik Ücret (₺)',
                    border: OutlineInputBorder(),
                    suffixText: 'TL',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDateTimeRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(_startDate == null 
                        ? 'Tarih Aralığı Seç' 
                        : '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text('Başlangıç: ${_startTime.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time_filled),
                      label: Text('Bitiş: ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adres / Konum',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Manuel giriş yok, GPS'ten alacak
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'GPS Konumu',
                    onPressed: _gettingLocation ? null : _getLocation,
                    icon: _gettingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.my_location),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Haritadan Seç',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                      );
                      
                      if (result != null && result is LatLng) {
                         setState(() {
                           _currentPosition = Position(
                             longitude: result.longitude,
                             latitude: result.latitude,
                             timestamp: DateTime.now(),
                             accuracy: 0,
                             altitude: 0,
                             altitudeAccuracy: 0, // Yeni geolocator versiyonlarında required olabilir
                             heading: 0,
                             headingAccuracy: 0,
                             speed: 0,
                             speedAccuracy: 0,
                             // floor vb. (eski versiyonlarda olmayabilir)
                           );
                           _addressController.text = "${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)} (Haritadan)";
                         });
                      }
                    },
                    icon: const Icon(Icons.map),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('İlanı Yayınla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

