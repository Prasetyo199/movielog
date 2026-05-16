class ReviewModel {
  final int id;
  final String title;
  final String type;
  final String genre;
  final int releaseYear;
  final double rating;
  final String reviewText;
  final String reviewerName;
  final bool isMine;
  final String imageUrl;

  const ReviewModel({
    required this.id,
    required this.title,
    required this.type,
    required this.genre,
    required this.releaseYear,
    required this.rating,
    required this.reviewText,
    required this.reviewerName,
    required this.isMine,
    required this.imageUrl,
  });
}
