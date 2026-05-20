import 'package:flutter/material.dart';
import '../../../services/api_services.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({super.key});

  @override
  State<AddReviewPage> createState() => AddReviewPageState();
}

class AddReviewPageState extends State<AddReviewPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final yearController = TextEditingController();
  final ratingController = TextEditingController();
  final textController = TextEditingController();
  String selectedType = 'film'; // Bawaan default sesuai enum Laravel

  bool _isLoading = false;

  void submitData() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Bungkus data sesuai format JSON yang diminta oleh ReviewController Laravel
    final reviewData = {
      "user_id": 1, // Sementara hardcode user ID tyo
      "title": titleController.text,
      "type": selectedType,
      "genre": genreController.text,
      "release_year": int.parse(yearController.text),
      "rating": int.parse(ratingController.text),
      "review_text": textController.text,
    };

    try {
      final success = await ApiService.addReview(reviewData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil ditambahkan!')),
        );
        Navigator.pop(context, true); // Kembali ke dashboard dengan sinyal sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan review.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      appBar: AppBar(
        title: const Text('Tambah Ulasan Baru'),
        backgroundColor: const Color(0xFF09090D),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Judul Film / Drama', labelStyle: TextStyle(color: Colors.white70)),
                      validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: const Color(0xFF15151F),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Tipe', labelStyle: TextStyle(color: Colors.white70)),
                      items: const [
                        DropdownMenuItem(value: 'film', child: Text('Film')),
                        DropdownMenuItem(value: 'drama', child: Text('Drama')),
                      ],
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: genreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Genre', labelStyle: TextStyle(color: Colors.white70)),
                      validator: (v) => v!.isEmpty ? 'Genre tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: yearController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tahun Rilis', labelStyle: TextStyle(color: Colors.white70)),
                      validator: (v) => v!.isEmpty ? 'Tahun rilis wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ratingController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rating (1-10)', labelStyle: TextStyle(color: Colors.white70)),
                      validator: (v) {
                        if (v!.isEmpty) return 'Rating wajib diisi';
                        final r = int.tryParse(v);
                        if (r == null || r < 1 || r > 10) return 'Masukkan angka 1 sampai 10';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Isi Ulasan / Review', labelStyle: TextStyle(color: Colors.white70)),
                      validator: (v) => v!.isEmpty ? 'Ulasan tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: submitData,
                      child: const Text('Simpan Review', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}