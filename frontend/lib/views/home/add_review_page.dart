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
  final textController = TextEditingController();
  String selectedType = 'film';
  double selectedRating = 8;

  bool _isLoading = false;
  late Future<List<dynamic>> futureMovies;

  final List<Map<String, String>> movieSuggestions = const [
    {
      'title': 'Interstellar',
      'type': 'film',
      'genre': 'Sci-Fi, Adventure',
      'year': '2014',
    },
    {
      'title': 'Parasite',
      'type': 'film',
      'genre': 'Thriller, Drama',
      'year': '2019',
    },
    {
      'title': 'The Dark Knight',
      'type': 'film',
      'genre': 'Action, Crime',
      'year': '2008',
    },
    {
      'title': 'Reply 1988',
      'type': 'drama',
      'genre': 'Slice of Life, Comedy',
      'year': '2015',
    },
    {
      'title': 'Queen of Tears',
      'type': 'drama',
      'genre': 'Romance, Drama',
      'year': '2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService.getMovies();
  }

  @override
  void dispose() {
    titleController.dispose();
    genreController.dispose();
    yearController.dispose();
    textController.dispose();
    super.dispose();
  }

  List<Map<String, String>> localSuggestions(String query) {
    if (query.isEmpty) return movieSuggestions.take(3).toList();

    return movieSuggestions.where((movie) {
      return movie['title']!.toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, String>> filteredMovieSuggestions(List<dynamic> movies) {
    final query = titleController.text.trim().toLowerCase();
    final adminMovies = movies.map((movie) {
      return {
        'title': (movie['title'] ?? '').toString(),
        'type': (movie['type'] ?? 'film').toString(),
        'genre': (movie['genre'] ?? '').toString(),
        'year': (movie['release_year'] ?? '').toString(),
      };
    }).where((movie) {
      if (movie['title']!.isEmpty) return false;
      if (query.isEmpty) return true;
      return movie['title']!.toLowerCase().contains(query);
    }).toList();

    if (adminMovies.isNotEmpty) return adminMovies.take(5).toList();
    return localSuggestions(query);
  }

  void selectMovieSuggestion(Map<String, String> movie) {
    setState(() {
      titleController.text = movie['title']!;
      selectedType = movie['type']!;
      genreController.text = movie['genre']!;
      yearController.text = movie['year']!;
    });
  }

  void submitData() async {
    if (!formKey.currentState!.validate()) return;

    if (ApiService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reviewData = {
      "user_id": ApiService.currentUserId,
      "title": titleController.text.trim(),
      "type": selectedType,
      "genre": genreController.text.trim(),
      "release_year": int.parse(yearController.text),
      "rating": selectedRating.round(),
      "review_text": textController.text.trim(),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF15151F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget buildMovieSuggestions() {
    return FutureBuilder<List<dynamic>>(
      future: futureMovies,
      builder: (context, snapshot) {
        final suggestions = filteredMovieSuggestions(snapshot.data ?? []);
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Column(
          children: suggestions.map((movie) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: const Color(0xFF15151F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(
                  movie['type'] == 'film' ? Icons.movie : Icons.live_tv,
                  color: Colors.redAccent,
                ),
                title: Text(
                  movie['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${movie['genre']} - ${movie['year']}',
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => selectMovieSuggestion(movie),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildRatingPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Rating pribadi: ${selectedRating.round()}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: selectedRating,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: Colors.redAccent,
            inactiveColor: Colors.white12,
            label: selectedRating.round().toString(),
            onChanged: (value) {
              setState(() {
                selectedRating = value;
              });
            },
          ),
        ],
      ),
    );
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
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Cari / ketik judul film atau drama',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF15151F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 10),
                    buildMovieSuggestions(),
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
                    buildInput(
                      controller: genreController,
                      label: 'Genre',
                      icon: Icons.category_outlined,
                      validator: (v) => v!.isEmpty ? 'Genre tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    buildInput(
                      controller: yearController,
                      label: 'Tahun Rilis',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Tahun rilis wajib diisi';
                        final year = int.tryParse(v);
                        if (year == null || year < 1900 || year > 2100) {
                          return 'Masukkan tahun yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    buildRatingPicker(),
                    const SizedBox(height: 12),
                    buildInput(
                      controller: textController,
                      label: 'Komentar / review kamu',
                      icon: Icons.rate_review_outlined,
                      maxLines: 4,
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
