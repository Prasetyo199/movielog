import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/views/home/dashboard_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  late Future<List<dynamic>> futureMovies;
  late Future<List<dynamic>> futureUsers;
  late Future<List<dynamic>> futureReviews;
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
    refreshData();
  }

  void refreshData() {
    futureMovies = ApiService.getMovies();
    futureUsers = ApiService.getUsers();
    futureReviews = ApiService.getReviews();
  }

  void logout() {
    ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  String ratingLabel(dynamic rating) {
    return (double.tryParse((rating ?? 0).toString()) ?? 0).toStringAsFixed(1);
  }

  Widget statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget buildOverview() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        futureMovies,
        futureUsers,
        futureReviews,
      ]).then((values) => values),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        final data = snapshot.data ?? [[], [], []];
        final movies = data[0];
        final users = data[1];
        final reviews = data[2];
        final admins = users.where((user) => user['role'] == 'admin').length;
        final regularUsers = users.length - admins;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Dashboard Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                statCard('Movie', movies.length.toString(), Icons.movie),
                const SizedBox(width: 10),
                statCard('User', regularUsers.toString(), Icons.people),
                const SizedBox(width: 10),
                statCard(
                  'Admin',
                  admins.toString(),
                  Icons.admin_panel_settings,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                statCard('Review', reviews.length.toString(), Icons.reviews),
                const SizedBox(width: 10),
                statCard('Login Sebagai', 'Admin', Icons.verified_user),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Review Terbaru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...reviews.take(5).map((review) {
              return adminTile(
                icon: Icons.star,
                title: review['title'] ?? '-',
                subtitle:
                    '${review['user']?['name'] ?? 'Anonim'} - Rating ${ratingLabel(review['rating'])}/5',
                onTap: () => showReviewDetail(review),
              );
            }),
          ],
        );
      },
    );
  }

  Widget adminTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF15151F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: trailing,
      ),
    );
  }

  void showReviewDetail(dynamic review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF15151F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rate_review, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review['title'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${review['user']?['name'] ?? 'Anonim'} - ${review['type']} - Rating ${ratingLabel(review['rating'])}/5',
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Komentar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (review['review_text'] ?? '-').toString(),
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> confirmDelete({
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15151F),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  void showAddMovieSheet() => showMovieSheet();

  void showMovieSheet({dynamic movie}) {
    final isEdit = movie != null;
    final titleController = TextEditingController(
      text: isEdit ? (movie['title'] ?? '').toString() : '',
    );
    final descriptionController = TextEditingController(
      text: isEdit ? (movie['description'] ?? '').toString() : '',
    );
    String selectedType = isEdit
        ? ((movie['type'] ?? 'film').toString() == 'series' ? 'series' : 'film')
        : 'film';
    String? selectedPosterPath;
    final selectedGenres = isEdit
        ? (movie['genre'] ?? '')
              .toString()
              .split(',')
              .map((genre) => genre.trim())
              .where((genre) => genre.isNotEmpty)
              .toSet()
        : <String>{};
    int selectedYear = isEdit
        ? int.tryParse((movie['release_year'] ?? '').toString()) ??
              DateTime.now().year
        : DateTime.now().year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF15151F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Movie' : 'Tambah Movie',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    sheetInput(titleController, 'Judul', Icons.movie),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: const Color(0xFF15151F),
                      style: const TextStyle(color: Colors.white),
                      decoration: sheetDecoration('Jenis', Icons.category),
                      items: const [
                        DropdownMenuItem(value: 'film', child: Text('Film')),
                        DropdownMenuItem(
                          value: 'series',
                          child: Text('Series'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedType = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    buildAdminGenrePicker(selectedGenres, (genre, selected) {
                      setSheetState(() {
                        if (selected) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                      });
                    }),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDialog<int>(
                          context: context,
                          builder: (dialogContext) {
                            var dialogYear = selectedYear;
                            return AlertDialog(
                              backgroundColor: const Color(0xFF15151F),
                              title: const Text(
                                'Pilih Tahun Rilis',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: SizedBox(
                                width: 280,
                                child: YearPicker(
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(now.year + 2),
                                  selectedDate: DateTime(dialogYear),
                                  onChanged: (date) {
                                    dialogYear = date.year;
                                    Navigator.pop(dialogContext, dialogYear);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        if (picked == null) return;
                        setSheetState(() => selectedYear = picked);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text('Tahun Rilis: $selectedYear'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        final path = result?.files.single.path;
                        if (path == null) return;
                        setSheetState(() => selectedPosterPath = path);
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        selectedPosterPath == null
                            ? 'Pilih Poster'
                            : 'Ganti Poster',
                      ),
                    ),
                    if (selectedPosterPath != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedPosterPath!),
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    sheetInput(
                      descriptionController,
                      'Deskripsi',
                      Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        try {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Judul tidak boleh kosong'),
                              ),
                            );
                            return;
                          }
                          if (selectedGenres.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih minimal satu genre'),
                              ),
                            );
                            return;
                          }

                          final movieData = {
                            'title': titleController.text.trim(),
                            'type': selectedType,
                            'genre': selectedGenres.join(', '),
                            'release_year': selectedYear,
                            'description': descriptionController.text.trim(),
                          };
                          final success = isEdit
                              ? await ApiService.updateMovie(
                                  movie['id'],
                                  movieData,
                                  posterPath: selectedPosterPath,
                                )
                              : await ApiService.addMovie(
                                  movieData,
                                  posterPath: selectedPosterPath,
                                );

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (!mounted) return;
                          if (success) {
                            setState(refreshData);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Movie diperbarui'
                                      : 'Movie ditambahkan',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Movie'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration sheetDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF09090D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget sheetInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: sheetDecoration(label, icon),
    );
  }

  Widget buildAdminGenrePicker(
    Set<String> selectedGenres,
    void Function(String genre, bool selected) onSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF09090D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                'Genre',
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
                backgroundColor: const Color(0xFF15151F),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                ),
                onSelected: (value) => onSelected(genre, value),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            selectedGenres.isEmpty
                ? 'Belum ada genre dipilih'
                : 'Dipilih: ${selectedGenres.join(', ')}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildMovies() {
    return FutureBuilder<List<dynamic>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        final movies = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: showAddMovieSheet,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Movie untuk Direview'),
            ),
            const SizedBox(height: 14),
            if (movies.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Belum ada movie di katalog admin.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ...movies.map((movie) {
              return adminTile(
                icon: movie['type'] == 'film' ? Icons.movie : Icons.live_tv,
                title: movie['title'] ?? '-',
                subtitle:
                    '${movie['type']} - ${movie['genre']} - ${movie['release_year']}',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit movie',
                      onPressed: () => showMovieSheet(movie: movie),
                      icon: const Icon(Icons.edit, color: Colors.white70),
                    ),
                    IconButton(
                      tooltip: 'Hapus movie',
                      onPressed: () async {
                        final confirmed = await confirmDelete(
                          title: 'Hapus Movie',
                          message:
                              'Yakin ingin menghapus "${movie['title'] ?? '-'}"?',
                        );
                        if (!confirmed) return;

                        final success = await ApiService.deleteMovie(
                          movie['id'],
                        );
                        if (success && mounted) {
                          setState(refreshData);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget buildUsers() {
    return FutureBuilder<List<dynamic>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        final users = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: users.map((user) {
            final isCurrentUser = user['id'] == ApiService.currentUserId;
            final isActive = user['is_active'] != false;

            return adminTile(
              icon: user['role'] == 'admin'
                  ? Icons.admin_panel_settings
                  : Icons.person,
              title: user['name'] ?? '-',
              subtitle:
                  '${user['email']} - ${user['role']} - ${isActive ? 'aktif' : 'nonaktif'}',
              trailing: isCurrentUser
                  ? const Chip(
                      label: Text('Saya'),
                      backgroundColor: Colors.redAccent,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isActive,
                          activeThumbColor: Colors.redAccent,
                          onChanged: (value) async {
                            final success = await ApiService.toggleUserStatus(
                              user['id'],
                              value,
                            );
                            if (success && mounted) setState(refreshData);
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirmed = await confirmDelete(
                              title: 'Hapus User',
                              message:
                                  'Yakin ingin menghapus user "${user['name'] ?? '-'}"?',
                            );
                            if (!confirmed) return;

                            final success = await ApiService.deleteUser(
                              user['id'],
                            );
                            if (success && mounted) {
                              setState(refreshData);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildReviews() {
    return FutureBuilder<List<dynamic>>(
      future: futureReviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        final reviews = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: reviews.map((review) {
            return adminTile(
              icon: Icons.rate_review,
              title: review['title'] ?? '-',
              subtitle:
                  '${review['user']?['name'] ?? 'Anonim'} - ${review['type']} - Rating ${ratingLabel(review['rating'])}/5\nKomentar: ${review['review_text'] ?? '-'}',
              onTap: () => showReviewDetail(review),
              trailing: IconButton(
                onPressed: () async {
                  final confirmed = await confirmDelete(
                    title: 'Hapus Review',
                    message:
                        'Yakin ingin menghapus review "${review['title'] ?? '-'}"?',
                  );
                  if (!confirmed) return;

                  final success = await ApiService.deleteReview(review['id']);
                  if (success && mounted) setState(refreshData);
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildAdminProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Colors.redAccent,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ApiService.currentUserName ?? 'Admin MovieLog',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ApiService.currentUserEmail ?? '-',
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 10),
              const Chip(
                backgroundColor: Colors.redAccent,
                avatar: Icon(Icons.security, color: Colors.white, size: 18),
                label: Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        adminTile(
          icon: Icons.movie_filter,
          title: 'Kelola katalog movie',
          subtitle: 'Tambah dan hapus film/series yang bisa direview user',
        ),
        adminTile(
          icon: Icons.manage_accounts,
          title: 'Kelola user',
          subtitle: 'Pantau user dan hapus akun yang tidak diperlukan',
        ),
        adminTile(
          icon: Icons.rate_review,
          title: 'Moderasi review',
          subtitle: 'Lihat aktivitas review dari semua pengguna',
        ),
      ],
    );
  }

  Widget buildPage() {
    if (selectedIndex == 0) return buildOverview();
    if (selectedIndex == 1) return buildMovies();
    if (selectedIndex == 2) return buildUsers();
    if (selectedIndex == 3) return buildReviews();
    return buildAdminProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090D),
        automaticallyImplyLeading: false,
        title: const Text('Admin Console'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Chip(
              backgroundColor: Colors.redAccent,
              label: Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Keluar'),
          ),
        ],
      ),
      body: buildPage(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101018),
        indicatorColor: Colors.redAccent.withValues(alpha: 0.22),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.redAccent),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_creation_outlined),
            selectedIcon: Icon(Icons.movie_creation, color: Colors.redAccent),
            label: 'Movie',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.redAccent),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.reviews_outlined),
            selectedIcon: Icon(Icons.reviews, color: Colors.redAccent),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(
              Icons.admin_panel_settings,
              color: Colors.redAccent,
            ),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
