import 'package:flutter/material.dart';
import '../../../services/api_services.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({super.key});

  @override
  State<AddReviewPage> createState() => AddReviewPageState();
}

class AddReviewPageState extends State<AddReviewPage> {
  final formKey = GlobalKey<FormState>();
  final searchMovieController = TextEditingController();
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final yearController = TextEditingController();
  final textController = TextEditingController();
  String selectedType = 'film';
  int selectedRating = 0;
  String? selectedMovieTitle;
  String? selectedMovieKey;
  final Set<String> selectedGenres = {};

  bool _isLoading = false;
  late Future<List<dynamic>> futureMovies;

  final List<String> genreOptions = const [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Drama',
    'Family',
    'Fantasy',
    'Historical',
    'Horror',
    'Medical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Thriller',
    'War',
  ];

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService.getMovies();
  }

  @override
  void dispose() {
    searchMovieController.dispose();
    titleController.dispose();
    genreController.dispose();
    yearController.dispose();
    textController.dispose();
    super.dispose();
  }

  List<Map<String, String>> filteredMovieSuggestions(List<dynamic> movies) {
    final query = searchMovieController.text.trim().toLowerCase();
    final adminMovies = movies
        .map((movie) {
          return {
            'title': (movie['title'] ?? '').toString(),
            'type': normalizeType((movie['type'] ?? 'film').toString()),
            'genre': (movie['genre'] ?? '').toString(),
            'year': (movie['release_year'] ?? '').toString(),
            'key': 'admin-${movie['id'] ?? movie['title']}',
          };
        })
        .where((movie) {
          if (movie['title']!.isEmpty) return false;
          if (query.isEmpty) return true;
          return movie['title']!.toLowerCase().contains(query);
        })
        .toList();

    return adminMovies.take(20).toList();
  }

  void selectMovieSuggestion(Map<String, String> movie) {
    setState(() {
      searchMovieController.text = movie['title']!;
      titleController.text = movie['title']!;
      selectedMovieTitle = movie['title'];
      selectedMovieKey = movie['key'];
      selectedType = normalizeType(movie['type']!);
      genreController.text = movie['genre']!;
      yearController.text = movie['year']!;
      selectedGenres
        ..clear()
        ..addAll(
          movie['genre']!
              .split(',')
              .map((genre) => genre.trim())
              .where((genre) => genre.isNotEmpty),
        );
    });
  }

  String normalizeType(String type) {
    return type == 'drama' ? 'series' : type;
  }

  String typeLabel(String type) {
    return type == 'film' ? 'Film' : 'Series';
  }

  void syncGenreController() {
    genreController.text = selectedGenres.join(', ');
  }

  void submitData() async {
    if (!formKey.currentState!.validate()) return;
    if (ApiService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login dulu untuk membuat review.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Bungkus data sesuai format JSON yang diminta oleh ReviewController Laravel
    final reviewData = {
      "user_id": ApiService.currentUserId,
      "title": titleController.text,
      "type": selectedType,
      "genre": selectedGenres.join(', '),
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
        Navigator.pop(
          context,
          true,
        ); // Kembali ke dashboard dengan sinyal sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan review.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget buildTypePicker() {
    return DropdownButtonFormField<String>(
      initialValue: selectedType,
      dropdownColor: const Color(0xFF15151F),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Jenis Tontonan',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.category, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF15151F),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'film', child: Text('Film')),
        DropdownMenuItem(value: 'series', child: Text('Series')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => selectedType = value);
      },
    );
  }

  Widget buildGenrePicker() {
    return FormField<Set<String>>(
      validator: (_) {
        if (selectedGenres.isEmpty) {
          return 'Pilih minimal satu genre';
        }
        return null;
      },
      builder: (field) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.white54),
                  SizedBox(width: 8),
                  Text(
                    'Pilih Genre',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genreOptions.map((genre) {
                  final selected = selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: Colors.redAccent,
                    backgroundColor: const Color(0xFF09090D),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                        syncGenreController();
                        field.didChange(selectedGenres);
                      });
                    },
                  );
                }).toList(),
              ),
              if (selectedGenres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Genre dipilih: ${selectedGenres.join(', ')}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              if (field.hasError) ...[
                const SizedBox(height: 8),
                Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
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
        if (snapshot.hasError) {
          return Text(
            'Gagal memuat katalog admin: ${snapshot.error}',
            style: const TextStyle(color: Colors.white70),
          );
        }

        if (suggestions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF15151F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Katalog admin kosong atau judul tidak ditemukan.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue:
              suggestions.any((movie) => movie['key'] == selectedMovieKey)
              ? selectedMovieKey
              : null,
          dropdownColor: const Color(0xFF15151F),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Pilih Film / Series',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.movie_filter, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF15151F),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: suggestions.map((movie) {
            final title = movie['title']!;
            final type = typeLabel(movie['type']!);

            return DropdownMenuItem(
              value: movie['key'],
              child: Text('$title - $type', overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih film atau series dulu';
            }
            return null;
          },
          onChanged: (value) {
            if (value == null) return;

            final movie = suggestions.firstWhere(
              (item) => item['key'] == value,
            );

            selectMovieSuggestion(movie);
          },
        );
      },
    );
  }

  Widget buildMovieSearch() {
    return TextFormField(
      controller: searchMovieController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari dari katalog admin...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        suffixIcon: searchMovieController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    searchMovieController.clear();
                    selectedMovieKey = null;
                    selectedMovieTitle = null;
                    titleController.clear();
                    genreController.clear();
                    yearController.clear();
                    selectedGenres.clear();
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
        filled: true,
        fillColor: const Color(0xFF15151F),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) {
        setState(() {
          selectedMovieKey = null;
          selectedMovieTitle = null;
          titleController.clear();
          genreController.clear();
          yearController.clear();
          selectedGenres.clear();
        });
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
                  typeLabel(selectedType),
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
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    buildMovieSearch(),
                    const SizedBox(height: 12),
                    buildMoviePicker(),
                    const SizedBox(height: 12),
                    buildTypePicker(),
                    const SizedBox(height: 12),
                    buildGenrePicker(),
                    const SizedBox(height: 12),
                    buildReadonlyInfo(),
                    const SizedBox(height: 12),
                    FormField<int>(
                      validator: (_) {
                        if (selectedRating < 1) {
                          return 'Pilih rating 1 sampai 5';
                        }
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
                      decoration: const InputDecoration(
                        labelText: 'Isi Ulasan / Review',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Ulasan tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: submitData,
                      child: const Text(
                        'Simpan Review',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
