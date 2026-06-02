import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/views/admin/admin_dashboard_page.dart';
import 'package:frontend/views/auth/login_page.dart';
import 'package:frontend/views/auth/register_page.dart';
import 'package:frontend/views/home/add_review_page.dart';

import '../../models/review_model.dart';
import 'widgets/review_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  String selectedFilter = 'Semua';
  String selectedSort = 'Rating Tertinggi';
  String searchQuery = '';

  final List<String> filterOptions = ['Semua', 'Film', 'Series'];
  final List<String> sortOptions = [
    'Rating Tertinggi',
    'Tahun Terbaru',
    'Judul A-Z',
  ];
  final List<String> profileGenreOptions = const [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Historical',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Thriller',
  ];
  final List<String> genderOptions = const ['Pria', 'Wanita', 'Lainnya'];

  late Future<List<dynamic>> futureReviews;
  final List<ReviewModel> currentReviews = [];

  @override
  void initState() {
    super.initState();
    futureReviews = ApiService.getReviews();

    if (ApiService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
        );
      });
    }
  }

  ReviewModel reviewFromJson(dynamic item) {
    return ReviewModel(
      id: item['id'],
      title: item['title'] ?? '-',
      type: item['type'] == 'film' ? 'Film' : 'Series',
      genre: item['genre'] ?? '-',
      releaseYear: item['release_year'] ?? 0,
      rating: double.tryParse(item['rating'].toString()) ?? 0,
      reviewText: item['review_text'] ?? '-',
      reviewerName: item['user'] != null ? item['user']['name'] : 'Anonim',
      isMine: item['user_id'] == ApiService.currentUserId,
      imageUrl: ApiService.normalizeMediaUrl(item['poster_url']) != null
          ? ApiService.normalizeMediaUrl(item['poster_url'])!
          : 'https://picsum.photos/seed/${item['id']}/300/450',
    );
  }

  List<ReviewModel> getProcessedReviews({bool onlyMine = false}) {
    var reviews = [...currentReviews];

    if (onlyMine) {
      reviews = reviews.where((review) => review.isMine).toList();
    }
    if (selectedFilter != 'Semua') {
      reviews = reviews
          .where(
            (review) =>
                review.type.toLowerCase() == selectedFilter.toLowerCase(),
          )
          .toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase();
      reviews = reviews.where((review) {
        return review.title.toLowerCase().contains(query) ||
            review.genre.toLowerCase().contains(query) ||
            review.reviewerName.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedSort == 'Rating Tertinggi') {
      reviews.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSort == 'Tahun Terbaru') {
      reviews.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
    } else {
      reviews.sort((a, b) => a.title.compareTo(b.title));
    }
    return reviews;
  }

  Future<void> refreshReviews() async {
    setState(() {
      futureReviews = ApiService.getReviews();
    });
  }

  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> addReview() async {
    if (!ApiService.isLoggedIn) {
      showLoginRequired();
      return;
    }

    final isChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddReviewPage()),
    );
    if (!mounted) return;
    if (isChanged == true) {
      refreshReviews();
    }
  }

  void showLoginRequired() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Colors.redAccent,
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buat akun dulu untuk menulis review',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guest tetap bisa membaca review dan membuka detail film.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    goToRegister();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Buat Akun'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    goToLogin();
                  },
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDetail(ReviewModel review) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        review.imageUrl,
                        width: 105,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 105,
                            height: 150,
                            color: const Color(0xFF252533),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${review.type} - ${review.genre} - ${review.releaseYear}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${review.rating}/5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.reviewText,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    review.reviewerName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Reviewer MovieLog',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteReview(ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15151F),
          title: const Text(
            'Hapus Review',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Yakin ingin menghapus review "${review.title}"?',
            style: const TextStyle(color: Colors.white70),
          ),
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

    if (confirmed != true) return;
    final success = await ApiService.deleteReview(review.id);
    if (!mounted) return;
    if (success) {
      refreshReviews();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review berhasil dihapus')));
    }
  }

  void logout() {
    ApiService.logout();
    setState(() => selectedIndex = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Keluar akun. Sekarang kamu sebagai guest.'),
      ),
    );
  }

  Widget buildAppBarTitle() {
    if (selectedIndex == 0) {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Movie',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            TextSpan(
              text: 'Log',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      );
    }
    if (selectedIndex == 1) return const Text('Review Saya');
    return const Text('Profil');
  }

  Widget buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFF1A1A24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        ApiService.isLoggedIn
            ? 'Halo, ${ApiService.currentUserName ?? 'MovieLover'}'
            : 'Jelajahi sebagai guest',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildPosterCard(ReviewModel review, int rank) {
    return GestureDetector(
      onTap: () => showDetail(review),
      child: SizedBox(
        width: 125,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  review.imageUrl,
                  width: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF252533),
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$rank. ${review.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${review.type} - ${review.releaseYear}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrendingSection() {
    final trendingReviews = [...currentReviews]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    if (trendingReviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Sekarang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 225,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trendingReviews.take(8).length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                buildPosterCard(trendingReviews[index], index + 1),
          ),
        ),
      ],
    );
  }

  Widget buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari judul, genre, atau reviewer...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF15151F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedFilter,
                dropdownColor: const Color(0xFF15151F),
                decoration: filterDecoration(Icons.filter_list),
                items: filterOptions
                    .map(
                      (filter) =>
                          DropdownMenuItem(value: filter, child: Text(filter)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedFilter = value ?? 'Semua'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedSort,
                dropdownColor: const Color(0xFF15151F),
                decoration: filterDecoration(Icons.sort),
                items: sortOptions
                    .map(
                      (sort) =>
                          DropdownMenuItem(value: sort, child: Text(sort)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedSort = value ?? 'Rating Tertinggi'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration filterDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF15151F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget buildReviewList(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Review tidak ditemukan.',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        return ReviewCard(
          review: review,
          onTap: () => showDetail(review),
          onEdit: null,
          onDelete: review.isMine ? () => deleteReview(review) : null,
        );
      }).toList(),
    );
  }

  Widget buildReviewsFuture({required bool onlyMine}) {
    return FutureBuilder<List<dynamic>>(
      future: futureReviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat review: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        currentReviews
          ..clear()
          ..addAll((snapshot.data ?? []).map(reviewFromJson));
        return buildReviewList(getProcessedReviews(onlyMine: onlyMine));
      },
    );
  }

  Widget buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildHeroHeader(),
        const SizedBox(height: 20),
        buildTrendingSection(),
        const SizedBox(height: 20),
        buildSearchAndFilter(),
        const SizedBox(height: 18),
        const Text(
          'Semua Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        buildReviewsFuture(onlyMine: false),
      ],
    );
  }

  Widget buildGuestGate(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_alt_1,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk atau buat akun supaya review dan profil tersimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: goToRegister,
              icon: const Icon(Icons.person_add),
              label: const Text('Buat Akun'),
            ),
            TextButton(onPressed: goToLogin, child: const Text('Masuk')),
          ],
        ),
      ),
    );
  }

  Widget buildMyReviewPage() {
    if (!ApiService.isLoggedIn) {
      return buildGuestGate('Review Saya khusus akun terdaftar');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Review yang Kamu Buat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        buildSearchAndFilter(),
        const SizedBox(height: 18),
        buildReviewsFuture(onlyMine: true),
      ],
    );
  }

  Widget profileAvatar() {
    final photoUrl = ApiService.currentUserPhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(radius: 45, backgroundImage: NetworkImage(photoUrl));
    }
    return const CircleAvatar(
      radius: 45,
      backgroundColor: Colors.redAccent,
      child: Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  void showEditProfileSheet() {
    final nameController = TextEditingController(
      text: ApiService.currentUserName ?? '',
    );
    String? selectedPhotoPath;
    String selectedGender = ApiService.currentUserGender ?? genderOptions.first;
    final selectedGenres = (ApiService.currentUserFavoriteGenres ?? '')
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toSet();
    final phoneController = TextEditingController(
      text: ApiService.currentUserPhone ?? '',
    );
    final bioController = TextEditingController(
      text: ApiService.currentUserBio ?? '',
    );

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
                      'Edit Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.redAccent,
                        backgroundImage: selectedPhotoPath != null
                            ? FileImage(File(selectedPhotoPath!))
                            : (ApiService.currentUserPhotoUrl != null &&
                                      ApiService.currentUserPhotoUrl!.isNotEmpty
                                  ? NetworkImage(
                                      ApiService.currentUserPhotoUrl!,
                                    )
                                  : null),
                        child:
                            selectedPhotoPath == null &&
                                (ApiService.currentUserPhotoUrl == null ||
                                    ApiService.currentUserPhotoUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 46,
                                color: Colors.white,
                              )
                            : null,
                      ),
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
                        setSheetState(() => selectedPhotoPath = path);
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pilih Foto Profil'),
                    ),
                    const SizedBox(height: 10),
                    profileInput(nameController, 'Nama', Icons.person),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: genderOptions.contains(selectedGender)
                          ? selectedGender
                          : genderOptions.first,
                      dropdownColor: const Color(0xFF15151F),
                      style: const TextStyle(color: Colors.white),
                      decoration: profileDecoration('Gender', Icons.wc),
                      items: genderOptions
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedGender = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    genreChoicePanel(selectedGenres, setSheetState),
                    const SizedBox(height: 10),
                    profileInput(phoneController, 'Nomor Telepon', Icons.phone),
                    const SizedBox(height: 10),
                    profileInput(
                      bioController,
                      'Biodata',
                      Icons.info_outline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final success = await ApiService.updateProfile(
                            name: nameController.text.trim(),
                            favoriteGenres: selectedGenres.join(', '),
                            phone: phoneController.text.trim(),
                            bio: bioController.text.trim(),
                            gender: selectedGender,
                            photoPath: selectedPhotoPath,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          if (success && mounted) {
                            setState(() {});
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Profil'),
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

  Widget genreChoicePanel(
    Set<String> selectedGenres,
    void Function(void Function()) setSheetState,
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
                'Genre Kesukaan',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profileGenreOptions.map((genre) {
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
                onSelected: (value) {
                  setSheetState(() {
                    if (value) {
                      selectedGenres.add(genre);
                    } else {
                      selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget profileInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF09090D),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration profileDecoration(String label, IconData icon) {
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

  Widget profileTile(IconData icon, String title, String value) {
    return Card(
      color: const Color(0xFF15151F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(color: Colors.white60),
        ),
      ),
    );
  }

  Widget buildProfilePage() {
    if (!ApiService.isLoggedIn) {
      return buildGuestGate('Profil tersedia setelah punya akun');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              profileAvatar(),
              const SizedBox(height: 16),
              Text(
                ApiService.currentUserName ?? '-',
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        profileTile(
          Icons.favorite,
          'Genre Kesukaan',
          ApiService.currentUserFavoriteGenres ?? '',
        ),
        profileTile(
          Icons.phone,
          'Nomor Telepon',
          ApiService.currentUserPhone ?? '',
        ),
        profileTile(Icons.wc, 'Gender', ApiService.currentUserGender ?? ''),
        profileTile(Icons.info, 'Biodata', ApiService.currentUserBio ?? ''),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: showEditProfileSheet,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profil'),
        ),
      ],
    );
  }

  Widget buildCurrentPage() {
    if (selectedIndex == 0) return buildHomePage();
    if (selectedIndex == 1) return buildMyReviewPage();
    return buildProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090D),
        elevation: 0,
        title: buildAppBarTitle(),
        actions: [
          if (ApiService.isLoggedIn)
            IconButton(onPressed: logout, icon: const Icon(Icons.logout))
          else
            TextButton.icon(
              onPressed: goToRegister,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Buat Akun'),
            ),
        ],
      ),
      body: buildCurrentPage(),
      floatingActionButton: selectedIndex == 2
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              onPressed: addReview,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101018),
        indicatorColor: Colors.redAccent.withValues(alpha: 0.22),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.redAccent),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie, color: Colors.redAccent),
            label: 'Review Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.redAccent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
