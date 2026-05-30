import 'package:flutter/material.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/views/auth/login_page.dart';

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
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
      future: Future.wait([futureMovies, futureUsers, futureReviews]).then(
        (values) => values,
      ),
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
                statCard('Admin', admins.toString(), Icons.admin_panel_settings),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                statCard('Review', reviews.length.toString(), Icons.reviews),
                const SizedBox(width: 10),
                statCard(
                  'Login Sebagai',
                  'Admin',
                  Icons.verified_user,
                ),
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
                    '${review['user']?['name'] ?? 'Anonim'} - Rating ${review['rating']}/5',
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
  }) {
    return Card(
      color: const Color(0xFF15151F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
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

  void showAddMovieSheet() {
    final titleController = TextEditingController();
    final genreController = TextEditingController();
    final yearController = TextEditingController();
    final posterController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'film';

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
                    const Text(
                      'Tambah Movie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                        DropdownMenuItem(value: 'drama', child: Text('Drama')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedType = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    sheetInput(genreController, 'Genre', Icons.local_offer),
                    const SizedBox(height: 10),
                    sheetInput(
                      yearController,
                      'Tahun Rilis',
                      Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    sheetInput(
                      posterController,
                      'URL Poster',
                      Icons.image_outlined,
                    ),
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
                        final success = await ApiService.addMovie({
                          'title': titleController.text.trim(),
                          'type': selectedType,
                          'genre': genreController.text.trim(),
                          'release_year': int.tryParse(yearController.text) ?? 0,
                          'poster_url': posterController.text.trim(),
                          'description': descriptionController.text.trim(),
                        });

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (!mounted) return;
                        if (success) {
                          setState(refreshData);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Movie ditambahkan')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Movie'),
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
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF09090D),
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
            ...movies.map((movie) {
              return adminTile(
                icon: movie['type'] == 'film' ? Icons.movie : Icons.live_tv,
                title: movie['title'] ?? '-',
                subtitle:
                    '${movie['type']} - ${movie['genre']} - ${movie['release_year']}',
                trailing: IconButton(
                  onPressed: () async {
                    final success = await ApiService.deleteMovie(movie['id']);
                    if (success && mounted) {
                      setState(refreshData);
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
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

            return adminTile(
              icon: user['role'] == 'admin'
                  ? Icons.admin_panel_settings
                  : Icons.person,
              title: user['name'] ?? '-',
              subtitle: '${user['email']} - ${user['role']}',
              trailing: isCurrentUser
                  ? const Chip(
                      label: Text('Saya'),
                      backgroundColor: Colors.redAccent,
                    )
                  : IconButton(
                      onPressed: () async {
                        final success = await ApiService.deleteUser(user['id']);
                        if (success && mounted) {
                          setState(refreshData);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                  '${review['user']?['name'] ?? 'Anonim'} - ${review['type']} - Rating ${review['rating']}/5',
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
          subtitle: 'Tambah dan hapus film/drama yang bisa direview user',
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
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
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
