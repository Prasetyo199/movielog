import 'package:flutter/material.dart';
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

  final List<String> filterOptions = ['Semua', 'Film', 'Drama'];
  final List<String> sortOptions = [
    'Rating Tertinggi',
    'Tahun Terbaru',
    'Judul A-Z',
  ];

  final List<ReviewModel> dummyReviews = [
    const ReviewModel(
      id: 1,
      title: 'Interstellar',
      type: 'Film',
      genre: 'Sci-Fi',
      releaseYear: 2014,
      rating: 9.5,
      reviewText:
          'Film sci-fi yang sangat bagus dengan cerita emosional dan visual yang keren.',
      reviewerName: 'Andi',
      isMine: true,
      imageUrl: 'https://picsum.photos/seed/interstellar/300/450',
    ),
    const ReviewModel(
      id: 2,
      title: 'Queen of Tears',
      type: 'Drama',
      genre: 'Romance',
      releaseYear: 2024,
      rating: 8.8,
      reviewText:
          'Drama Korea dengan konflik keluarga dan hubungan yang menarik untuk diikuti.',
      reviewerName: 'Sinta',
      isMine: false,
      imageUrl: 'https://picsum.photos/seed/queenoftears/300/450',
    ),
    const ReviewModel(
      id: 3,
      title: 'Avengers: Endgame',
      type: 'Film',
      genre: 'Action',
      releaseYear: 2019,
      rating: 9.0,
      reviewText:
          'Penutup saga Avengers yang emosional, ramai, dan memuaskan untuk penggemar Marvel.',
      reviewerName: 'Budi',
      isMine: true,
      imageUrl: 'https://picsum.photos/seed/avengers/300/450',
    ),
    const ReviewModel(
      id: 4,
      title: 'Moving',
      type: 'Drama',
      genre: 'Action, Fantasy',
      releaseYear: 2023,
      rating: 9.2,
      reviewText:
          'Drama dengan cerita keluarga, kekuatan super, dan aksi yang sangat seru.',
      reviewerName: 'Raka',
      isMine: false,
      imageUrl: 'https://picsum.photos/seed/movingdrama/300/450',
    ),
    const ReviewModel(
      id: 5,
      title: 'The Batman',
      type: 'Film',
      genre: 'Crime, Mystery',
      releaseYear: 2022,
      rating: 8.7,
      reviewText:
          'Film Batman dengan suasana gelap, misteri kuat, dan visual yang sangat sinematik.',
      reviewerName: 'Andi',
      isMine: true,
      imageUrl: 'https://picsum.photos/seed/thebatman/300/450',
    ),
  ];

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

    if (selectedIndex == 1) {
      return const Text('Review Saya');
    }

    return const Text('Profil');
  }

  List<ReviewModel> getProcessedReviews({bool onlyMine = false}) {
    List<ReviewModel> reviews = dummyReviews;

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
    } else if (selectedSort == 'Judul A-Z') {
      reviews.sort((a, b) => a.title.compareTo(b.title));
    }

    return reviews;
  }

  void showDetail(ReviewModel review) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Membuka detail: ${review.title}')));
  }

  void editReview(ReviewModel review) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit review: ${review.title}')));
  }

  void deleteReview(ReviewModel review) {
    showDialog(
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  dummyReviews.removeWhere((item) => item.id == review.id);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review berhasil dihapus')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void addReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nanti masuk ke halaman tambah review')),
    );
  }

  void logout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logout berhasil')));
  }

  Widget buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFF1A1A24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan Review Film & Drama',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lihat review pengguna lain, beri rating, dan kelola review milikmu sendiri.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      review.imageUrl,
                      width: 125,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 125,
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

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            review.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              review.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '${review.type} • ${review.releaseYear}',
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
    final trendingReviews = [...dummyReviews]
      ..sort((a, b) => b.rating.compareTo(a.rating));

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
            itemCount: trendingReviews.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 12);
            },
            itemBuilder: (context, index) {
              final review = trendingReviews[index];

              return buildPosterCard(review, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari judul, genre, atau reviewer...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF15151F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((filter) {
              final isSelected = selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: Colors.redAccent,
                  backgroundColor: const Color(0xFF15151F),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (value) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: selectedSort,
          dropdownColor: const Color(0xFF15151F),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF15151F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          iconEnabledColor: Colors.white70,
          style: const TextStyle(color: Colors.white),
          items: sortOptions.map((sort) {
            return DropdownMenuItem(value: sort, child: Text(sort));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedSort = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildReviewList(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F),
          borderRadius: BorderRadius.circular(18),
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
          onEdit: review.isMine ? () => editReview(review) : null,
          onDelete: review.isMine ? () => deleteReview(review) : null,
        );
      }).toList(),
    );
  }

  Widget buildHomePage() {
    final reviews = getProcessedReviews();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildHeroHeader(),

        const SizedBox(height: 24),

        buildTrendingSection(),

        const SizedBox(height: 24),

        buildSearchAndFilter(),

        const SizedBox(height: 22),

        Row(
          children: [
            const Text(
              'Semua Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${reviews.length} data',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),

        const SizedBox(height: 12),

        buildReviewList(reviews),
      ],
    );
  }

  Widget buildMyReviewPage() {
    final myReviews = getProcessedReviews(onlyMine: true);

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

        const SizedBox(height: 6),

        const Text(
          'Di halaman ini, nanti user hanya bisa edit dan hapus review miliknya sendiri.',
          style: TextStyle(color: Colors.white60),
        ),

        const SizedBox(height: 18),

        buildSearchAndFilter(),

        const SizedBox(height: 18),

        buildReviewList(myReviews),
      ],
    );
  }

  Widget buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),

              SizedBox(height: 16),

              Text(
                'Andi Pratama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4),

              Text('andi@email.com', style: TextStyle(color: Colors.white60)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Card(
          color: const Color(0xFF15151F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const ListTile(
            leading: Icon(Icons.phone, color: Colors.redAccent),
            title: Text('Nomor Telepon', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              '0812-3456-7890',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ),

        Card(
          color: const Color(0xFF15151F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const ListTile(
            leading: Icon(Icons.info, color: Colors.redAccent),
            title: Text('Biodata', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Suka menonton film sci-fi, action, dan drama Korea.',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nanti masuk ke halaman edit profil'),
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profil'),
        ),
      ],
    );
  }

  Widget buildCurrentPage() {
    if (selectedIndex == 0) {
      return buildHomePage();
    } else if (selectedIndex == 1) {
      return buildMyReviewPage();
    } else {
      return buildProfilePage();
    }
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
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
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
        indicatorColor: Colors.redAccent.withOpacity(0.22),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
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
