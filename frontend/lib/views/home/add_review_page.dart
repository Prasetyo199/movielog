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
  String selectedType = 'film'; // Bawaan default sesuai enum Laravel
  int selectedRating = 0;
  String? selectedMovieTitle;

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

    setState(() => _isLoading = true);

    // Bungkus data sesuai format JSON yang diminta oleh ReviewController Laravel
    final reviewData = {
      "user_id": 1, // Sementara hardcode user ID tyo
      "title": titleController.text,
      "type": selectedType,
      "genre": genreController.text,
      "release_year": int.parse(yearController.text),
      "rating": selectedRating,
      "review_text": textController.text,
    };

    try {
      final success = await ApiService.addReview(reviewData);
      if (!mounted) return;

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
      if (!mounted) return;

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

  Widget buildMoviePicker() {
    return FutureBuilder<List<dynamic>>(
      future: futureMovies,
      builder: (context, snapshot) {
        final suggestions = filteredMovieSuggestions(snapshot.data ?? []);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue: selectedMovieTitle,
          dropdownColor: const Color(0xFF15151F),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Pilih Film / Drama',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.movie_filter, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF15151F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: suggestions.map((movie) {
            final title = movie['title']!;
            final type = movie['type'] == 'film' ? 'Film' : 'Drama';

            return DropdownMenuItem(
              value: title,
              child: Text(
                '$title - $type',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih film atau drama dulu';
            }
            return null;
          },
          onChanged: (value) {
            if (value == null) return;

            final movie = suggestions.firstWhere(
              (item) => item['title'] == value,
            );

            selectedMovieTitle = value;
            selectMovieSuggestion(movie);
          },
        );
      },
    );
  }

  Widget buildReadonlyInfo() {
    if (titleController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            selectedType == 'film' ? Icons.movie : Icons.live_tv,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedType == 'film' ? 'Film' : 'Drama',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${genreController.text} - ${yearController.text}',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
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
                selectedRating == 0
                    ? 'Beri rating'
                    : 'Rating pribadi: $selectedRating/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = rating <= selectedRating;

              return IconButton(
                tooltip: '$rating dari 5',
                onPressed: () {
                  setState(() {
                    selectedRating = rating;
                  });
                },
                icon: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 34,
                ),
              );
            }),
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
                    buildMoviePicker(),
                    const SizedBox(height: 12),
                    buildReadonlyInfo(),
                    const SizedBox(height: 12),
                    FormField<int>(
                      validator: (_) {
                        if (selectedRating < 1) return 'Pilih rating 1 sampai 5';
                        return null;
                      },
                      builder: (field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRatingPicker(),
                            if (field.hasError) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  field.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
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
